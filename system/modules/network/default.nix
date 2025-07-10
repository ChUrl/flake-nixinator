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
  cfg = config.modules.network;
in {
  options.modules.network = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    services.resolved.enable = true;
    services.resolved.llmnr = "false";

    # Use the programs.nm-applet instead
    # environment.systemPackages = with pkgs;
    #   builtins.concatLists [
    #     []
    #     (lib.optionals cfg.useNetworkManager [networkmanagerapplet]) # This is started by hyprland if enabled
    #   ];

    programs.nm-applet.enable = cfg.useNetworkManager;

    # Main Networks
    systemd.network = {
      enable = !cfg.useNetworkManager;
      wait-online.timeout = 10;

      # Don't wait for all networks to be configured, as e.g. wg0 will only be upon manual activation
      wait-online.anyInterface = true;

      # TODO: Apparently anyInterface doesn't work?
      # wait-online.ignoredInterfaces = [
      #   "wg0"
      #   "wlp7s0"
      #   "enp5s0"
      # ];

      # networks = cfg.networks;
      inherit (cfg) networks;
    };

    modules.polkit.allowedActions = mkIf cfg.useNetworkManager [
      # List NM permissions by running "nmcli general permissions"
      "org.freedesktop.NetworkManager.settings.modify.system"
    ];

    # General Networking Settings
    networking = {
      # Gets inherited from flake in nixos mylib and passed through the module option
      hostName = cfg.hostname; # Define your hostname.
      enableIPv6 = false;

      # Disable a lot of stuff not needed for systemd-networkd
      networkmanager = {
        enable = cfg.useNetworkManager;
        ensureProfiles.profiles = cfg.profiles;

        insertNameservers = [
          "192.168.86.26"
          "8.8.8.8"
        ];

        wifi = {
          backend = "iwd";
        };
      };

      useDHCP = false; # Default: true, don't use with networkd
      dhcpcd.enable = false; # Don't use with networkd
      useNetworkd = false; # Only use this if the configuration can't be written in systemd.network completely. It translates some of the networking... options to systemd
      # resolvconf.enable = true;

      wireless = {
        enable = false; # Enables wireless support via wpa_supplicant.
        iwd.enable = true; # Use iwd instead of wpa_supplicant
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

        # allowedTCPPorts = cfg.allowedTCPPorts;
        # allowedTCPPortRanges = [];
        # allowedUDPPorts = cfg.allowedUDPPorts;
        # allowedUDPPortRanges = [];
        inherit (cfg) allowedTCPPorts allowedUDPPorts;
      };
    };
  };
}
