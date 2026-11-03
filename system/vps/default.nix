{
  config,
  lib,
  hostname,
  ...
}: {
  imports = [
    ./disks.nix
    ../services/nixos/gatus.nix
  ];

  # 1 vCPU, 1 GB RAM, 10 GB disk, so we keep a minimal config
  system.stateVersion = "26.11";

  systemmodules = {
    bootloader = {
      enable = true;

      # The VM boots via UEFI (Secure Boot is off) and disko mounts the ESP at
      # /boot, which is also the module's default efiSysMountPoint.
      loader = "systemd-boot";
    };

    docker.enable = lib.mkForce false;

    # Build on nixinator and pull from its binary cache.
    remote-build.enable = true;

    network = {
      inherit hostname;

      # IPv4 comes from DHCP (2.31.177.253/32 via the private gateway
      # 172.31.1.1), IPv6 is static /64 with the link-local gateway.
      networks."10-eth0" = {
        enable = true;

        matchConfig.Name = "eth0";

        address = ["2a01:4f8:1c16:4ad1::1/64"];
        routes = [
          {
            Gateway = "fe80::1";
            # Hetzner's own netplan marks this route "on-link"
            GatewayOnLink = true;
          }
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
      # nixinator is no longer streamed, it is reached through this host's
      # sshd with ProxyJump now, so fail2ban sees the real client addresses.
      allowedTCPPorts = lib.mkForce [222];
      allowedUDPPorts = lib.mkForce [51820];
    };

    caddy = {
      enable = true;

      httpPort = 80;
      httpsPort = 443;
      autoHttps = true;

      # *.vps.chriphost.gay is a wildcard, so it has to be issued via DNS-01
      dnsProvider = "hetzner";
      acmeDomain = "*.vps.chriphost.gay";
      acmeCertName = "vps.chriphost.gay";

      openFirewall = true;
    };
  };

  # The wildcard does not cover the apex, so add it as an extra SAN instead of
  # serving a certificate without a matching name on https://vps.chriphost.gay.
  security.acme.certs."vps.chriphost.gay".extraDomainNames = ["vps.chriphost.gay"];

  # The Ubuntu image renamed the NIC to eth0 via netplan. On NixOS the kernel
  # name would be enp1s0/ens3 depending on the PCI slot, so pin it by MAC.
  # NOTE: the MAC changes if the server is ever deleted and recreated.
  systemd.network.links."10-wan" = {
    matchConfig.MACAddress = "92:00:0a:63:76:7a";
    linkConfig.Name = "eth0";
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
    externalInterface = "eth0";
    internalInterfaces = ["wg0"];
  };

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
    '';
  };

  # Thinknix terminates TLS for *.local.chriphost.gay, VPS terminates TLS
  # for *.vps.chriphost.gay
  services.caddy.virtualHosts = let
    upstream = "reverse_proxy http://192.168.86.26:80";
  in {
    "vps.chriphost.gay" = {
      useACMEHost = "vps.chriphost.gay";
      extraConfig = "redir https://status.vps.chriphost.gay{uri} 302";
    };

    # Browsers often autocomplete the apex to www.; the wildcard would
    # otherwise forward it to thinknix, which has no vhost for it.
    "www.vps.chriphost.gay" = {
      useACMEHost = "vps.chriphost.gay";
      extraConfig = "redir https://status.vps.chriphost.gay{uri} 302";
    };

    "*.vps.chriphost.gay" = {
      useACMEHost = "vps.chriphost.gay";
      extraConfig = upstream;
    };

    # External watchdog. More specific than the wildcard above, so it is
    # served locally instead of being forwarded to thinknix.
    "status.vps.chriphost.gay" = {
      useACMEHost = "vps.chriphost.gay";
      extraConfig = "reverse_proxy 127.0.0.1:8080";
    };
  };

  # Hardware limitations
  nix.settings = {
    max-jobs = 1;
    cores = 1;
  };

  zramSwap.enable = true;

  # The VM has no GPU/serial console; keep the default kernel.
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_net"
    "virtio_scsi"
    "sd_mod"
    "ata_piix"
  ];
}
