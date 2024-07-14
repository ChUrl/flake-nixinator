#!/nix/store/agkxax48k35wdmkhmmija2i2sxg8i7ny-bash-5.2p26/bin/sh
exec nvim -u NONE -E -R --headless +'set rtp+=$PWD' +'luafile scripts/docgen.lua' +q
