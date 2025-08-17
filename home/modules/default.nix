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
    ./qutebrowser
    ./rmpc
    ./rofi
    ./waybar
    ./yazi
    ./zathura

    # HM modules imported from the flake inputs
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.nixvim.homeModules.nixvim
    inputs.textfox.homeManagerModules.default

    # NOTE: Do NOT use this, use the system module (the HM module has to rely on fuse)
    # inputs.impermanence.homeManagerModules.impermanence
  ];
}
