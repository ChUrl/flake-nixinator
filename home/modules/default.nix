{inputs, ...}: {
  imports = [
    # Obsolete modules are kept in "1_deprecated" for reference.

    # My own HM modules
    ./chromium
    ./color
    ./docs
    ./firefox
    ./fish
    ./git
    ./hyprland
    ./hyprpanel
    ./kitty
    ./neovim
    ./nnn
    ./paths
    ./rmpc
    ./rofi
    ./waybar
    ./zathura

    # HM modules imported from the flake inputs
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.nixvim.homeManagerModules.nixvim
    inputs.ags.homeManagerModules.default
    inputs.spicetify-nix.homeManagerModules.default
  ];
}
