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
  inherit (config.modules) rofi color;
in {
  options.modules.rofi = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf rofi.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      terminal = "kitty";
      font = "${color.font} 14";
      location = "center";
      cycle = true;

      extraConfig = {
        modi = "run,drun,ssh,filebrowser";
        show-icons = true;
        icon-theme = "Papirus";
        drun-display-format = "{icon} {name}";
        disable-history = false;
        hide-scrollbar = true;
        display-drun = " apps ";
        display-run = " run ";
        display-filebrowser = " file ";
        display-ssh = " ssh ";
        sidebar-mode = false;
      };

      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
          bg = mkLiteral "rgba(${color.rgbString.light.base}, 0.3)";
          hl = mkLiteral "#${color.hex.dark.lavender}";
          hl-pink = mkLiteral "#${color.hex.dark.pink}";
          text = mkLiteral "#${color.hex.dark.base}";
          trans = mkLiteral "rgba(0, 0, 0, 0)";
        };

        "element-text,element-icon,mode-switcher" = {
          background-color = mkLiteral "inherit";
          text-color = mkLiteral "inherit";
        };

        "window" = {
          height = 480;
          width = 700;
          border = mkLiteral "2 solid 2 solid 2 solid 2 solid";
          border-radius = 6;
          border-color = mkLiteral "@hl";
          background-color = mkLiteral "@bg";
        };

        "mainbox" = {
          background-color = mkLiteral "@trans";
        };

        "message" = {
          background-color = mkLiteral "@trans";
        };

        "error-message" = {
          background-color = mkLiteral "@trans";
          margin = mkLiteral "0px 0px 20px 0px";
        };

        "textbox" = {
          background-color = mkLiteral "@trans";
          padding = 6;
          margin = mkLiteral "20px 20px 0px 20px";
          border-radius = 3;
        };

        "inputbar" = {
          children = builtins.map mkLiteral ["prompt" "entry"];
          background-color = mkLiteral "@trans";
        };

        "prompt" = {
          background-color = mkLiteral "@hl-pink";
          padding = 6;
          text-color = mkLiteral "@text";
          border-radius = 3;
          margin = mkLiteral "20px 0px 0px 20px";
        };

        "entry" = {
          padding = 6;
          margin = mkLiteral "20px 20px 0px 10px";
          text-color = mkLiteral "@text";
          background-color = mkLiteral "@trans";
          border = mkLiteral "2 solid 2 solid 2 solid 2 solid";
          border-radius = 3;
          border-color = mkLiteral "@hl-pink";
        };

        "listview" = {
          # border = mkLiteral "0px 0px 0px";
          padding = 0;
          margin = mkLiteral "10px 20px 20px 20px";
          columns = 1;
          background-color = mkLiteral "@trans";
          border = mkLiteral "2 solid 2 solid 2 solid 2 solid";
          border-radius = 3;
          border-color = mkLiteral "@hl-pink";
        };

        "element" = {
          padding = 5;
          margin = 0;
          background-color = mkLiteral "@trans";
          text-color = mkLiteral "@text";
          # border-radius = 3;
        };

        "element-icon" = {
          size = 25;
        };

        "element selected" = {
          background-color = mkLiteral "@hl-pink";
          text-color = mkLiteral "@text";
        };
      };
    };

    modules.hyprland.keybindings = let
      power-menu =
        mylib.rofi.mkSimpleMenu
        "power"
        {
          "Poweroff" = "poweroff";
          "Reboot" = "reboot";
          "Lock" = "loginctl lock-session";
          "Reload Hyprpanel" = "systemctl --user restart hyprpanel.service";
          "Reload Hyprland" = "hyprctl reload";
          "Exit Hyprland" = "hyprctl dispatch exit";
        };

      vpn-menu = pkgs.writeScript "rofi-menu-vpn" (builtins.readFile ./menus/vpn.fish);
      keybinds-menu = pkgs.writeScript "rofi-menu-keybinds" (builtins.readFile ./menus/keybinds.fish);
      lectures-menu = pkgs.writeScript "rofi-menu-lectures" (builtins.readFile ./menus/lectures.fish);
    in {
      bindings = lib.mergeAttrsList [
        {
          "$mainMod, escape" = ["exec, \"${power-menu}\""];
          "$mainMod, M" = ["exec, \"${keybinds-menu}\""];
          # "$mainMod, O" = ["exec, \"${lectures-menu}\""];
        }
        (lib.optionalAttrs (!nixosConfig.modules.network.useNetworkManager) {
          "$mainMod, U" = ["exec, \"${vpn-menu}\""];
        })
      ];
    };
  };
}
