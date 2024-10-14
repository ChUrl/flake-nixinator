#!/usr/bin/env fish

# User chooses lecture
set LECTURE (eza -1 -D ~/Notes/TU | rofi -dmenu -p " lecture " -i)
if test -z $LECTURE
    exit
end

# User chooses slides
set DECK (eza -1 ~/Notes/TU/$LECTURE/Lecture | grep ".pdf" | rofi -dmenu -p " deck " -i)
if test -z $DECK
    exit
end

# TODO: $LECTURE and $DECK seem fine, but nothing opens:
#       error: Could not determine file type.
xdg-open ~/Notes/TU/$LECTURE/Lecture/$DECK
