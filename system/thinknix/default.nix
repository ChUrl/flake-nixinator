{
  inputs,
  hostname,
  lib,
  mylib,
  config,
  pkgs,
  system,
  username,
  headless,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # General services
    ../services/adguard.nix
    ../services/arcane.nix
    # ../services/portainer.nix
    # ../services/pulse.nix
    # ../services/pulse-agent-thinknix.nix
    # ../services/whats-up-docker.nix
  ];

  networking.tempAddresses = "disabled";

  systemmodules = {
    authelia.enable = true;

    caddy = {
      enable = true;

      # Entrypoint for LAN and WAN.
      httpPort = 80;
      httpsPort = 443;
      autoHttps = true;
      dnsProvider = "ionos";

      # AdGuard answers NODATA for TXT below *.local.chriphost.de, so the
      # propagation check must not use the LAN resolver.
      acmeResolver = "8.8.8.8:53";

      openFirewall = true;
    };

    docker.networks = [
      {
        name = "behind-nginx";
        disable_masquerade = false;

        ipv6.enable = true;
        ipv6.subnet = "fd00:1::/64";
        # ipv6.gateway = "fd00::5";
      }
    ];

    network = {
      useNetworkManager = false;

      networks = {
        "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "ens18";
          ips = ["192.168.86.26/24"];
          routers = ["192.168.86.5"]; # Don't add "fd00::5", rely on router advertisement instead
          nameservers = ["8.8.8.8" "8.8.4.4" "2001:4860:4860::8888" "2001:4860:4860::8844"]; # NOTE: Use reliable DNS for servers instead of 127.0.0.1
          routable = true;
          privacy = "no";
          extraAddresses = ["fd00::1a/64"]; # IPv6 ULA — declared without creating a route
        };
      };

      # The Caddy ports are opened by the caddy systemmodules
      allowedTCPPorts = [
        53 # DNS
      ];
      allowedUDPPorts = [
        53 # DNS
      ];
    };

    sops-nix.secrets.${username} = [
      "arcane-encryption-key"
      "arcane-jwt-secret"
    ];
  };

  # networking.wireguard.interfaces."vps-wg-client" = {
  #   ips = ["10.10.10.2/32"];
  #   privateKeyFile = "${config.sops.secrets.wireguard-vps-private-key.path}";

  #   # Create the depending network namespace
  #   # preSetup = ''
  #   #   ${pkgs.iproute2}/bin/ip netns add ${name}
  #   # '';

  #   # postSetup = ''
  #   #   ${pkgs.iptables}/bin/iptables -A FORWARD -i vps-wg-client -j ACCEPT
  #   #   ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
  #   # '';
  #   # postShutdown = ''
  #   #   ${pkgs.iptables}/bin/iptables -D FORWARD -i vps-wg-client -j ACCEPT
  #   #   ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ens18 -j MASQUERADE
  #   # '';
  #   postSetup = ''
  #     ${pkgs.iptables} -A FORWARD -i wg0-client -j ACCEPT
  #     ${pkgs.iptables} -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  #   '';
  #   postShutdown = ''
  #     ${pkgs.iptables} -D FORWARD -i wg0-client -j ACCEPT
  #     ${pkgs.iptables} -t nat -D POSTROUTING -o eth0 -j MASQUERADE
  #   '';

  #   peers = [
  #     {
  #       name = "chriphost-vps";
  #       publicKey = "w/U8p9fizw0jk8PFaMZXV1N49Ws+q6mUHzNFYtoDTS8=";
  #       endpoint = "212.227.233.241:51820";
  #       allowedIPs = [
  #         "10.10.10.0/24"
  #       ];

  #       # Keep this connection alive so the server can always reach us
  #       persistentKeepalive = 25;
  #     }
  #   ];
  # };

  services = {
    # Forward thinknix 222 to servenix 222, otherwise all .git/config paths would
    # have to be updated to servenix.chriphost.de:222, as local.chriphost.de now
    # points to thinknix (LAN/WAN entry + TLS termination lives there)
    haproxy = {
      enable = true;
      config = ''
        defaults
          mode tcp
          timeout connect 5s
          timeout client  1h
          timeout server  1h

        frontend gitea-ssh
          bind :222
          default_backend gitea-ssh

        backend gitea-ssh
          server servenix 192.168.86.25:222
      '';
    };

    # This host is the entry for LAN and WAN: everything that is hosted on
    # servenix is forwarded to its Caddy over HTTP inside the LAN (see
    # system/servenix/default.nix). Only thinknix terminates TLS and uses
    # Authelia, so there is only one certificate store.
    caddy.virtualHosts =
      # Public names, forwarded by the VPS over WireGuard with the Host header
      # preserved. TLS terminates at the VPS, so these are plain HTTP here.
      lib.genAttrs [
        "f10.vps.chriphost.de"
        "f11.vps.chriphost.de"
        "f12.vps.chriphost.de"
        "f11pb.vps.chriphost.de"
        "f12pb.vps.chriphost.de"
        "gitea.vps.chriphost.de"
        "immich.vps.chriphost.de"
        "jellyfin.vps.chriphost.de"
        "nextcloud.vps.chriphost.de"
        "ntfy.vps.chriphost.de"
        "paperless.vps.chriphost.de"
        "f11.vps.chriphost.gay"
        "f12.vps.chriphost.gay"
        "jellyfin.vps.chriphost.gay"
        "f11.chriphost.de"
      ] (h: {
        hostName = "http://${h}";
        extraConfig = "reverse_proxy http://192.168.86.25:9080";
      })
      // {
        # Local services on this host
        "auth.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = "reverse_proxy 127.0.0.1:9091";
        };

        "adguard.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = "reverse_proxy 127.0.0.1:3000";
        };

        "arcane.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = "reverse_proxy 127.0.0.1:3552";
        };

        # Devices that are not hosted here or on servenix
        "hass.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = "reverse_proxy http://192.168.86.55:8123";
        };

        "switch.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = "reverse_proxy http://192.168.86.2:80";
        };

        "wifi.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = "reverse_proxy http://192.168.86.3:80";
        };

        "synology.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = "reverse_proxy http://192.168.86.15:5000";
        };

        "truenas.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = ''
            reverse_proxy https://192.168.86.20:443 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';
        };

        "pve.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = ''
            reverse_proxy https://192.168.86.4:8006 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';
        };

        "pvf.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = ''
            reverse_proxy https://192.168.86.13:8006 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';
        };

        "opnsense.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = ''
            reverse_proxy https://192.168.86.5:443 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';
        };

        # Everything else that lives on servenix. Thinknix only terminates TLS
        # and forwards to servenix's Caddy, which does the actual routing.
        "*.local.chriphost.de" = {
          useACMEHost = "local.chriphost.de";
          extraConfig = "reverse_proxy http://192.168.86.25:9080";
        };

        "http://hass.vps.chriphost.de" = {
          extraConfig = "reverse_proxy http://192.168.86.55:8123";
        };
      };

    # Configure keymap in X11
    xserver = {
      xkb.layout = "us";
      xkb.variant = "altgr-intl";
    };

    qemuGuest.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
