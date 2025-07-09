{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.adguard = {
    image = "adguard/adguardhome";
    autoStart = true;

    dependsOn = [];

    ports = [
      # DNS server
      "53:53/tcp"
      "53:53/udp"
      # "853:853/tcp" # DNS over TLS
      # "853:853/udp" # DNS over QUIC

      # DHCP server
      # "67:67/udp"
      # "68:68/tcp"
      # "68:68/udp"

      # Admin panel + DNS over HTTPS
      # "80:80/tcp"
      # "443:443/tcp"
      # "443:443/udp"
      # "3100:3000/tcp" # Web interface

      # DNSCrypt
      # "5443:5443/tcp"
      # "5443:5443/udp"

      # "6060:6060/tcp" # Debugging
    ];

    volumes = [
      "adguard_config:/opt/adguardhome/conf"
      "adguard_work:/opt/adguardhome/work"
    ];

    environment = {};

    extraOptions = [
      "--net=behind-nginx"
    ];
  };
}
