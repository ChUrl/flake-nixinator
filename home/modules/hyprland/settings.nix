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
      "workspace ${workspace}, "
      + "class:^(${class})$";
    mkWorkspaceRules = workspace: class-list:
      builtins.map (mkWorkspaceRule workspace) class-list;

    mkFloatingRule = attrs:
      "float"
      + (lib.optionalString (builtins.hasAttr "class" attrs) ", class:^(${attrs.class})$")
      + (lib.optionalString (builtins.hasAttr "title" attrs) ", title:^(${attrs.title})$");

    mkTranslucentRule = class:
      "opacity ${hyprland.transparent-opacity} ${hyprland.transparent-opacity}, "
      + "class:^(${class})$";
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

  dwindle = {
    pseudotile = true;
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
    "blur,rofi"
    "ignorealpha 0.001,rofi" # Fix pixelated corners
    "xray 0,rofi" # Render on top of other windows
    "dimaround,rofi"

    "blur,waybar"
    "blur,gtk4-layer-shell"
    "blur,bar-0"
    "blur,bar-1"
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

    (lib.optionalAttrs hyprland.dynamicCursor.enable {
      dynamic-cursors = {
        # enables the plugin
        enabled = true;

        # sets the cursor behaviour, supports these values:
        # tilt    - tilt the cursor based on x-velocity
        # rotate  - rotate the cursor based on movement direction
        # stretch - stretch the cursor shape based on direction and velocity
        # none    - do not change the cursors behaviour
        mode = "rotate";

        # minimum angle difference in degrees after which the shape is changed
        # smaller values are smoother, but more expensive for hw cursors
        threshold = 2;

        # for mode = rotate
        rotate = {
          # length in px of the simulated stick used to rotate the cursor
          # most realistic if this is your actual cursor size
          length = 20;

          # clockwise offset applied to the angle in degrees
          # this will apply to ALL shapes
          offset = 0.0;
        };

        # for mode = tilt
        tilt = {
          # controls how powerful the tilt is, the lower, the more power
          # this value controls at which speed (px/s) the full tilt is reached
          # the full tilt being 60° in both directions
          limit = 1000;

          # relationship between speed and tilt, supports these values:
          # linear             - a linear function is used
          # quadratic          - a quadratic function is used (most realistic to actual air drag)
          # negative_quadratic - negative version of the quadratic one, feels more aggressive
          # see `activation` in `src/mode/utils.cpp` for how exactly the calculation is done
          function = "negative_quadratic";

          # time window (ms) over which the speed is calculated
          # higher values will make slow motions smoother but more delayed
          window = 100;
        };

        # configure shake to find
        # magnifies the cursor if its is being shaken
        shake = {
          # enables shake to find
          enabled = false;

          # use nearest-neighbour (pixelated) scaling when shaking
          # may look weird when effects are enabled
          nearest = true;

          # controls how soon a shake is detected
          # lower values mean sooner
          threshold = 3.0;

          # magnification level immediately after shake start
          base = 1.5;
          # magnification increase per second when continuing to shake
          speed = 0.0;
          # how much the speed is influenced by the current shake intensitiy
          influence = 0.0;

          # maximal magnification the cursor can reach
          # values below 1 disable the limit (e.g. 0)
          limit = 0.0;

          # time in millseconds the cursor will stay magnified after a shake has ended
          timeout = 1000;

          # show cursor behaviour `tilt`, `rotate`, etc. while shaking
          effects = true;

          # enable ipc events for shake
          # see the `ipc` section below
          ipc = false;
        };

        # use hyprcursor to get a higher resolution texture when the cursor is magnified
        # see the `hyprcursor` section below
        hyprcursor = {
          # use nearest-neighbour (pixelated) scaling when magnifing beyond texture size
          # this will also have effect without hyprcursor support being enabled
          # 0 / false - never use pixelated scaling
          # 1 / true  - use pixelated when no highres image
          # 2         - always use pixleated scaling
          nearest = true;

          # enable dedicated hyprcursor support
          enabled = true;

          # resolution in pixels to load the magnified shapes at
          # be warned that loading a very high-resolution image will take a long time and might impact memory consumption
          # -1 means we use [normal cursor size] * [shake:base option]
          resolution = -1;

          # shape to use when clientside cursors are being magnified
          # see the shape-name property of shape rules for possible names
          # specifying clientside will use the actual shape, but will be pixelated
          fallback = "clientside";
        };
      };
    })

    (lib.optionalAttrs hyprland.trails.enable {
      hyprtrails = {
        color = "rgb(${color.hex.accent})";
      };
    })

    (lib.optionalAttrs hyprland.hyprspace.enable {
      overview = {};
    })
  ];
}
