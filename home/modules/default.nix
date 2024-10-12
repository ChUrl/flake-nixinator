{inputs, ...}: {
  imports = [
    # Obsolete modules are kept in "1_deprecated" for reference.

    # My own HM modules
    ./chromium
    ./firefox
    ./fish
    ./hyprland
    ./kitty
    ./latex
    ./neovim
    ./nnn
    ./rofi
    ./waybar
    ./zathura

    # HM modules imported from the flake inputs
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.nixvim.homeManagerModules.nixvim
  ];
}
