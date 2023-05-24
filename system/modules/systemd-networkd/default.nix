{
  inputs,
  config,
  lib,
  mylib,
  pkgs,
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
      networks = cfg.networks;
    };

    # Wireguard VPNs
    systemd.services = cfg.wireguard-tunnels;

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

      # TODO: Either IWD or WiFi through systemd-networkd
      wireless = {
        enable = false; # Enables wireless support via wpa_supplicant.
        iwd.enable = false; # Use iwd instead of NetworkManager
      };

      # Open Ports
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
