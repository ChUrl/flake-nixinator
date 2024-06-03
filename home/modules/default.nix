{inputs, ...}: {
  imports = [
    ./audio
    ./chromium
    ./emacs
    ./email
    ./firefox
    ./fish
    ./flatpak
    ./gaming
    ./helix
    ./hyprland
    ./kitty
    ./misc
    ./neovim
    ./nextcloud
    ./nnn
    ./ranger
    ./rofi
    ./vscode
    ./waybar

    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.nixvim.homeManagerModules.nixvim
  ];
}
