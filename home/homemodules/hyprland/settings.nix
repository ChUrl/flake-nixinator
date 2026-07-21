{
  lib,
  config,
  hyprland,
  color,
  always-exec,
  always-bind,
  always-bindm,
}: {
  "$mainMod" = "${hyprland.keybindings.main-mod}";

  general = {
    gaps_in = 5;
    gaps_out = 10;
    border_size = 2;

    "col.active_border" = "rgb(${color.hex.accent})";
    "col.inactive_border" = "rgb(${color.hex.base})";
  };

  group = {
    groupbar = {
      enabled = true;
      render_titles = false;
      font_size = 10;
      gradients = false;

      "col.active" = "rgb(${color.hex.accent})";
      "col.inactive" = "rgb(${color.hex.base})";
    };

    "col.border_active" = "rgb(${color.hex.accent})";
    "col.border_inactive" = "rgb(${color.hex.base})";
  };

  input = {
    kb_layout = hyprland.keyboard.layout;
    kb_variant = hyprland.keyboard.variant;
    kb_options = hyprland.keyboard.option;
    kb_model = "pc104";
    kb_rules = "";

    follow_mouse = true;

    touchpad = {
      natural_scroll = "no";
    };

    sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
  };

  monitor = let
    mkMonitor = name: conf:
      "${name}, "
      + "${builtins.toString conf.width}x${builtins.toString conf.height}@"
      + "${builtins.toString conf.rate}, "
      + "${builtins.toString conf.x}x${builtins.toString conf.y}, "
      + "${builtins.toString conf.scale}";
  in
    hyprland.monitors
    |> builtins.mapAttrs mkMonitor
    |> builtins.attrValues;

  workspace = let
    mkWorkspace = monitor: workspace:
      "${builtins.toString workspace}, "
      + "monitor:${builtins.toString monitor}";

    mkWorkspaces = monitor: workspace-list:
      builtins.map (mkWorkspace monitor) workspace-list;
  in
    hyprland.workspaces
    |> builtins.mapAttrs mkWorkspaces
    |> builtins.attrValues
    |> builtins.concatLists;

  bind = let
    mkBind = key: action: "${key}, ${action}";
    mkBinds = key: actions: builtins.map (mkBind key) actions;
  in
    (hyprland.keybindings.bindings // always-bind)
    |> builtins.mapAttrs mkBinds
    |> builtins.attrValues
    |> builtins.concatLists;

  bindm = let
    mkBind = key: action: "${key}, ${action}";
    mkBinds = key: actions: builtins.map (mkBind key) actions;
  in
    always-bindm
    |> builtins.mapAttrs mkBinds
    |> builtins.attrValues
    |> builtins.concatLists;

  exec-once = let
    mkDelayedStart = str: ''hyprctl dispatch exec "sleep 5s && ${str}"'';

    mkSpecialSilentStart = w: str: "[workspace special:${w} silent] ${str}";
    mkSpecialSilentStarts = w: strs: builtins.map (mkSpecialSilentStart w) strs;
  in
    lib.mkMerge [
      always-exec
      hyprland.autostart.immediate
      (hyprland.autostart.special-silent
        |> builtins.mapAttrs mkSpecialSilentStarts
        |> builtins.attrValues
        |> builtins.concatLists)
      (hyprland.autostart.delayed
        |> builtins.map mkDelayedStart)
    ];

  windowrule = let
    mkWorkspaceRule = workspace: class:
      "match:class ^(${class})$, "
      + "workspace ${workspace}";
    mkWorkspaceRules = workspace: class-list:
      builtins.map (mkWorkspaceRule workspace) class-list;

    mkFloatingRule = attrs:
      (lib.optionalString (builtins.hasAttr "class" attrs) "match:class ^(${attrs.class})$, ")
      + (lib.optionalString (builtins.hasAttr "title" attrs) "match:title ^(${attrs.title})$, ")
      + "float 1";

    mkTranslucentRule = class:
      "match:class ^(${class})$, "
      + "opacity ${hyprland.transparent-opacity} ${hyprland.transparent-opacity}";
  in
    lib.mkMerge [
      (hyprland.workspacerules
        |> builtins.mapAttrs mkWorkspaceRules
        |> builtins.attrValues
        |> builtins.concatLists)
      (hyprland.floating
        |> builtins.map mkFloatingRule)
      (hyprland.transparent
        |> builtins.map mkTranslucentRule)
      hyprland.windowrules
    ];

  render = {
    cm_enabled = true;
    cm_auto_hdr = true;
  };

  dwindle = {
    preserve_split = true;
  };

  master = {
    new_status = "master";
  };

  gesture = [
    "3, horizontal, workspace" # 3 Fingers, horizontal, workspace swipe
  ];

  misc = {
    # Say no to the anime girl
    disable_hyprland_logo = true;
    force_default_wallpaper = 0;

    # Say no to the "Application not responding" window
    enable_anr_dialog = false;

    disable_splash_rendering = true;
    font_family = "${color.font}";
  };

  # Because those are not windows, but layers,
  # we have to blur them explicitly
  layerrule = [
    "match:class rofi, blur 1"
    # "match:class rofi, ignore_alpha 0.001" # Fix pixelated corners
    # "match:class rofi, xray 0" # Render on top of other windows
    # "match:class rofi, dim_around 1"

    "match:class waybar, blur 1"
    "match:class gtk4-layer-shell, blur 1"
    "match:class bar-0, blur 1"
    "match:class bar-1, blur 1"
  ];

  decoration = {
    rounding = 4;

    shadow = {
      enabled = false;
    };

    blur = {
      enabled = true;
      size = 10;
      passes = 3;
      new_optimizations = true;
      ignore_opacity = true;
      xray = true;
    };
  };

  animations = {
    enabled = true;
    bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
    animation = [
      "windows, 1, 7, myBezier"
      "windowsOut, 1, 7, default,popin 80%"
      "border, 1, 10, default"
      "borderangle, 1, 8, default"
      "fade, 1, 7, default"
      "workspaces, 1, 6, default"
    ];
  };

  plugin = lib.mergeAttrsList [
    (lib.optionalAttrs hyprland.bars.enable {
      hyprbars = {
        enabled = true;

        bar_height = 25;
        bar_blur = true;
        bar_color = "rgb(${color.hex.base})";
        col.text = "rgb(${color.hex.text})";

        bar_title_enabled = true;
        bar_text_size = 12;
        bar_text_font = color.font;

        bar_text_align = "center";
        bar_buttons_alignment = "left";

        bar_part_of_window = true;
        bar_precedence_over_border = false;

        # example buttons (R -> L)
        # hyprbars-button = color, size, on-click
        hyprbars-button = [
          "rgb(${color.hex.red}), 10, 󰖭, hyprctl dispatch killactive"
          "rgb(${color.hex.green}), 10, , hyprctl dispatch fullscreen 1"
        ];

        # cmd to run on double click of the bar
        on_double_click = "hyprctl dispatch fullscreen 1";
      };
    })
  ];
}
