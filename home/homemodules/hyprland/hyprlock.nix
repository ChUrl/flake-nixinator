{
  config,
  hyprland,
  color,
}: {
  enable = true;

  settings = {
    general = {
      disable_loading_bar = true;
      grace = 0; # Immediately lock
      hide_cursor = true;
      no_fade_in = false;
    };

    # The widgets start here.

    background = [
      {
        path = "${config.paths.nixflake}/wallpapers/${color.wallpaper}.jpg";
        blur_passes = 3;
        blur_size = 10;
        monitor = "";
      }
    ];

    input-field = [
      # Password input
      {
        size = "200, 50";
        position = "0, 0";
        monitor = "";
        dots_center = true;
        fade_on_empty = false;
        font_color = "rgb(${color.hex.accentText})";
        font_family = "${color.font}";
        inner_color = "rgb(${color.hex.accent})";
        outer_color = "rgb(${color.hex.accent})";
        outline_thickness = 2;
        placeholder_text = "<span foreground='\#\#${color.hex.accentText}'>Password...</span>";
        shadow_passes = 0;
        rounding = 4;
        halign = "center";
        valign = "center";
      }
    ];

    label = [
      # Date
      {
        position = "0, 300";
        monitor = "";
        text = ''cmd[update:1000] date -I'';
        color = "rgba(${color.hex.text}AA)";
        font_size = 22;
        font_family = "${color.font}";
        halign = "center";
        valign = "center";
      }

      # Time
      {
        position = "0, 200";
        monitor = "";
        text = ''cmd[update:1000] date +"%-H:%M"'';
        color = "rgba(${color.hex.text}AA)";
        font_size = 95;
        font_family = "${color.font} Extrabold";
        halign = "center";
        valign = "center";
      }
    ];
  };
}
