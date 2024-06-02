#!/nix/store/306znyj77fv49kwnkpxmb0j2znqpa8bj-bash-5.2p26/bin/sh
exec nvim -u NONE -E -R --headless +'set rtp+=$PWD' +'luafile scripts/docgen.lua' +q
