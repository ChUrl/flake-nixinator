{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.waybar;
  color = config.modules.color;
  hyprcfg = config.modules.hyprland;
in {
  options.modules.waybar = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 40;
          spacing = 4;
          output = ["${cfg.monitor}"];

          modules-left = ["custom/launcher" "user" "hyprland/window"];
          modules-center = ["hyprland/workspaces"];
          modules-right = ["pulseaudio" "network" "cpu" "memory" "temperature" "clock" "tray"];

          "custom/launcher" = {
            format = "<span font='${color.font}'></span> ";
            interval = "once";
            on-click = "rofi -drun-show-actions -show drun";
          };

          "hyprland/workspaces" = {
            all-outputs = false;
            format = "{name}";
            on-click = "activate";
            sort-by-coordinates = false;
            sort-by-name = true;
            sort-by-number = false;
          };

          "pulseaudio" = {
            format = "<span font='${color.font}'></span> {volume}%";
            format-muted = "<span font='${color.font}'></span> ";
            on-click = "kitty ncpamixer -t o";
          };

          "network" = {
            format = "<span font='${color.font}'></span> {ipaddr}";
            format-disconnected = "<span font='${color.font}'></span> ";
            interface = "enp8s0";
            tooltip-format = "{ifname} via {gwaddr}";
          };

          cpu = {
            format = "<span font='${color.font}'></span> {load}%";
          };

          memory = {
            format = "<span font='${color.font}'></span> {percentage}%";
          };

          temperature = {
            format = "<span font='${color.font}'></span> {temperatureC}°C";
            thermal-zone = 3;
          };

          clock = {
            format = "<span font='${color.font}'></span> {:%H:%M}";
            timezone = "Europe/Berlin";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
          };

          tray = {
            icon-size = 20;
            show-passive-items = true;
            spacing = 5;
          };
        };
      };

      style = ''
        /*Order is Top-Right-Bottom-Left for combined properties*/
        window#waybar {
          font-family: ${color.font};
          font-weight: bold;
          color: #${color.light.base};

          /*Can't use color.light.base here because waybar doesn't support rrggbbaa*/
          background-color: rgba(239, 241, 245, 0.5);
        }

        /*Square Widgets*/
        #custom-launcher,
        #workspaces button,
        #tray {
          padding: 0px 10px 0px 10px;
          margin: 5px 5px 5px 5px;
          border-radius: 6px;
          color: #${color.light.base};
        }

        #workspaces button:hover {
          color: #${color.light.pink};
        }

        /*Tux Icon*/
        #custom-launcher {
          font-size: 18px;
          padding-right: 0px;
        }

        /*Rectangle Widgets*/
        #user,
        #window,
        #pulseaudio,
        #network,
        #cpu,
        #memory,
        #temperature,
        #clock {
          padding: 0px 10px 0px 10px;
          margin: 8px 5px 8px 5px;
          border-radius: 6px;
        }

        /*Colors*/
        #custom-launcher {
          background-color: #${color.light.flamingo};
        }
        #user {
          background-color: #${color.light.pink};
        }
        #window {
          background-color: #${color.light.mauve};
        }
        #workspaces button {
          background-color: #${color.light.red};
        }
        #pulseaudio {
          background-color: #${color.light.maroon};
        }
        #network {
          background-color: #${color.light.peach};
        }
        #cpu {
          background-color: #${color.light.yellow};
        }
        #memory {
          background-color: #${color.light.green};
        }
        #temperature {
          background-color: #${color.light.teal};
        }
        #clock {
          background-color: #${color.light.sky};
        }
        #tray {
          background-color: #${color.light.sapphire};
        }
      '';
    };
  };
}
