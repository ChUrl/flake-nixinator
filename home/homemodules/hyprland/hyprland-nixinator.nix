{
  keyboard = {
    layout = "us";
    variant = "altgr-intl";
    option = "nodeadkeys";
  };

  monitors = {
    "DP-1" = {
      width = 3440;
      height = 1440;
      rate = 165;
      x = 1920;
      y = 0;
      scale = 1;
    };

    "DP-2" = {
      width = 1920;
      height = 1080;
      rate = 60;
      x = 0;
      y = 0;
      scale = 1;
    };
  };

  workspaces = {
    "DP-1" = [1 2 3 4 5 6 7 8 9];
    "DP-2" = [10];
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
}
