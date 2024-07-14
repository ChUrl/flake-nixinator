#!/nix/store/agkxax48k35wdmkhmmija2i2sxg8i7ny-bash-5.2p26/bin/sh

for i in */; do
    cd "$i"
    ./cmd.sh
    rm -f *.mod
    cd - > /dev/null
done
