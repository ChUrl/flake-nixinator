#!/nix/store/306znyj77fv49kwnkpxmb0j2znqpa8bj-bash-5.2p26/bin/sh

for i in */; do
    cd "$i"
    ./cmd.sh
    rm -f *.mod
    cd - > /dev/null
done
