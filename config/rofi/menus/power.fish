#!/usr/bin/env fish

# User chooses option
set OPTIONS "Poweroff" "Reboot" "Reload Hyprland" "Exit Hyprland"
set OPTION (echo -e (string join "\n" $OPTIONS) | rofi -theme ~/NixFlake/config/rofi/rofi.rasi -dmenu -p "power" -i)
if not contains $OPTION $OPTIONS
    exit
end

# Set command
if test "Poweroff" = $OPTION
    set ACTION "poweroff"
else if test "Reboot" = $OPTION
    set ACTION "reboot"
else if test "Reload Hyprland" = $OPTION
    set ACTION "hyprctl reload"
else if test "Exit Hyprland" = $OPTION
    set ACTION "hyprctl dispatch exit"
else
    exit
end

# Execute command
eval $ACTION