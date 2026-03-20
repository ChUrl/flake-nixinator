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
  inherit (config.homemodules) rofi color;
in {
  options.homemodules.rofi = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf rofi.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      terminal = "kitty";
      font = "${color.font} 14";
      location = "center";
      cycle = true;

      extraConfig = {
        modi = "run,drun,ssh,filebrowser";
        show-icons = true;
        icon-theme = color.iconTheme;
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
        mkLiteral = config.lib.formats.rasi.mkLiteral;
      in
        import ./theme.nix {inherit color mkLiteral;};
    };

    # homemodules.hyprland.keybindings = let
    #   vpn-menu =
    #     pkgs.writeScriptBin
    #     "rofi-menu-vpn"
    #     (builtins.readFile ./menus/vpn.fish);
    #
    #   keybinds-menu =
    #     pkgs.writeScriptBin
    #     "rofi-menu-keybinds"
    #     (builtins.readFile ./menus/keybinds.fish);
    #
    #   lectures-menu =
    #     pkgs.writeScriptBin
    #     "rofi-menu-lectures"
    #     (builtins.readFile ./menus/lectures.fish);
    #
    #   power-menu =
    #     mylib.rofi.mkSimpleMenu
    #     "power"
    #     {
    #       "󰤂 Poweroff" = "poweroff";
    #       "󰜉 Reboot" = "reboot";
    #       "󰌾 Lock" = "loginctl lock-session";
    #       " Reload Hyprpanel" = "systemctl --user restart hyprpanel.service";
    #       " Reload Hyprland" = "hyprctl reload";
    #       " Exit Hyprland" = "hyprctl dispatch exit";
    #     };
    #
    #   wallpaper-menu = let
    #     setWallpaperOnMonitor = name: monitor:
    #       "hyprctl hyprpaper wallpaper "
    #       + "${monitor},${config.paths.nixflake}/wallpapers/${name}.jpg";
    #
    #     setWallpaperOnMonitors = monitors: name: {
    #       ${name} =
    #         monitors
    #         |> builtins.map (setWallpaperOnMonitor name)
    #         |> builtins.concatStringsSep " && ";
    #     };
    #
    #     monitors = builtins.attrNames config.homemodules.hyprland.monitors;
    #   in
    #     mylib.rofi.mkSimpleMenu
    #     "wall"
    #     (color.wallpapers
    #       |> builtins.map (setWallpaperOnMonitors monitors)
    #       |> lib.mergeAttrsList);
    # in
    #   lib.mkIf (!config.homemodules.hyprland.caelestia.enable) {
    #     bindings = lib.mergeAttrsList [
    #       {
    #         "$mainMod, escape" = ["exec, \"${power-menu}/bin/rofi-menu-power\""];
    #         "$mainMod, m" = ["exec, \"${keybinds-menu}/bin/rofi-menu-keybinds\""];
    #         "$mainMod, w" = ["exec, \"${wallpaper-menu}/bin/rofi-menu-wall\""];
    #         # "$mainMod, o" = ["exec, \"${lectures-menu}\""];
    #       }
    #       (lib.optionalAttrs (!nixosConfig.systemmodules.network.useNetworkManager) {
    #         "$mainMod, U" = ["exec, \"${vpn-menu}/rofi-menu-vpn\""];
    #       })
    #     ];
    #   };
  };
}
