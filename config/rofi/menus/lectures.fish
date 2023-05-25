#!/usr/bin/env fish

# User chooses lecture
set LECTURE (exa -1 -D ~/Notes/TU | rofi -dmenu -p " lecture " -i)
if test -z $LECTURE
    exit
end

# User chooses slides
set DECK (exa -1 ~/Notes/TU/$LECTURE/Lecture | grep ".pdf" | rofi -dmenu -p " deck " -i)
if test -z $DECK
    exit
end

xdg-open ~/Notes/TU/$LECTURE/Lecture/$DECK
