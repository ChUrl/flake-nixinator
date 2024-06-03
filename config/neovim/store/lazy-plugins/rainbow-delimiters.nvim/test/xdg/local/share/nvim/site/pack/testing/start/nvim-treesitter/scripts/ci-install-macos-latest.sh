#!/nix/store/306znyj77fv49kwnkpxmb0j2znqpa8bj-bash-5.2p26/bin/bash

curl -L https://github.com/neovim/neovim/releases/download/${NVIM_TAG}/nvim-macos.tar.gz | tar -xz
sudo ln -s "$PWD"/nvim-macos/bin/nvim /usr/local/bin
rm -rf "$PWD"/nvim-macos/lib/nvim/parser
mkdir -p ~/.local/share/nvim/site/pack/nvim-treesitter/start
ln -s "$PWD" ~/.local/share/nvim/site/pack/nvim-treesitter/start
