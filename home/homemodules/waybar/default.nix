{
  config,
  lib,
  mylib,
  hostname,
  pkgs,
  ...
}: let
  inherit (config.homemodules) color waybar;

  # Desktop-only widgets (NVIDIA GPU etc.)
  isNixinator = hostname == "nixinator";
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

          modules-left = ["custom/launcher" "niri/workspaces" "niri/window" "hyprland/workspaces" "hyprland/window"]; # "user"
          modules-center = ["mpris"]; # "systemd-failed-units"
          modules-right =
            lib.optional isNixinator "systemd-failed-units"
            ++ ["privacy" "pulseaudio" "network" "disk" "custom/cpu"]
            ++ lib.optional isNixinator "custom/gpu"
            ++ ["memory" "clock" "tray"];

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

          "hyprland/workspaces" = {
            all-outputs = false;
            format = "{icon}";
            format-icons = {
              default = "";
              focused = "";
              active = "";
            };
            persistent-workspaces = {
              DP-1 = [1 2 3 4 5 6 7 8 9];
              DP-2 = [0];
            };
          };

          "hyprland/window" = {
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

          network =
            if isNixinator
            then {
              format = "<span>󰌀</span> {ipaddr}";
              format-wifi = "<span>󰌀</span> {essid} {signalStrength}%";
              format-ethernet = "<span>󰌀</span> {ipaddr}";
              format-disconnected = "<span></span> ";
              tooltip = true;
              tooltip-format = "{ifname}: {ipaddr}/{cidr}\n↓ {bandwidthDownBytes}  ↑ {bandwidthUpBytes}";
            }
            else {
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

          # Waybar's cpu module cannot show a temperature, so this mirrors custom/gpu
          "custom/cpu" = let
            cpuScript = pkgs.writeShellScript "waybar-cpu" ''
              set -eu

              state="''${XDG_RUNTIME_DIR:-/tmp}/waybar-cpu.stat"

              # cpu user nice system idle iowait irq softirq steal guest guest_nice
              read -r _cpu u n s i w irq sirq st _rest < /proc/stat
              total=$((u + n + s + i + w + irq + sirq + st))
              busy=$((total - i - w))

              prev_total=0
              prev_busy=0
              if [ -r "$state" ]; then
                read -r prev_total prev_busy < "$state" || true
              fi
              echo "$total $busy" > "$state"

              delta=$((total - prev_total))
              delta_busy=$((busy - prev_busy))
              if [ "$prev_total" -eq 0 ]; then
                # First sample after a (re)start, fall back to "since boot"
                usage=$((busy * 100 / total))
              elif [ "$delta" -gt 0 ]; then
                usage=$((delta_busy * 100 / delta))
              else
                usage=0
              fi
              [ "$usage" -le 100 ] || usage=100
              [ "$usage" -ge 0 ] || usage=0

              # Package temperature
              temp=""
              for name in /sys/class/hwmon/hwmon*/name; do
                read -r hwmon < "$name" || continue
                case "$hwmon" in
                  k10temp | zenpower | coretemp | cpu_thermal) ;;
                  *) continue ;;
                esac
                if read -r milli < "''${name%name}temp1_input"; then
                  temp=$((milli / 1000))
                fi
                break
              done

              read -r load1 load5 load15 _rest < /proc/loadavg

              freq=$(
                cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null |
                  ${pkgs.gawk}/bin/awk '{ sum += $1; n++ } END { if (n) printf "%.2f", sum / n / 1000000 }'
              ) || freq=""
              [ -n "$freq" ] || freq="n/a"

              # JSON needs escaped newlines in the tooltip
              nl='\n'
              temp_text=""
              temp_tooltip=""
              if [ -n "$temp" ]; then
                temp_text=" $temp°C"
                temp_tooltip="Temp:   $temp°C$nl"
              fi

              class=""
              if [ "$usage" -ge 85 ]; then
                class="critical"
              fi

              printf '{"text":"%s%%%s","tooltip":"Usage:  %s%%%s%sLoad:   %s / %s / %s%sFreq:   %s GHz","class":"%s"}\n' \
                "$usage" "$temp_text" "$usage" "$nl" "$temp_tooltip" \
                "$load1" "$load5" "$load15" "$nl" "$freq" "$class"
            '';
          in {
            exec = cpuScript;
            return-type = "json";
            interval = 1;
            format = "<span></span> {text}";
            on-click = "kitty --title=Btop btop";
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

          # Defined for every host (like the niri/hyprland modules), but only
          # added to modules-right on nixinator.
          "custom/gpu" = let
            gpuScript = pkgs.writeShellScript "waybar-gpu" ''
              nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total \
                --format=csv,noheader,nounits -i 0 2>/dev/null |
              ${pkgs.gawk}/bin/awk -F', *' '
                {
                  printf "{\"text\":\"󰢮 %s%% %s°C\",\"tooltip\":\"GPU %s%% · %s°C\\nVRAM %s / %s MiB\"}\n", $1, $2, $1, $2, $3, $4
                }
                END {
                  if (NR == 0) printf "{\"text\":\"󰢮 n/a\"}\n"
                }
              '
            '';
          in {
            exec = gpuScript;
            return-type = "json";
            interval = 5;
            on-click = "kitty --title=Btop btop";
          };
        };
      };

      style = let
        border-width = "2px";
        border-radius = "10px";

        # The GPU chip only exists on nixinator, so shift the following chips'
        # colors there only; other hosts keep the original sequence.
        memoryColor =
          if isNixinator
          then color.hex.sky
          else color.hex.teal;
        clockColor =
          if isNixinator
          then color.hex.sapphire
          else color.hex.sky;

        # Styles for modules that only exist on nixinator
        desktopCss = lib.optionalString isNixinator ''
          #custom-gpu,
          #systemd-failed-units {
            color: #${color.hex.mantle};
            font-weight: bold;
            padding: 0px 10px 0px 10px;
            margin: 8px 5px 8px 5px;
            border-radius: ${border-radius};
          }

          #custom-gpu         {background-color: #${color.hex.teal};}
          #systemd-failed-units {background-color: #${color.hex.red};}
        '';
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
          background-color: rgba(${color.rgbS.mantle}, 0.7);
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
        #custom-cpu                {background-color: #${color.hex.green};}
        #custom-cpu.critical       {color: #${color.hex.red};}
        #memory                    {background-color: #${memoryColor};}
        #clock                     {background-color: #${clockColor};}
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
        #custom-cpu,
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

        ${desktopCss}
      '';
    };
  };
}
