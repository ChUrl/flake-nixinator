{inputs, ...}: {
  imports = [
    # Obsolete modules are kept in "1_deprecated" for reference.

    # My own HM modules
    ./beets
    ./chromium
    ./color
    ./docs
    ./firefox
    ./fish
    ./git
    ./hyprland
    ./hyprpanel
    ./kitty
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
    # inputs.agenix.homeManagerModules.default
    # inputs.ags.homeManagerModules.default
    # inputs.spicetify-nix.homeManagerModules.default
  ];
}
