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

        kb-layout = "de";
        kb-variant = "nodeadkeys";
        
        monitors = ''
          # See https://wiki.hyprland.org/Configuring/Monitors/
          monitor = eDP-1, 1920x1080@60, 0x0, 1

          # I have the first 9 workspaces on the main monitor, the last one on the secondary monitor
          wsbind = 1, eDP-1
          wsbind = 2, eDP-1
          wsbind = 3, eDP-1
          wsbind = 4, eDP-1
          wsbind = 5, eDP-1
          wsbind = 6, eDP-1
          wsbind = 7, eDP-1
          wsbind = 8, eDP-1
          wsbind = 9, eDP-1
        '';
      };
    };

    home.packages = with pkgs; [
    ];
  };
}
