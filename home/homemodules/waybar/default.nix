{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.homemodules) color waybar;
in {
  options.homemodules.waybar = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf waybar.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 36;
          spacing = 0;
          margin = "10px 10px 0px 10px";
          fixed-center = true;
          output = ["${waybar.monitor}"];

          modules-left = ["custom/launcher" "user" "hyprland/window"];
          modules-center = ["hyprland/workspaces"];
          modules-right = ["pulseaudio" "network" "cpu" "memory" "temperature" "clock" "tray"];

          "custom/launcher" = {
            format = "<span></span>";
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
            format = "<span>󰕾</span> {volume}%";
            format-muted = "<span>󰝟</span> ";
            on-click = "kitty ncpamixer -t o";
          };

          "network" = {
            format = "<span>󰌀</span> {ipaddr}";
            format-disconnected = "<span></span> ";
            interface = "enp8s0";
            tooltip-format = "{ifname} via {gwaddr}";
          };

          cpu = {
            format = "<span></span> {load}%";
          };

          memory = {
            format = "<span></span> {percentage}%";
          };

          temperature = {
            format = "<span></span> {temperatureC}°C";
            thermal-zone = 3;
          };

          clock = {
            format = "<span>󰥔</span> {:%H:%M}";
            timezone = "Europe/Berlin";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
          };

          tray = {
            icon-size = 22;
            show-passive-items = true;
            spacing = 5;
          };
        };
      };

      style = let
        border-width = "2px";
        border-radius = "10px";
      in ''
        /* Order is Top-Right-Bottom-Left for combined properties */
        * {
          font-family: ${color.font};
        }

        window#waybar {
          border-style: solid;
          border-width: ${border-width};
          border-radius: ${border-radius};
          border-color: #${color.hex.accent};
          background-color: rgba(${color.rgbS.mantle}, 1.0);
        }

        tooltip {
          color: #${color.hex.text};
          font-weight: normal;
          border-style: solid;
          border-width: ${border-width};
          border-radius: ${border-radius};
          border-color: #${color.hex.accent};
          background-color: rgba(${color.rgbS.mantle}, 1.0);
        }

        /* Background colors */
        #custom-launcher          {background-color: #${color.hex.accent};}
        #user                     {background-color: #${color.hex.pink};}
        #window                   {background-color: #${color.hex.mauve};}
        #workspaces button        {background-color: #${color.hex.lavender};}
        #workspaces button.active {background-color: #${color.hex.pink};}
        #pulseaudio               {background-color: #${color.hex.maroon};}
        #network                  {background-color: #${color.hex.peach};}
        #cpu                      {background-color: #${color.hex.yellow};}
        #memory                   {background-color: #${color.hex.green};}
        #temperature              {background-color: #${color.hex.teal};}
        #clock                    {background-color: #${color.hex.sky};}
        #tray                     {background-color: #${color.hex.accent};}

        /* Square Widgets */
        #custom-launcher,
        #workspaces button,
        #tray {
          color: #${color.hex.mantle};
          font-weight: bold;
          padding: 0px 10px 0px 10px;
          border-radius: ${border-radius};
        }

        /* Rectangle Widgets */
        #user,
        #window,
        #pulseaudio,
        #network,
        #cpu,
        #memory,
        #temperature,
        #clock {
          color: #${color.hex.mantle};
          font-weight: bold;
          padding: 0px 10px 0px 10px;
          margin: 8px 5px 8px 5px;
          border-radius: ${border-radius};
        }

        /* Make window module transparent when no windows present */
        window#waybar.empty #window {
            background-color: transparent;
        }

        /* Alignment of left/right/center elements */

        /* Tux Icon */
        #custom-launcher {
          font-size: 26px;
          padding-right: 10px;
          margin: 0px 5px 0px 0px;
        }

        #workspaces button {
          margin: 0px 5px 0px 5px;
        }

        #tray {
          margin: 0px 0px 0px 5px;
        }
      '';
    };
  };
}
