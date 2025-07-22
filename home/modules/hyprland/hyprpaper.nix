{
  config,
  hyprland,
  color,
}: {
  enable = true;

  settings = {
    ipc = "on";
    splash = false;
    splash_offset = 2.0;

    # Wallpapers have to be preloaded to be displayed
    preload = let
      mkPreload = name: "${config.paths.nixflake}/wallpapers/${name}.jpg";
    in
      color.wallpapers |> builtins.map mkPreload;

    wallpaper = let
      mkWallpaper = monitor:
        "${monitor}, "
        + "${config.paths.nixflake}/wallpapers/${color.wallpaper}.jpg";
    in
      hyprland.monitors
      |> builtins.attrNames
      |> builtins.map mkWallpaper;
  };
}
