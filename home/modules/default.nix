{inputs, ...}: {
  imports = [
    # Obsolete modules are kept in this folder for reference.
    # ./audio
    # ./emacs
    # ./email
    # ./flatpak
    # ./helix
    # ./gaming
    # ./misc
    # ./nextcloud
    # ./ranger
    # ./vscode

    # My own HM modules
    ./chromium
    ./firefox
    ./fish
    ./hyprland
    ./kitty
    ./neovim
    ./nnn
    ./rofi
    ./waybar

    # HM modules imported from the flake inputs
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.nixvim.homeManagerModules.nixvim
  ];
}
