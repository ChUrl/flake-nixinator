#!/usr/bin/env fish

grep -E "^bind =" ~/NixFlake/config/hyprland/hyprland.conf | sd "bind = " "" | rofi -theme ~/NixFlake/config/rofi/rofi.rasi -dmenu -p "keys" -i