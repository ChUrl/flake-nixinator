#!/usr/bin/env fish

grep -E "^bind =" ~/NixFlake/config/hyprland/hyprland.conf | sd "bind = " "" | rofi -dmenu -p " keys " -i