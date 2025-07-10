# TODO: OpenVPN
{
  inputs,
  pkgs,
  lib,
  ...
}: rec {
  mkSystemdNetwork = interface: routable: {
    # name = "enp0s31f6"; # Network interface name?
    enable = true;

    # See man systemd.link, man systemd.netdev, man systemd.network
    matchConfig = {
      # This corresponds to the [MATCH] section
      Name = interface; # Match ethernet interface
    };

    # See man systemd.network
    networkConfig = {
      # This corresponds to the [NETWORK] section
      DHCP = "yes";

      # TODO: What does this all do?
      # IPv6AcceptRA = true;
      # MulticastDNS = "yes"; # Needed?
      # LLMNR = "no"; # Needed?
      # LinkLocalAddressing = "no"; # Needed?
    };

    linkConfig = {
      # This corresponds to the [LINK] section
      # RequiredForOnline = "routable";
      RequiredForOnline =
        if routable
        then "routable"
        else "no"; # Don't make nixos-rebuild wait for systemd-networkd-wait-online.service
    };
  };

  mkStaticSystemdNetwork = {
    interface,
    ips,
    routers,
    nameservers,
    routable,
  }: {
    enable = true;

    # See man systemd.link, man systemd.netdev, man systemd.network
    matchConfig = {
      # This corresponds to the [MATCH] section
      Name = interface; # Match ethernet interface
    };

    # Static IP + DNS + Gateway
    address = ips;
    gateway = routers;
    dns = nameservers;
    routes = builtins.map (r: {Gateway = r;}) routers;

    # See man systemd.network
    networkConfig = {
      # This corresponds to the [NETWORK] section
      DHCP = "no";

      # IPv6AcceptRA = "no";
      # MulticastDNS = "no";
      # LLMNR = "no";
      # LinkLocalAddressing = "ipv6";
    };

    linkConfig = {
      # This corresponds to the [LINK] section
      # RequiredForOnline = "routable";
      RequiredForOnline =
        if routable
        then "routable"
        else "no"; # Don't make nixos-rebuild wait for systemd-networkd-wait-online.service
    };
  };

  # TODO: What other config options are there?
  mkStaticNetworkManagerProfile = {
    id,
    interface,
    ip,
    router,
    nameserver,
    autoconnect,
  }: {
    connection = {
      inherit id autoconnect;
      type = "ethernet";
      interface-name = interface;
    };

    ipv4 = {
      method = "manual";
      addresses = ip;
      gateway = router;
      dns = nameserver;
    };
  };
}
