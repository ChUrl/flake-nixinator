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
    ../services/nixos/adguard.nix
    ../services/docker/arcane.nix
    ../services/docker/backrest.nix
  ];

  networking.tempAddresses = "disabled";

  systemmodules = {
    remote-build.enable = true;

    authelia.enable = true;

    caddy = {
      enable = true;

      # Entrypoint for LAN and WAN.
      httpPort = 80;
      httpsPort = 443;
      autoHttps = true;
      dnsProvider = "hetzner";

      # AdGuard answers NODATA for TXT below *.local.chriphost.gay, so the
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

    restic = {
      enable = true;

      paths = [
        "/var/lib/acme"
        "/var/lib/authelia-main"
        "/var/lib/docker/volumes"
        "/var/lib/AdGuardHome"
      ];

      extraBackupArgs = [
        "--exclude-caches"
        "--cleanup-cache"
      ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
    };

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
        222 # Gitea SSH (streamed to servenix 222 via haproxy)
      ];
      allowedUDPPorts = [
        53 # DNS
      ];
    };

    sops-nix.secrets.${username} = [
      "arcane-encryption-key"
    ];
  };

  services = {
    # Forward thinknix 222 to servenix 222, otherwise all .git/config paths would
    # have to be updated to servenix.chriphost.gay:222, as local.chriphost.gay now
    # points to thinknix (LAN/WAN entry + TLS termination lives there)
    haproxy = {
      enable = true;
      config = ''
        defaults
          mode tcp
          timeout connect 5s
          timeout client  1h
          timeout server  1h

        frontend gitea-ssh-frontend
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
        "f10.vps.chriphost.gay"
        "f11.vps.chriphost.gay"
        "f12.vps.chriphost.gay"
        "f11pb.vps.chriphost.gay"
        "f12pb.vps.chriphost.gay"
        "gitea.vps.chriphost.gay"
        "immich.vps.chriphost.gay"
        "jellyfin.vps.chriphost.gay"
        "nextcloud.vps.chriphost.gay"
        "ntfy.vps.chriphost.gay"
        "paperless.vps.chriphost.gay"
      ] (h: {
        hostName = "http://${h}";
        extraConfig = "reverse_proxy http://192.168.86.25:9080";
      })
      // {
        # Local services on this host
        "auth.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = "reverse_proxy 127.0.0.1:9091";
        };

        "adguard.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = "reverse_proxy 127.0.0.1:3000";
        };

        "arcane.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = "reverse_proxy 127.0.0.1:3552";
        };

        "restic.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = "reverse_proxy 127.0.0.1:9898";
        };

        # Devices that are not hosted here or on servenix
        "hass.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = "reverse_proxy http://192.168.86.55:8123";
        };

        "switch.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = "reverse_proxy http://192.168.86.2:80";
        };

        "wifi.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = "reverse_proxy http://192.168.86.3:80";
        };

        "synology.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = "reverse_proxy http://192.168.86.15:5000";
        };

        "amp.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = "reverse_proxy http://192.168.86.35:8080";
        };

        "truenas.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = ''
            reverse_proxy https://192.168.86.20:443 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';
        };

        "pve.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = ''
            reverse_proxy https://192.168.86.4:8006 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';
        };

        "pvf.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = ''
            reverse_proxy https://192.168.86.13:8006 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';
        };

        "opnsense.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          # NOTE: Pinned to HTTP/1.1 so caddy doesn't switch to QUIC,
          #       which is rejected by opnsense
          extraConfig = ''
            reverse_proxy https://192.168.86.5:443 {
              transport http {
                versions 1.1
                tls_insecure_skip_verify
              }
            }
          '';
        };

        # Everything else that lives on servenix. Thinknix only terminates TLS
        # and forwards to servenix's Caddy, which does the actual routing.
        "*.local.chriphost.gay" = {
          useACMEHost = "local.chriphost.gay";
          extraConfig = "reverse_proxy http://192.168.86.25:9080";
        };

        "http://hass.vps.chriphost.gay" = {
          extraConfig = "reverse_proxy http://192.168.86.55:8123";
        };

        # Plain-HTTP side. Defining a site on :80 disables Caddy's automatic
        # HTTP→HTTPS redirects, so the redirect for the LAN names is repeated
        # here. Everything else gets a clear 404 — otherwise a public name that
        # the VPS forwards but that has no vhost here would bounce between
        # VPS:443 and this :80 forever.
        ":80" = {
          extraConfig = ''
            @local host *.local.chriphost.gay
            redir @local https://{host}{uri} 308

            respond "no vhost for this host" 404
          '';
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
