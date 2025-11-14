{
  pkgs,
  config,
  hyprland,
  color,
}: {
  enable = hyprland.dunst.enable;

  # iconTheme.package = pkgs.papirus-icon-theme;
  iconTheme.name = color.iconTheme;

  settings = {
    global = {
      monitor = config.modules.waybar.monitor;
      font = "${color.font} 11";
      offset = "10x10";
      background = color.hexS.base;
      foreground = color.hexS.text;
      frame_width = 2;
      corner_radius = 6;
      separator_color = "frame";
    };

    urgency_low = {
      frame_color = color.hexS.green;
    };

    urgency_normal = {
      frame_color = color.hexS.green;
    };

    urgency_critical = {
      frame_color = color.hexS.red;
    };
  };
}
