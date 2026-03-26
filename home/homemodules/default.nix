{inputs, ...}: {
  imports = [
    # Obsolete modules are kept in "1_deprecated" for reference.

    # My own HM modules
    ./bat
    ./beets
    ./btop
    ./cava
    ./chromium
    ./color
    ./docs
    ./fastfetch
    ./fcitx
    ./firefox
    ./fish
    ./git
    ./jellyfin-tui
    ./kitty
    ./lazygit
    ./mpd
    ./neovim
    ./niri
    ./nnn
    ./packages
    ./paths
    ./qutebrowser
    ./rmpc
    ./rofi
    ./waybar
    ./ssh
    ./terminal
    ./tmux
    ./yazi
    ./zathura

    # HM modules imported from the flake inputs
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.nixvim.homeModules.nixvim
    inputs.textfox.homeManagerModules.default
    inputs.walker.homeManagerModules.default
    # inputs.niri.homeModules.niri # Imported by system module
    # inputs.noctalia.homeModules.default
    # inputs.caelestia.homeManagerModules.default
    # inputs.dank-material-shell.homeModules.dank-material-shell
    # inputs.dank-material-shell.homeModules.niri
    # inputs.danksearch.homeModules.default

    # NOTE: Do NOT use this, use the system module (the HM module has to rely on fuse)
    # inputs.impermanence.homeManagerModules.impermanence
  ];
}
