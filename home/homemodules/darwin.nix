{inputs, ...}: {
  imports = [
    # My own HM modules
    ./color
    ./fish
    ./git
    ./kitty
    ./lazygit
    ./neovim
    ./paths
    ./yazi

    # HM modules imported from the flake inputs
    inputs.nixvim.homeModules.nixvim
    inputs.textfox.homeManagerModules.default
  ];
}
