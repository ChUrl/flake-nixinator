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
    ./niri
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
    # inputs.niri.homeModules.niri # Imported by system module
    inputs.noctalia.homeModules.default
    inputs.caelestia.homeManagerModules.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.niri

    # NOTE: Do NOT use this, use the system module (the HM module has to rely on fuse)
    # inputs.impermanence.homeManagerModules.impermanence
  ];
}
