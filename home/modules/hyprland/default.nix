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
  cfg = config.modules.hyprland;
in {
  options.modules.hyprland = import ./options.nix {inherit lib mylib;};

  config = let
    # Taken from https://github.com/Ruixi-rebirth/flakes/blob/main/modules/programs/wayland/waybar/workspace-patch.nix
    hyprctl = "${pkgs.hyprland}/bin/hyprctl";
    workspaces-patch = pkgs.writeTextFile {
      name = "waybar-hyprctl.diff";
      text = ''
        diff --git a/src/modules/wlr/workspace_manager.cpp b/src/modules/wlr/workspace_manager.cpp
        index 6a496e6..a689be0 100644
        --- a/src/modules/wlr/workspace_manager.cpp
        +++ b/src/modules/wlr/workspace_manager.cpp
        @@ -511,7 +511,9 @@ auto Workspace::handle_clicked(GdkEventButton *bt) -> bool {
           if (action.empty())
             return true;
           else if (action == "activate") {
        -    zext_workspace_handle_v1_activate(workspace_handle_);
        +    // zext_workspace_handle_v1_activate(workspace_handle_);
        +    const std::string command = "${hyprctl} dispatch workspace " + name_;
        +    system(command.c_str());
           } else if (action == "close") {
             zext_workspace_handle_v1_remove(workspace_handle_);
           } else {
      '';
    };

    waybar-hyprland = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      patches = (oldAttrs.patches or []) ++ [workspaces-patch];
    });
  in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = nixosConfig.programs.hyprland.enable;
          message = "Can't enable Hyprland module with Hyprland disabled!";
        }
      ];

      gtk = {
        enable = true;
        iconTheme.package = pkgs.papirus-icon-theme;
        iconTheme.name = "Papirus";
      };

      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };

      home.sessionVariables = {
        # QT_QPA_PLATFORMTHEME = "qt5ct";
      };

      # Polkit
      home.file.".config/hypr/polkit.conf".text = ''exec-once = ${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1'';

      # Monitors for different systems
      home.file.".config/hypr/monitors.conf".text = cfg.monitors;

      # Keyboard layout
      home.file.".config/hypr/input.conf".text = ''
        input {
            kb_layout = ${cfg.kb-layout}
            kb_variant = ${cfg.kb-variant}
            kb_model = pc104
            kb_options =
            kb_rules =

            follow_mouse = 1

            touchpad {
                natural_scroll = no
            }

            sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
        }
      '';

      home.file.".config/hypr/waybar-reload.conf".text = let
        waybar-reload = pkgs.writeScript "waybar-reload" ''
          #! ${pkgs.bash}/bin/bash

          trap "${pkgs.procps}/bin/pkill waybar" EXIT

          while true; do
              ${waybar-hyprland}/bin/waybar -c $HOME/NixFlake/config/waybar/config -s $HOME/NixFlake/config/waybar/style.css &
              ${pkgs.inotifyTools}/bin/inotifywait -e create,modify $HOME/NixFlake/config/waybar/config $HOME/NixFlake/config/waybar/style.css
              ${pkgs.procps}/bin/pkill waybar
          done
        '';
      in ''
        exec-once = ${waybar-reload}
      '';

      home.file.".config/hypr/hyprpaper.conf".text = ''
        preload = ~/NixFlake/wallpapers/${cfg.theme}.png
        wallpaper = HDMI-A-1, ~/NixFlake/wallpapers/${cfg.theme}.png
        wallpaper = HDMI-A-2, ~/NixFlake/wallpapers/${cfg.theme}.png
      '';

      home.activation = {
        # NOTE: Keep the hyprland/waybar config symlinked, to allow easy changes with hotreload
        # TODO: Don't symlink at all, why not just tell Hyprland where the config is? Much easier
        # TODO: Use this approach for every program that supports it, makes things much easier,
        #       as everything can just stay in ~/NixFlake/config
        linkHyprlandConfig =
          hm.dag.entryAfter ["writeBoundary"]
          (mkLink "~/NixFlake/config/hyprland/hyprland.conf" "~/.config/hypr/hyprland.conf");

        # linkWaybarConfig = hm.dag.entryAfter ["writeBoundary"]
        #                    (mkLink "~/NixFlake/config/waybar/config" "~/.config/waybar/config");
        # linkWaybarStyle = hm.dag.entryAfter ["writeBoundary"]
        #                   (mkLink "~/NixFlake/config/waybar/style.css" "~/.config/waybar/style.css");
        # linkWaybarColors = hm.dag.entryAfter ["writeBoundary"]
        #                    (mkLink "~/NixFlake/config/waybar/colors" "~/.config/waybar/colors");
      };

      home.packages = with pkgs; [
        hyprpaper # Wallpaper setter
        hyprpicker # Color picker

        wl-clipboard
        clipman # Clipboard manager (wl-paste)

        imv # Image viewer
        moc # Audio player
        ncpamixer # ncurses pavucontrol
        slurp # Region selector for screensharing
        grim # Grab images from compositor

        xfce.thunar
        xfce.tumbler # Thunar thumbnails
        libsForQt5.polkit-kde-agent
      ];

      services = {
        # Notification service
        dunst = {
          enable = true;
        };
      };

      programs = {
        rofi = {
          enable = true;
          package = pkgs.rofi-wayland;
          plugins = [
            pkgs.keepmenu # TODO: Rofi KeepassXC frontend
          ];

          # NOTE: Don't use this, use the configfile for hot-reload
          # terminal = "${pkgs.kitty}/bin/kitty";
          # font = "JetBrains Mono 14";
          # theme =
          # extraConfig = '''';
        };

        waybar = {
          enable = true;
          package = waybar-hyprland;

          systemd = {
            enable = false; # Gets started by hyprland
          };
        };
      };
    };
}
