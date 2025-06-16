{inputs, ...}: {
  imports = [
    # Obsolete modules are kept in "1_deprecated" for reference.

    # My own HM modules
    ./ags
    ./chromium
    ./color
    ./firefox
    ./fish
    ./hyprland
    ./hyprpanel
    ./kitty
    ./latex
    ./neovim
    ./nnn
    ./paths
    ./rofi
    ./waybar
    ./zathura

    # HM modules imported from the flake inputs
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.nixvim.homeManagerModules.nixvim
    inputs.ags.homeManagerModules.default
    inputs.hyprpanel.homeManagerModules.hyprpanel
  ];
}
