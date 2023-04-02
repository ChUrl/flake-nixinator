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

    inputs.musnix.nixosModules.musnix
  ];

  # Low latency audio
  musnix = {
    enable = true;
    # musnix.soundcardPciId = ;
  };

  services.xserver = {
    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";

    # videoDrivers = [ "nvidia" ]; # NVIDIA
    videoDrivers = ["amdgpu"];
  };

  programs.hyprland = {
    enable = true;
    nvidiaPatches = false;
    recommendedEnvironment = true;

    # NOTE: System module hyprland is configured in ~/.config/hypr/
    # extraConfig = ''
    #   bind = SUPER,a,exec,rofi -show drun

    #   exec-once = dunst & # Notification daemon
    #   exec-once = ${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1
    # '';
  };
}
