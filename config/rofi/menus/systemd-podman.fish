#!/usr/bin/env fish

# User chooses service, running services are marked in green
set SERVICES (cat /etc/rofi-containers)
set PROMPT ""
for SERVICE in $SERVICES
    set SERVICE_RUNNING "$(systemctl list-units podman-$SERVICE.service | grep podman-$SERVICE.service)"
    if test -z $SERVICE_RUNNING
        set PROMPT $PROMPT$SERVICE"\n"
    else
        set PROMPT $PROMPT"<span foreground=\"green\">$SERVICE</span>\n"
    end
end
set SERVICE (echo -e $PROMPT | rofi -dmenu -p " pod " -i -markup-rows)
set SERVICE (echo -e $SERVICE | sd "<.*?>" "")
if not contains $SERVICE $SERVICES
    exit
end

# User chooses action
set ACTIONS "start" "stop" "restart" "status"
set ACTION (echo -e (string join "\n" $ACTIONS) | rofi -dmenu -p " action " -i)
if not contains $ACTION $ACTIONS
    exit
end

# Execute command
set COMMAND "systemctl $ACTION podman-$SERVICE.service"
set EVAL_RESULT "$(eval $COMMAND)"

if test $ACTION = "status" && test -n "$EVAL_RESULT"
    # Display result if it exists
    rofi -theme ~/NixFlake/config/rofi/rofi.rasi -e "$EVAL_RESULT"
end
