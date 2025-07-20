{inputs, ...}: {
  imports = [
    # Obsolete modules are kept in "1_deprecated" for reference.

    # My own HM modules
    ./beets
    ./btop
    ./chromium
    ./color
    ./docs
    ./fcitx
    ./firefox
    ./fish
    ./git
    ./hyprland
    ./hyprpanel
    ./kitty
    ./lazygit
    ./mpd
    ./neovim
    ./nnn
    ./paths
    ./rmpc
    ./rofi
    ./waybar
    ./yazi
    ./zathura

    # HM modules imported from the flake inputs
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.nixvim.homeManagerModules.nixvim
    # inputs.impermanence.homeManagerModules.impermanence
  ];
}
