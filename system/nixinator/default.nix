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

      homeassistant.enable = false;
      stablediffusion.enable = true;
      jellyfin.enable = true;
      fileflows.enable = false;
      sonarr.enable = false;
      radarr.enable = false;
      hydra.enable = false;
      sabnzbd.enable = false;
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

  # Low latency audio
  # musnix = {
  #   enable = true;
  #   # musnix.soundcardPciId = ;
  # };

  services.xserver = {
    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";

    # videoDrivers = [ "nvidia" ]; # NVIDIA
    videoDrivers = ["amdgpu"];
  };
}
