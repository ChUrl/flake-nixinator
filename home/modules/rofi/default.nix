# TODO: Need some kind of menu generator API that is integrated with hyprland hotkeys
#       VPN and Container modules should use this rofi module to enable their menus then
{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  cfg = config.modules.rofi;
in {
  options.modules.rofi = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi-wayland
    ];

    modules.hyprland.keybindings = let
      power-menu =
        mylib.rofi.mkSimpleMenu
        "power"
        {
          "Poweroff" = "poweroff";
          "Reboot" = "reboot";
          "Reload Hyprland" = "hyprctl reload";
          "Exit Hyprland" = "hyprctl dispatch exit";
        };
    in {
      bindings = {
        "$mainMod, escape" = ["exec, \"${power-menu}\""];
      };
    };

    home.file = {
      ".config/rofi/config.rasi".source = ../../../config/rofi/rofi.rasi;
      ".config/rofi/colors.rasi".source = ../../../config/rofi/colors/${cfg.theme}.rasi;
    };
  };
}
