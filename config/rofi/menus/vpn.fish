#!/usr/bin/env fish

# User chooses VPN server, running servers are marked in green
set SERVERS (cat /etc/rofi-vpns)
set PROMPT ""
for SERVER in $SERVERS
    set SERVER_RUNNING "$(systemctl list-units $SERVER.service | grep $SERVER.service)"
    if test -z $SERVER_RUNNING
        set PROMPT $PROMPT$SERVER"\n"
    else
        set PROMPT $PROMPT"<span foreground=\"green\">$SERVER</span>\n"
    end
end
set SERVER (echo -e $PROMPT | rofi -dmenu -p " vpn " -i -markup-rows)
set SERVER (echo -e $SERVER | sd "<.*?>" "")
if not contains $SERVER $SERVERS
    exit
end

# User chooses action
set ACTIONS "start" "stop" "status"
set ACTION (echo -e (string join "\n" $ACTIONS) | rofi -dmenu -p " action " -i)
if not contains $ACTION $ACTIONS
    exit
end

# Enable wireguard netdev
set COMMAND "systemctl $ACTION $SERVER.service"
set EVAL_RESULT "$(eval $COMMAND)"

if test $ACTION = "status" && test -n "$EVAL_RESULT"
    # Display result if it exists
    rofi -theme ~/NixFlake/config/rofi/rofi.rasi -e "$EVAL_RESULT"
else if test $ACTION = "start"
    # Launch chromium in firejail
    # NOTE: With a shared home directory, firejail uses the same instance, so it won't work to
    #       launch multiple browsers with different VPNs...
    # firejail --noprofile --allusers --private="~/.firejail-home" --netns="wg0-$SERVER" chromium --incognito --new-window ipaddress.my &>/dev/null
    firejail --noprofile --private --netns="$SERVER" chromium --incognito --new-window ipaddress.my &>/dev/null
end
