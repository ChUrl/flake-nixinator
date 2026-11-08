{...}: {
  imports = [
    ./bootloader
    ./desktopportal
    ./docker
    ./fonts
    ./impermanence
    ./mime
    ./monitoring-agent
    ./network
    ./nix-cache
    ./polkit
    ./remote-build
    ./restic
    ./sops-nix
    ./ssh
    ./vm
  ];
}
