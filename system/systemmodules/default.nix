{...}: {
  imports = [
    ./authelia
    ./bootloader
    ./caddy
    ./desktopportal
    ./docker
    ./fonts
    ./impermanence
    ./mime
    ./network
    ./polkit
    ./restic
    ./sops-nix
    ./ssh
  ];
}
