{
  inputs,
  hostname,
  username,
  lib,
  mylib,
  config,
  nixosConfig,
  pkgs,
  ...
}:
# Here goes the stuff that will only be enabled on the desktop
rec {
  imports = [
    ../../modules
  ];

  config = {
    modules = {
      hyprland = {
        kb-layout = "us";
        kb-variant = "altgr-intl";

        monitors = {
          "HDMI-A-3" = {
            width = 1920;
            height = 1080;
            rate = 60;
            x = 0;
            y = 0;
            scale = 1;
          };
        };

        workspaces = {
          "HDMI-A-3" = [1 2 3 4 5 6 7 8 9 10];
        };
      };

      waybar.monitor = "HDMI-A-3";
    };

    # Use mkForce to not pull the entire ballast from /home/christoph/default.nix
    home.packages = with pkgs; lib.mkForce [
      ffmpeg_5-full # v5, including ffplay
      imagemagick # Convert image (magic)
      unrar
      p7zip
    ];
  };
}
