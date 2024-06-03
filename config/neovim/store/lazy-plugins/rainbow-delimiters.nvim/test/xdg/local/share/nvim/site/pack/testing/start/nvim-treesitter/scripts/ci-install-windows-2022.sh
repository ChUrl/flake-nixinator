#!/nix/store/306znyj77fv49kwnkpxmb0j2znqpa8bj-bash-5.2p26/bin/bash

curl -L https://github.com/neovim/neovim/releases/download/${NVIM_TAG}/nvim-win64.zip -o nvim-win64.zip
unzip nvim-win64
mkdir -p ~/AppData/Local/nvim/pack/nvim-treesitter/start
mkdir -p ~/AppData/Local/nvim-data
cp -r "$PWD" ~/AppData/Local/nvim/pack/nvim-treesitter/start
