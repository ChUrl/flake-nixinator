# TODO: Setup Wireless (IWD/Networkd?)
{
  config,
  lib,
  mylib,
  ...
}:
with lib;
with mylib.networking;
with mylib.modules; let
  cfg = config.modules.systemd-networkd;
in {
  options.modules.systemd-networkd = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    services.resolved.enable = true;
    services.resolved.llmnr = "false";

    # Main Networks
    systemd.network = {
      enable = true;
      wait-online.timeout = 10;

      # Don't wait for all networks to be configured, as e.g. wg0 will only be upon manual activation
      wait-online.anyInterface = true;

      # TODO: Apparently anyInterface doesn't work?
      # wait-online.ignoredInterfaces = [
      #   "wg0"
      #   "wlp7s0"
      #   "enp5s0"
      # ];

      networks = cfg.networks;
    };

    # Wireguard VPNs
    systemd.services = cfg.wireguard-tunnels;

    # NOTE: I can connect to TU Dortmund directly
    # TODO: Use config with netns, like with wireguard
    # services.openvpn.servers = {
    #   # TODO: Can't read config file...
    #   tu-dortmund-irb = {
    #     autoStart = false;
    #     config = "config ~/NixFlake/config/openvpn/tu-dortmund-irb.ovpn";
    #   };
    # };

    # TODO: Rewrite with lib.pipe
    # Generate list of vpns for rofi menu
    environment.etc."rofi-vpns".text = let
      names-list = attrNames cfg.wireguard-tunnels;
      names = concatStringsSep "\n" names-list;
    in
      names;

    # Allow to enable/disable tunnels without root password
    modules.polkit.allowed-system-services = let
      vpn-services = lib.pipe cfg.wireguard-tunnels [
        attrNames
        (map (v: "${v}.service"))
      ];
    in
      vpn-services;

    # General Networking Settings
    networking = {
      # Gets inherited from flake in nixos mylib and passed through the module option
      hostName = cfg.hostname; # Define your hostname.
      enableIPv6 = true;

      # Disable a lot of stuff not needed for systemd-networkd
      networkmanager.enable = false;
      useDHCP = false; # Default: true, don't use with networkd
      dhcpcd.enable = false; # Don't use with networkd
      useNetworkd = false; # Only use this if the configuration can't be written in systemd.network completely. It translates some of the networking... options to systemd
      # resolvconf.enable = true;

      # TODO
      wireless = {
        enable = false; # Enables wireless support via wpa_supplicant.
        iwd.enable = false; # Use iwd instead of NetworkManager
      };

      # Open Ports
      nftables.enable = true;
      firewall = {
        enable = true;
        # networking.firewall.checkReversePath = "loose";

        trustedInterfaces = [
          "podman0"
          "docker0"
        ];

        allowedTCPPorts = cfg.allowedTCPPorts;
        # allowedTCPPortRanges = [];

        allowedUDPPorts = cfg.allowedUDPPorts;
        # allowedUDPPortRanges = [];
      };
    };
  };
}
