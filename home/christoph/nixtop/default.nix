{
  inputs,
  hostname,
  username,
  lib,
  mylib,
  config,
  nixosConfig,
  pkgs,
  ...
}:
# Here goes the stuff that will only be enabled on the laptop
rec {
  imports = [
    ../../modules
  ];

  config = {
    modules = {
      hyprland = {
        enable = true;
        theme = "Three-Bears";

        # kb-layout = "de";
        # kb-variant = "nodeadkeys";

        kb-layout = "us";
        kb-variant = "altgr-intl";

        monitors = ''
          # See https://wiki.hyprland.org/Configuring/Monitors/
          monitor = eDP-1, 1920x1080@60, 0x0, 1

          # I have the first 9 workspaces on the main monitor, the last one on the secondary monitor
          workspace = 1, monitor:eDP-1
          workspace = 2, monitor:eDP-1
          workspace = 3, monitor:eDP-1
          workspace = 4, monitor:eDP-1
          workspace = 5, monitor:eDP-1
          workspace = 6, monitor:eDP-1
          workspace = 7, monitor:eDP-1
          workspace = 8, monitor:eDP-1
          workspace = 9, monitor:eDP-1
        '';
      };
    };

    home.packages = with pkgs; [
    ];
  };
}
