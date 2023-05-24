{
  inputs,
  pkgs,
  lib,
  ...
}: rec {
  mkSystemdNetwork = interface: {
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
    };
  };

  # VPN stuff
  mkNetworkNamespace = name: ''
    ${pkgs.iproute}/bin/ip netns add ${name} # Create the Namespace
    ${pkgs.iproute}/bin/ip -n ${name} link set lo up # Enable the Loopback device
  '';

  killNetworkNamespace = name: ''
    ${pkgs.iproute}/bin/ip netns del ${name} # Delete the Namespace
  '';

  # TODO: IPv6 Configuration
  # NOTE: The interface and netns have the same name, so it's a bit confusing
  mkWireguardTunnel = name: privatekey: publickey: endpoint: ''
    ${pkgs.iproute}/bin/ip link add ${name} type wireguard
    ${pkgs.iproute}/bin/ip link set ${name} netns ${name}
    ${pkgs.iproute}/bin/ip netns exec ${name} ${pkgs.wireguard-tools}/bin/wg set ${name} \
      private-key /home/christoph/.secrets/wireguard/${privatekey} \
      peer ${publickey} \
      allowed-ips 0.0.0.0/0 \
      endpoint ${endpoint}:51820
    ${pkgs.iproute}/bin/ip -n ${name} addr add 10.2.0.2/32 dev ${name}
    ${pkgs.iproute}/bin/ip -n ${name} link set ${name} up
    ${pkgs.iproute}/bin/ip -n ${name} route add default dev ${name}
  '';

  killWireguardTunnel = name: ''
    ${pkgs.iproute}/bin/ip -n ${name} link del ${name}
  '';

  mkWireguardService = name: privatekey: publickey: endpoint: {
    description = "Wireguard ProtonVPN Server ${name}";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeScript "${name}-up" ''
        #! ${pkgs.bash}/bin/bash
        ${mkNetworkNamespace "${name}"}
        ${mkWireguardTunnel "${name}" "${privatekey}" "${publickey}" "${endpoint}"}
      '';
      ExecStop = pkgs.writeScript "wg0-de-115-down" ''
        #! ${pkgs.bash}/bin/bash
        ${killWireguardTunnel "${name}"}
        ${killNetworkNamespace "${name}"}
      '';
    };
  };

  # mkOpenVPNTunnel = "";
  # killOpenVPNTunnel = "";
}
