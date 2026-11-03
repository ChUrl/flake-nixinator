{
  config,
  lib,
  hostname,
  ...
}: {
  imports = [
    ./disks.nix
  ];

  # 1 vCPU, 1 GB RAM, 10 GB disk, so we keep a minimal config
  system.stateVersion = "26.11";

  systemmodules = {
    bootloader = {
      enable = true;

      # BIOS: disko generates `boot.loader.grub.devices = ["/dev/vda"]`
      # and nixpkgs takes the same entry from `grub.device`, which would result
      # in a duplicated grub device -> leave `device` empty (disko decides)
      loader = "grub";
      grub.bootDevice = lib.mkForce "";
    };

    docker.enable = lib.mkForce false;

    # Build on nixinator and pull from its binary cache.
    remote-build.enable = true;

    network = {
      inherit hostname;

      # IPv4 comes from DHCP (IONOS keeps the address for the VM's MAC),
      # IPv6 is static with a link-local gateway.
      networks."10-ens6" = {
        enable = true;

        matchConfig.Name = "ens6";

        address = ["2a02:2479:6b:b400::1/80"];
        routes = [
          {Gateway = "fe80::1";}
        ];

        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = false;
          DNS = ["8.8.8.8" "8.8.4.4"];
        };

        linkConfig.RequiredForOnline = "routable";
      };

      # 22 is opened by the ssh module, 80/443 by the caddy module,
      # 222 is the HAProxy gitea stream, 51820/udp is WireGuard.
      # 5432 is not listed here, because it is accepted in extraInputRules below
      allowedTCPPorts = lib.mkForce [222];
      allowedUDPPorts = lib.mkForce [51820];
    };

    caddy = {
      enable = true;

      httpPort = 80;
      httpsPort = 443;
      autoHttps = true;

      # *.vps.chriphost.de is a wildcard, so it has to be issued via DNS-01
      dnsProvider = "ionos";
      acmeDomain = "*.vps.chriphost.de";
      acmeCertName = "vps.chriphost.de";

      openFirewall = true;
    };
  };

  sops.secrets."wireguard-vps-private-key" = {};

  networking.wireguard.interfaces.wg0 = {
    ips = ["10.10.10.1/24"];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets."wireguard-vps-private-key".path;

    peers = [
      {
        # OPNsense: default route into the LAN for the public vhosts
        publicKey = "bsvabi6V4XZx7ZS/53Tai0s1n0Tf/6KRvMn+9yNnymY=";
        allowedIPs = [
          "10.10.10.2/32"
          "192.168.86.0/24"
        ];
      }
      {
        # iPhone
        publicKey = "qcJPgz/N3y+QMac5kfLKDgouIcWnLD+uPpe4JTEB4G0=";
        allowedIPs = ["10.10.10.3/32"];
      }
    ];
  };

  # Peers route their internet traffic through WireGuard
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.nat = {
    enable = true;
    externalInterface = "ens6";
    internalInterfaces = ["wg0"];
  };

  # The public 5432 stream is an SSH proxy to nixinator, so every external
  # client arrives as 10.10.10.1 -> per-IP banning has to happen here, where
  # the source addresses are still visible
  networking.firewall.extraInputRules = ''
    # Drop before accepting: extraInputRules are appended at the end of the
    # input-allow chain, so the accept has to live here as well.
    iifname "ens6" tcp dport 5432 ct state new \
      meter ssh_stream { ip saddr limit rate over 12/minute } drop
    iifname "ens6" tcp dport 5432 accept
  '';

  services.haproxy = {
    enable = true;

    config = ''
      global
        log stdout format raw local0
        maxconn 200

      defaults
        mode tcp
        log global
        timeout connect 5s
        timeout client  1h
        timeout server  1h

      # Gitea SSH
      frontend fe_gitea_ssh
        bind :222
        default_backend gitea_ssh

      backend gitea_ssh
        server servenix 192.168.86.25:222 check

      # nixinator SSH
      frontend fe_nixinator_ssh
        bind :5432
        default_backend nixinator_ssh

      backend nixinator_ssh
        server nixinator 192.168.86.50:5432 check
    '';
  };

  # Thinknix terminates TLS for *.local.chriphost.de, VPS terminates TLS
  # for *.vps.chriphost.de
  services.caddy.virtualHosts = let
    upstream = "reverse_proxy http://192.168.86.26:80";
  in
    {
      "vps.chriphost.de" = {
        useACMEHost = "vps.chriphost.de";
        extraConfig = upstream;
      };

      "*.vps.chriphost.de" = {
        useACMEHost = "vps.chriphost.de";
        extraConfig = upstream;
      };
    }
    // lib.genAttrs
    [
      # chriphost.gay is delegated to INWX, so no DNS-01 in the IONOS account:
      # Caddy issues these individually via HTTP-01.
      "f11.vps.chriphost.gay"
      "f12.vps.chriphost.gay"
      "jellyfin.vps.chriphost.gay"
    ]
    (_: {extraConfig = upstream;});

  # Hardware limitations
  nix.settings = {
    max-jobs = 1;
    cores = 1;
  };

  zramSwap.enable = true;

  # The VM has no GPU/serial console; keep the default kernel.
  # /boot is only 512M: keep three generations of kernel+initrd
  boot.loader.grub.configurationLimit = 3;

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_net"
    "virtio_scsi"
    "sd_mod"
    "ata_piix"
  ];
}
