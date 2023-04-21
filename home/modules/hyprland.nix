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
  options.modules.hyprland = {
    enable = mkEnableOpt "Hyprland Window Manager + Compositor";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = nixosConfig.programs.hyprland.enable;
        message = "Can't enable Hyprland module with Hyprland disabled!";
      }
    ];

    home.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };

    home.packages = with pkgs; [
      # TODO: Check which of these belong in the global config
      hyprpaper # Wallpaper setter
      wl-clipboard
      clipman # Clipboard manager (wl-paste)
      imv # Image viewer
      slurp # Region selector for screensharing
      ncpamixer # ncurses pavucontrol
      wofi
      cava
      font-manager
      
      # TODO: These are mostly also present in the Plasma module, find a way to unify this?
      libsForQt5.qt5ct # QT Configurator for unintegrated desktops
      # libsForQt5.ark
      libsForQt5.breeze-gtk # TODO: Remove
      libsForQt5.breeze-icons # TODO: Remove
      libsForQt5.breeze-qt5 # TODO: Remove
      # libsForQt5.dolphin # TODO: Replace
      # libsForQt5.dolphin-plugins # TODO: Remove
      # libsForQt5.ffmpegthumbs
      # libsForQt5.gwenview
      # libsForQt5.kalendar
      # libsForQt5.kate
      # libsForQt5.kcalc
      # libsForQt5.kcharselect
      # libsForQt5.kcolorpicker
      # libsForQt5.kdenetwork-filesharing
      # libsForQt5.kdegraphics-thumbnailers
      # libsForQt5.kfind
      # libsForQt5.kgpg
      libsForQt5.kmail
      # libsForQt5.kompare # Can't be used as git merge tool, but more integrated than kdiff3
      # libsForQt5.ksystemlog
      libsForQt5.kwallet # TODO: How does this integrate with hyprland?
      libsForQt5.kwalletmanager # TODO: Same as above
      # libsForQt5.kwrited
      libsForQt5.okular
      # libsForQt5.plasma-systemmonitor
      libsForQt5.polkit-kde-agent
      # libsForQt5.spectacle
      # libsForQt5.skanlite
    ];

    programs = {
      # Use wofi instead
      # rofi = {
      #   enable = true;
      #   package = pkgs.rofi-wayland;
      #   plugins = [
      #     pkgs.keepmenu # Rofi KeepassXC frontend
      #   ];
      #   terminal = "${pkgs.kitty}/bin/kitty";
  
      #   font = "JetBrains Mono 14";
      #   # theme = 
      #   # extraConfig = '''';
      # };

      waybar = let 
        # Taken from https://github.com/Ruixi-rebirth/flakes/blob/main/modules/programs/wayland/waybar/workspace-patch.nix
        hyprctl = "${pkgs.hyprland}/bin/hyprctl";
        workspaces-patch = pkgs.writeTextFile {
          name = "waybar-hyprctl.diff";
          text = ''
            diff --git a/src/modules/wlr/workspace_manager.cpp b/src/modules/wlr/workspace_manager.cpp
            index da83cb7..4c33ac3 100644
            --- a/src/modules/wlr/workspace_manager.cpp
            +++ b/src/modules/wlr/workspace_manager.cpp
            @@ -450,7 +450,8 @@ auto Workspace::handle_clicked(GdkEventButton *bt) -> bool {
               if (action.empty())
                 return true;
               else if (action == "activate") {
            -    zext_workspace_handle_v1_activate(workspace_handle_);
            +    const std::string command = "${hyprctl} dispatch workspace " + name_;
            +       system(command.c_str());
               } else if (action == "close") {
                 zext_workspace_handle_v1_remove(workspace_handle_);
               } else {
          '';
        };

        wrapico = icon: "<span font=\"FontAwesome\">${icon}</span> ";
      in {
        enable = true;
        package = pkgs.waybar.overrideAttrs (oldAttrs: {
          mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
          patches = (oldAttrs.patches or [ ]) ++ [ workspaces-patch ];
        });

        systemd = {
          enable = false; # Gets started by hyprland
        };
  
        # TODO: These icons do not fit at all, need to use a different icon font.
        settings = [{
          "output" = "HDMI-A-1"; # Only bar on main monitor, multiple wireplumber widgets result in crash
          "layer" = "top";
          "position" = "top";
          "height" = 34; # 34 fits with VictorMono Nerd Font size 15
          "spacing" = 4;

          "modules-left" = [
            # TODO: Launcher (opens wofi), with NixOS icon
            "custom/launcher"
            "user"
            "hyprland/window"
          ];

          "modules-center" = [
            "wlr/workspaces"
          ];

          "modules-right" = [
            # "cava" # Unknown? Maybe needs git version
            # "wireplumber"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            "clock"
            "tray"
          ];

          "custom/launcher" = {
            "interval" = "once";
            "format" = (wrapico "");
            "on-click" = "wofi --show drun --columns 2 -I"; # TODO: Wofi Theme
            "tooltip" = false;
          };

          "wlr/workspaces" = {
            "format" = "{name}"; # TODO: "{icon}""
            "on-click" = "activate";
            "sort-by-coordinates" = false;
            "sort-by-name" = true;
            "sort-by-number" = false;
            "all-outputs" = false;

            # TODO: This doesn't work? But I think I like it more without this anyway
            # "persistent_workspaces" = {
            #   # In [] the output can be specified, by I only use one bar, so not required
            #   "1" = ["HDMI-A-1"];
            #   "2" = ["HDMI-A-1"];
            #   "3" = ["HDMI-A-1"];
            #   "4" = ["HDMI-A-1"];
            #   "5" = ["HDMI-A-1"];
            #   "6" = ["HDMI-A-1"];
            #   "7" = ["HDMI-A-1"];
            #   "8" = ["HDMI-A-1"];
            #   "9" = ["HDMI-A-1"];
            #   # "0" = [];
            # };
          };

          # NOTE: This was wireplumber originally, but that is really unstable
          "pulseaudio" = {
            "format" = (wrapico "") + "{volume}%";
            "format-muted" = (wrapico "");
            "on-click" = "kitty ncpamixer";
          };

          "network" = {
            "interface" = "enp0s31f6";
            "format" = (wrapico "") + "{ipaddr}"; # Other Icon: 
            "format-disconnected" = (wrapico ""); # Other Icon: 
            "tooltip-format" = "{ifname} via {gwaddr}"; # TODO: gwaddr does not show?
          };

          "cpu" = {
            "format" = (wrapico "") + "{load}%";
          };

          "memory" = {
            "format" = (wrapico "") + "{percentage}%";
          };

          "temperature" = {
            "thermal-zone" = 3; # Zone 3 is "x86_pkg_temp"
            "format" = (wrapico "") + "{temperatureC}°C";
          };

          "clock" = {
            "format" = (wrapico "") + "{:%H:%M}";
            "timezone" = "Europe/Berlin";
            "tooltip-format" = "<tt><small>{calendar}</small></tt>";
          };

          "tray" = {
            "icon-size" = 20;
            "spacing" = 5;
            "show-passive-items" = true;
          };
        }];

        # Taken from https://github.com/MathisP75/hyppuccin/blob/main/waybar/desktop-bar/style.css
        style = ''
          window#waybar {
            border-radius: 0px;
            margin: 16px 16px;
          }
          
          window#waybar.hidden {
            opacity: 0.2;
          }
          
          #workspaces button {
            border-radius: 8px;
            padding: 0px 10px 0px 10px;
            margin: 7px 5px 10px 5px;
          }
          
          #custom-launcher,
          #clock,
          #cpu,
          #temperature,
          #network,
          #wireplumber,
          #memory {
            padding: 0px 20px;
            margin: 7px 0px 10px 0px;
	          border-radius: 8px;
          }
          
          #window,
          #custom-launcher {
            padding: 0px 25px 0px 20px;
            margin: 7px 0px 10px 20px;
          }
          
          #wireplumber {
            padding: 0px 20px 0px 17px;
          }
          
          #network {
            padding: 0px 15px 0px 20px;
          }
        '';
      };
    };

    services = {
      # Notification service
      dunst = {
        enable = true;
      };
    };

    # Polkit
    home.file.".config/hypr/polkit.conf".text = ''exec-once = ${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-agent-1 &'';

    home.activation = {
      # TODO: Can I simplify mkLink to include the hm.dag.entryAfter and the name?
      #       Like mkLink linkHyprlandConfig "source" "target"
      linkHyprlandConfig = hm.dag.entryAfter ["writeBoundary"] (mkLink "~/NixFlake/config/hyprland/hyprland.conf" "~/.config/hypr/hyprland.conf");
      linkHyprpaperConfig = hm.dag.entryAfter ["writeBoundary"] (mkLink "~/NixFlake/config/hyprland/hyprpaper.conf" "~/.config/hypr/hyprpaper.conf");
      # TODO: Allow choosing a wallpaper through an option
      linkWallpaper = hm.dag.entryAfter ["writeBoundary"] (mkLink "~/NixFlake/config/hyprland/wall.jpg" "~/.config/hypr/wall.jpg");
    };
  };
}
