# Here goes the stuff that will only be enabled on the desktop
{pkgs, ...}: {
  imports = [
    ../../modules
  ];

  config = {
    modules = {
      hyprland = {
        kb-layout = "us";
        kb-variant = "altgr-intl";

        monitors = {
          "HDMI-A-1" = {
            width = 2560;
            height = 1440;
            rate = 144;
            x = 1920;
            y = 0;
            scale = 1;
          };

          "DP-1" = {
            width = 1920;
            height = 1080;
            rate = 60;
            x = 0;
            y = 0;
            scale = 1;
          };
        };

        workspaces = {
          "HDMI-A-1" = [1 2 3 4 5 6 7 8 9];
          "DP-1" = [10];
        };

        autostart = {
          delayed = [
            "fcitx5"
          ];
        };

        floating = [
          {
            class = "fcitx";
          }
        ];
      };

      # TODO: Also set the dunst monitor
      waybar.monitor = "HDMI-A-1";
    };

    home.packages = with pkgs; [
      # quartus-prime-lite # Intel FPGA design software

      unityhub
      jetbrains.rider
      (with dotnetCorePackages;
        combinePackages [
          sdk_6_0_1xx
          sdk_7_0_3xx
          sdk_8_0_2xx
        ]) # For Rider/Unity
      mono # For Rider/Unity

      blender
      # godot_4
      obs-studio
      kdenlive
      krita
      # makemkv
    ];
  };
}
