{
  config,
  hyprland,
  color,
}: {
  enable = hyprland.caelestia.enable;
  systemd = {
    enable = false; # Start from hyprland autostart
    target = "graphical-session.target";
    environment = [];
  };

  settings = {
    bar.status = {
      showBattery = false;
    };
    paths.wallpaperDir = "~/NixFlake/wallpapers";
  };

  cli = {
    enable = hyprland.caelestia.enable;
    settings = {
      theme.enableGtk = false;
    };
  };
}
