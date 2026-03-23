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
          output = waybar.monitors;

          modules-left = ["custom/launcher" "niri/workspaces" "niri/window"]; # "user"
          modules-center = ["mpris"]; # "systemd-failed-units"
          modules-right = ["privacy" "pulseaudio" "network" "disk" "cpu" "memory" "clock" "tray"];

          "custom/launcher" = {
            format = "<span></span>";
            interval = "once";
            on-click = "walker -m desktopapplications";
          };

          systemd-failed-units = {
            hide-on-ok = true;
            format = " {nr_failed}";
            format-ok = "✔️";
            system = true;
            user = true;
          };

          "niri/workspaces" = {
            all-outputs = false;
            format = "{icon}";
            format-icons = {
              default = "";
              focused = "";
              active = "";
            };
          };

          "niri/window" = {
            format = "{title}";
            separate-outputs = false;
            icon = true;
            icon-size = 22;
          };

          mpris = {
            format = "<span>󰎇</span> {dynamic}";
            format-paused = "<span>{status_icon}</span> <i>{dynamic}</i>";
            dynamic-order = ["artist" "title"];
            status-icons = {
              paused = "󰏤";
            };
          };

          privacy = {
            icon-spacing = 4;
            icon-size = 16;
            transition-duration = 250;
            modules = [
              {
                type = "screenshare";
                tooltip = true;
                tooltip-icon-size = 24;
              }
              # {
              #   type = "audio-out";
              #   tooltip = true;
              #   tooltip-icon-size = 24;
              # }
              {
                type = "audio-in";
                tooltip = true;
                tooltip-icon-size = 24;
              }
            ];
            ignore-monitor = true;
          };

          pulseaudio = {
            format = "<span>󰕾</span> {volume}%";
            format-muted = "<span>󰝟</span> ";
            on-click = "kitty --title=WireMix wiremix";
          };

          network = {
            format = "<span>󰌀</span> {ipaddr}";
            format-disconnected = "<span></span> ";
            interface = "enp8s0";
            tooltip = false;
          };

          disk = {
            interval = 5;
            format = "<span>󰋊</span> {percentage_used}%";
            on-click = "kitty --hold --title=Duf duf --hide-mp '/var/*,/etc/*,/usr/*,/home/christoph/.*' -width 120";
          };

          cpu = {
            interval = 1;
            # states = {
            #   "critical" = 85;
            # };
            format = "<span></span> {load}%";
            # format-critical = "<span color='#${color.hex.red}'><span></span> {load}%</span>";
            on-click = "kitty --title=Btop btop";
            tooltip = false;
          };

          memory = {
            interval = 1;
            # states = {
            #   "critical" = 85;
            # };
            format = "<span></span> {percentage}%";
            # format-critical = "<span color='#${color.hex.red}'><span></span> {percentage}%</span>";
            on-click = "kitty --title=Btop btop";
            tooltip = true;
            tooltip-format = "RAM:  {used}GiB / {total}GiB\nSwap: {swapUsed}GiB / {swapTotal}GiB";
          };

          clock = {
            format = "<span>󰥔</span> {:%H:%M}";
            timezone = "Europe/Berlin";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "month";
              weeks-pos = "right";
              mode-mon-col = 3;
              on-scroll = -1;
              format = {
                months = "<span color='#${color.hex.peach}'><b>{}</b></span>";
                days = "<span color='#${color.hex.flamingo}'><b>{}</b></span>";
                weeks = "<span color='#${color.hex.teal}'><b>W{}</b></span>";
                weekdays = "<span color='#${color.hex.lavender}'><b>{}</b></span>";
                today = "<span color='#${color.hex.accent}'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
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
        #custom-launcher           {background-color: #${color.hex.accent};}
        #workspaces button         {background-color: #${color.hex.blue};}
        #workspaces button.empty   {background-color: #${color.hex.lavender};}
        #workspaces button.active  {background-color: #${color.hex.green};}
        #workspaces button.urgent  {background-color: #${color.hex.red};}
        #window                    {background-color: #${color.hex.maroon};}

        #mpris                     {background-color: #${color.hex.accent};}

        #privacy                   {background-color: #${color.hex.red};}
        #pulseaudio                {background-color: #${color.hex.maroon};}
        #network                   {background-color: #${color.hex.peach};}
        #disk                      {background-color: #${color.hex.yellow};}
        #cpu                       {background-color: #${color.hex.green};}
        #memory                    {background-color: #${color.hex.teal};}
        #clock                     {background-color: #${color.hex.sky};}
        #tray                      {background-color: #${color.hex.accent};}

        /* Square Widgets */
        #custom-launcher,
        #mpris,
        #tray {
          color: #${color.hex.mantle};
          font-weight: bold;
          padding: 0px 10px 0px 10px;
          border-radius: ${border-radius};
        }

        /* Workspaces */
        #workspaces button {
          color: #${color.hex.mantle};
          font-weight: bold;
          padding: 0px 2px 0px 2px;
          margin: 8px 2px 8px 2px;
          border-radius: ${border-radius};
        }

        /* Rectangle Widgets */
        #user,
        #window,
        #pulseaudio,
        #privacy,
        #network,
        #disk,
        #cpu,
        #memory,
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
          padding-right: 13px;
          margin: 0px 5px 0px 0px;
        }

        #tray {
          margin: 0px 0px 0px 5px;
        }
      '';
    };
  };
}
