# TODO: Need some kind of menu generator API that is integrated with hyprland hotkeys
#       VPN and Container modules should use this rofi module to enable their menus then
{
  config,
  nixosConfig,
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
        "$mainMod, A" = ["exec, rofi -drun-show-actions -show drun"];
        "$mainMod, escape" = ["exec, \"${power-menu}\""];
      };
    };

    home.activation = {
      # NOTE: Keep the rofi config symlinked, to allow easy changes with hotreload
      linkRofiConfig =
        lib.hm.dag.entryAfter ["writeBoundary"]
        (mylib.modules.mkLink "~/NixFlake/config/rofi/rofi.rasi" "~/.config/rofi/config.rasi");
      linkRofiColors =
        lib.hm.dag.entryAfter ["writeBoundary"]
        (mylib.modules.mkLink "~/NixFlake/config/rofi/colors/${cfg.theme}.rasi" "~/.config/rofi/colors.rasi");
    };
  };
}
