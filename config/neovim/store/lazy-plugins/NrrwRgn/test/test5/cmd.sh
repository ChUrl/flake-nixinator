#!/nix/store/agkxax48k35wdmkhmmija2i2sxg8i7ny-bash-5.2p26/bin/bash
#set -x

Test=`basename $PWD`

dir="$(realpath ../..)"
LC_ALL=C vim -u NONE -N \
    --cmd ':set noswapfile hidden' \
    -c "sil :so $dir/plugin/NrrwRgn.vim" \
    -c ':e 1.txt' \
    -c ':saveas! 1.txt.mod' \
    -c 'sil :1,$NR!' \
    -c 'sil :$put =\"Added Line\"' \
    -c ':wq' \
    -c ':$put =string(getmatches())' \
    -c ':wq!'

rt=$(diff -uN0 <(cat *.mod) <(cat *.ok))
if [ "$?" -ne 0 ]; then
    printf "$Test failed\n"
    printf "Diff:\n%s\n" "$rt"
    exit 2;
else
    printf "$Test successful!\n"
fi
