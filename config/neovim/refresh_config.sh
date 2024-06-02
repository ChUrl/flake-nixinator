#!/usr/bin/env bash

INIT_PATH="$(readlink -f ~/.config/nvim/init.lua)"
cp -f "$INIT_PATH" ./config.lua
cp -f "$INIT_PATH" ./config_nix.lua
echo "Copied $INIT_PATH to ./config.lua and ./config_nix.lua"

chmod +w ./config.lua
chmod +w ./config_nix.lua
echo "Fixed permission for ./config.lua and ./config_nix.lua"
echo ""

rm -rf ./store/*
echo "Cleared ./store/"

STORE_PATHS=$(rg -oN "\"/nix/store/.*?(lazy-plugins|vimplugin-nvim-treesitter-.*?|treesitter-parsers)\"" config.lua | uniq | sd "\"" "")
for STORE_PATH in $STORE_PATHS
do
    cp -Lr "$STORE_PATH" ./store/
    echo "Copied $STORE_PATH to ./store/"
done

chmod -R +w ./store/*
echo "Fixed permissions for ./store"
echo ""

for IDENTIFIER in "treesitter-parsers" "lazy-plugins" "nvim-treesitter"
do
    CURRENT_PATH=$(eza -1 ./store | grep $IDENTIFIER)
    mv "./store/$CURRENT_PATH" "./store/$IDENTIFIER"
    echo "Moved ./store/$CURRENT_PATH to ./store/$IDENTIFIER"
done
echo ""

BASE_PATH="/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store"
for IDENTIFIER in "treesitter-parsers" "lazy-plugins" "nvim-treesitter"
do
    REPLACE_STRINGS=$(rg -oN "\"/nix/store/.*?$IDENTIFIER.*?\"" ./config.lua | uniq | sd "\"" "")
    for REPLACE_STRING in $REPLACE_STRINGS
    do
        if [[ $REPLACE_STRING =~ .*$IDENTIFIER/.* ]];
        then
            # Trailing / means not the entire string can be replaced
            REPLACE_STRING=$(dirname "$REPLACE_STRING")
            sd "$REPLACE_STRING" "$BASE_PATH/$IDENTIFIER" ./config.lua
            echo "Substituted $REPLACE_STRING with $BASE_PATH/$IDENTIFIER"
        else
            # No trailing / means the entire string can be replaced
            sd "$REPLACE_STRING" "$BASE_PATH/$IDENTIFIER" ./config.lua
            echo "Substituted $REPLACE_STRING with $BASE_PATH/$IDENTIFIER"
        fi
    done
done
echo ""

sd "/home/christoph" "/home/lab/smchurla" ./config.lua
echo "Substituted /home/christoph with /home/lab/smchurla"
