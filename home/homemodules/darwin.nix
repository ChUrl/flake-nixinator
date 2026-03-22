{inputs, ...}: {
  imports = [
    # My own HM modules
    ./bat
    ./color
    ./fastfetch
    ./fish
    ./git
    ./kitty
    ./lazygit
    ./neovim
    ./paths
    ./ssh
    ./tmux
    ./yazi

    # HM modules imported from the flake inputs
    inputs.nixvim.homeModules.nixvim
    inputs.textfox.homeManagerModules.default
  ];
}
