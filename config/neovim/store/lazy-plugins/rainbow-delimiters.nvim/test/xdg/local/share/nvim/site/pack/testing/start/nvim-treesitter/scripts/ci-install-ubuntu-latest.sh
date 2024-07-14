#!/nix/store/agkxax48k35wdmkhmmija2i2sxg8i7ny-bash-5.2p26/bin/bash

wget https://github.com/neovim/neovim/releases/download/${NVIM_TAG}/nvim-linux64.tar.gz
tar -zxf nvim-linux64.tar.gz
sudo ln -s "$PWD"/nvim-linux64/bin/nvim /usr/local/bin
rm -rf "$PWD"/nvim-linux64/lib/nvim/parser
mkdir -p ~/.local/share/nvim/site/pack/nvim-treesitter/start
ln -s "$PWD" ~/.local/share/nvim/site/pack/nvim-treesitter/start
