# TODO: Need some kind of menu generator API that is integrated with hyprland hotkeys
#       VPN and Container modules should use this rofi module to enable their menus then
{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.rofi;
in {
  options.modules.rofi = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rofi-wayland

      # Power Menu
      (mylib.rofi.mkSimpleMenu
        "power"
        {
          "Poweroff" = "poweroff";
          "Reboot" = "reboot";
          "Reload Hyprland" = "hyprctl reload";
          "Exit Hyprland" = "hyprctl dispatch exit";
        })
    ];

    home.activation = {
      # NOTE: Keep the rofi config symlinked, to allow easy changes with hotreload
      linkRofiConfig =
        hm.dag.entryAfter ["writeBoundary"]
        (mkLink "~/NixFlake/config/rofi/rofi.rasi" "~/.config/rofi/config.rasi");
      linkRofiColors =
        hm.dag.entryAfter ["writeBoundary"]
        (mkLink "~/NixFlake/config/rofi/colors/${cfg.theme}.rasi" "~/.config/rofi/colors.rasi");
    };
  };
}
