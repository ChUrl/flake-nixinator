# Here goes the stuff that will only be enabled on the laptop
{...}: {
  imports = [
    ../../modules
  ];

  config = {
    modules = {
      hyprland = {
        keyboard = {
          layout = "us";
          variant = "altgr-intl";
          option = "nodeadkeys";
        };

        monitors = {
          "eDP-1" = {
            width = 1920;
            height = 1080;
            rate = 60;
            x = 0;
            y = 0;
            scale = 1;
          };
        };

        workspaces = {
          "eDP-1" = [1 2 3 4 5 6 7 8 9];
        };
      };

      waybar.monitor = "eDP-1";
    };

    home = {
      # packages = with pkgs; [];

      # Do not change.
      # This marks the version when NixOS was installed for backwards-compatibility.
      stateVersion = "22.05";
    };
  };
}
