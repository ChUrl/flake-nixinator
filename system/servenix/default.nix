{
  inputs,
  config,
  lib,
  mylib,
  pkgs,
  ...
}: rec {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../modules

    # inputs.musnix.nixosModules.musnix
  ];

  modules = {
    containers = {
      enable = true;

      homeassistant.enable = true;
      stablediffusion.enable = false;
      jellyfin.enable = true;
      fileflows.enable = false;
      sonarr.enable = true;
      radarr.enable = true;
      hydra.enable = true;
      sabnzbd.enable = true;
    };

    systemd-networkd = {
      wireguard-tunnels = {
        wg0-de-115 = (
          mylib.networking.mkWireguardService
          "wg0-de-115"
          "proton-de-115.key"
          "9+CorlxrTsQR7qjIOVKsEkk8Z7UUS5WT3R1ccF7a0ic="
          "194.126.177.14"
        );

        wg0-lu-16 = (
          mylib.networking.mkWireguardService
          "wg0-lu-16"
          "proton-lu-16.key"
          "asu9KtQoZ3iKwELsDTgjPEiFNcD1XtgGgy3O4CZFg2w="
          "92.223.89.133"
        );
      };
    };
  };

  services.xserver = {
    enable = lib.mkForce false;

    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";

    # videoDrivers = [ "nvidia" ]; # NVIDIA
    # videoDrivers = ["amdgpu"];
    # videoDrivers = ["intel"];
  };

  programs = lib.mkForce {
    fish.enable = true;
    firejail.enable = true;
    git.enable = true;
    neovim.enable = true;
    starship.enable = true;
  };

  services = {
    pipewire.enable = lib.mkForce false;
    printing.enable = lib.mkForce false;
    avahi.enable = lib.mkForce false;
    flatpak.enable = lib.mkForce false;
    qemuGuest.enable = true;
  };
}
