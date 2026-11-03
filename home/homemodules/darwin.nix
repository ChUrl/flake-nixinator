{inputs, ...}: {
  imports = [
    # My own HM modules
    ./bat
    ./btop
    ./color
    ./fastfetch
    ./fish
    ./git
    ./impermanence
    ./jellyfin-tui
    ./kitty
    ./lazygit
    ./neovim
    ./packages
    ./paths
    ./sops
    ./ssh
    ./terminal
    ./tmux
    ./yazi
    ./zathura

    # HM modules imported from the flake inputs
    inputs.nixvim.homeModules.nixvim
    inputs.textfox.homeManagerModules.default
  ];
}
