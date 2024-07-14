#!/nix/store/agkxax48k35wdmkhmmija2i2sxg8i7ny-bash-5.2p26/bin/bash

HERE="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd $HERE/..

run() {
    nvim --headless --noplugin -u scripts/minimal_init.lua \
        -c "PlenaryBustedDirectory $1 { minimal_init = './scripts/minimal_init.lua' }"
}

if [[ $2 = '--summary' ]]; then
    ## really simple results summary by filtering plenary busted output
    run tests/$1  2> /dev/null | grep -E '^\S*(Testing|Success|Failed|Errors)\s*:'
else
    run tests/$1
fi
