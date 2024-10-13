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
            format = "<span font='FontAwesome'></span> ";
            interval = "once";
            tooltip = false;
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
            format = "<span font='FontAwesome'></span> {volume}%";
            format-muted = "<span font='FontAwesome'></span> ";
            on-click = "kitty ncpamixer -t o";
          };

          "network" = {
            format = "<span font='FontAwesome'></span> {ipaddr}";
            format-disconnected = "<span font='FontAwesome'></span> ";
            interface = "enp8s0";
            tooltip-format = "{ifname} via {gwaddr}";
          };

          cpu = {
            format = "<span font='FontAwesome'></span> {load}%";
          };

          memory = {
            format = "<span font='FontAwesome'></span> {percentage}%";
          };

          temperature = {
            format = "<span font='FontAwesome'></span> {temperatureC}°C";
            thermal-zone = 3;
          };

          clock = {
            format = "<span font='FontAwesome'></span> {:%H:%M}";
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

      style =
        (builtins.readFile ./colors/${hyprcfg.theme}.css)
        + ''
          /*Order is Top-Right-Bottom-Left for combined properties*/
          window#waybar {
            font-family: JetBrainsMono Nerd Font Mono;
            font-weight: bold;
            color: @base;
            background-color: rgba(239, 241, 245, 0.6);
          }

          /*Square Widgets*/
          #custom-launcher,
          #workspaces button,
          #tray {
            padding: 0px 10px 0px 10px;
            margin: 5px 5px 5px 5px;
            border-radius: 6px;
            color: @base;
          }

          #workspaces button:hover {
            color: @pink;
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
            background-color: @flamingo;
          }
          #user {
            background-color: @pink;
          }
          #window {
            background-color: @mauve;
          }
          #workspaces button {
            background-color: @red;
          }
          #pulseaudio {
            background-color: @maroon;
          }
          #network {
            background-color: @peach;
          }
          #cpu {
            background-color: @yellow;
          }
          #memory {
            background-color: @green;
          }
          #temperature {
            background-color: @teal;
          }
          #clock {
            background-color: @sky;
          }
          #tray {
            background-color: @sapphire;
          }
        '';
    };
  };
}
