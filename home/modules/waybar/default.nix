{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.modules) color waybar;
in {
  options.modules.waybar = import ./options.nix {inherit lib mylib;};

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
            format = "<span></span>";
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
            format = "<span></span> {volume}%";
            format-muted = "<span></span> ";
            on-click = "kitty ncpamixer -t o";
          };

          "network" = {
            format = "<span></span> {ipaddr}";
            format-disconnected = "<span></span> ";
            interface = "enp8s0";
            tooltip-format = "{ifname} via {gwaddr}";
          };

          cpu = {
            format = "<span></span> {load}%";
          };

          memory = {
            format = "<span></span> {percentage}%";
          };

          temperature = {
            format = "<span></span> {temperatureC}°C";
            thermal-zone = 3;
          };

          clock = {
            format = "<span></span> {:%H:%M}";
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
        * {
          color: #${color.hex.dark.base};
          font-family: ${color.font};
          font-weight: bold;
        }

        window#waybar {
          border-style: solid;
          border-width: 2px;
          border-radius: 6px;
          border-color: #${color.hex.dark.lavender};
          background-color: rgba(${color.rgbString.light.base}, 0.3);
        }

        /*Colors*/
        #custom-launcher          {background-color: #${color.hex.dark.lavender};}
        #user                     {background-color: #${color.hex.dark.pink};}
        #window                   {background-color: #${color.hex.dark.mauve};}
        #workspaces button        {background-color: #${color.hex.dark.lavender};}
        #workspaces button.active {background-color: #${color.hex.dark.pink};}
        #pulseaudio               {background-color: #${color.hex.dark.maroon};}
        #network                  {background-color: #${color.hex.dark.peach};}
        #cpu                      {background-color: #${color.hex.dark.yellow};}
        #memory                   {background-color: #${color.hex.dark.green};}
        #temperature              {background-color: #${color.hex.dark.teal};}
        #clock                    {background-color: #${color.hex.dark.sky};}
        #tray                     {background-color: #${color.hex.dark.lavender};}


        /*Square Widgets*/
        #custom-launcher,
        #workspaces button,
        #tray {
          padding: 0px 10px 0px 10px;
          border-radius: 6px;
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

        /*make window module transparent when no windows present*/
        window#waybar.empty #window {
            background-color: transparent;
        }

        /*Tux Icon*/
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
