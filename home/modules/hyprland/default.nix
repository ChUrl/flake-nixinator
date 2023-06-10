# TODO: The keys to reset the workspaces need to depend on actual workspace config
# TODO: Many of the text file generations can be made simpler with pipe and concatLines functions...
{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  cfg = config.modules.hyprland;
in {
  options.modules.hyprland = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = nixosConfig.programs.hyprland.enable;
        message = "Can't enable Hyprland module with Hyprland disabled!";
      }
    ];

    gtk = {
      enable = true;
      iconTheme.package = pkgs.papirus-icon-theme;
      iconTheme.name = "Papirus";
    };

    # TODO: catppuccin-cursors
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      # package = pkgs.catppuccin-cursors.latteMauve;
      # name = "Catppuccin-Latte-Mauve-Cursors";
      size = 16;
    };

    home.packages = with pkgs; [
      hyprpaper # Wallpaper setter
      hyprpicker # Color picker

      wl-clipboard
      clipman # Clipboard manager (wl-paste)

      imv # Image viewer
      moc # Audio player
      ncpamixer # ncurses pavucontrol
      slurp # Region selector for screensharing
      grim # Grab images from compositor

      xfce.thunar
      xfce.tumbler # Thunar thumbnails
      libsForQt5.polkit-kde-agent
    ];

    services = {
      # Notification service
      dunst = {
        enable = true;

        iconTheme.package = pkgs.papirus-icon-theme;
        iconTheme.name = "Papirus";

        settings = {
          global = {
            monitor = 1;
            font = "JetBrains Nerd Font Mono 11";
            offset = "20x20";
            frame_color = "#1E66F5";
            frame_width = 2;
            corner_radius = 5;
            separator_color = "frame";
          };

          urgency_low = {
            background = "#EFF1F5";
            foreground = "#4C4F69";
          };

          urgency_normal = {
            background = "#EFF1F5";
            foreground = "#4C4F69";
          };

          urgency_critical = {
            background = "#EFF1F5";
            foreground = "#4C4F69";
            frame_color = "#FE640B";
          };
        };
      };
    };

    home.sessionVariables = {
    };

    #
    # Generate many individual config files from the options
    #

    # Polkit
    home.file.".config/hypr/polkit.conf".text = ''
      exec-once = ${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1
    '';

    # Monitors for different systems
    home.file.".config/hypr/monitors.conf".text = let
      mkMonitor = name: conf: "monitor = ${name}, ${toString conf.width}x${toString conf.height}@${toString conf.rate}, ${toString conf.x}x${toString conf.y}, ${toString conf.scale}";
    in
      lib.pipe cfg.monitors [
        (builtins.mapAttrs mkMonitor)
        builtins.attrValues
        (builtins.concatStringsSep "\n")
      ];

    # Bind workspaces to monitors
    home.file.".config/hypr/workspaces.conf".text = let
      mkWorkspace = monitor: workspace: "workspace = ${toString workspace}, monitor:${toString monitor}";
      mkWorkspaces = monitor: workspace-list: map (mkWorkspace monitor) workspace-list;
    in
      lib.pipe cfg.workspaces [
        (builtins.mapAttrs mkWorkspaces)
        builtins.attrValues
        builtins.concatLists
        (builtins.concatStringsSep "\n")
      ];

    # Keybindings
    home.file.".config/hypr/keybindings.conf".text = let
      always-bind = {
        # Hyprland control
        "$mainMod, Q" = ["killactive"];
        "$mainMod, V" = ["togglefloating"];
        "$mainMod, F" = ["fullscreen"];
        "$mainMod, C" = ["exec, clipman pick --tool=rofi"];
        "$mainMod, G" = ["togglegroup"];
        "ALT, tab" = ["changegroupactive"];
      };

      mkBind = key: action: "bind = ${key}, ${action}";
      mkBinds = key: actions: builtins.map (mkBind key) actions;
      binds = lib.pipe (lib.mergeAttrs cfg.keybindings.bindings always-bind) [
        (builtins.mapAttrs mkBinds)
        builtins.attrValues
        builtins.concatLists
        (builtins.concatStringsSep "\n")
      ];
    in ''
      $mainMod = ${cfg.keybindings.main-mod}
      ${binds}
    '';

    # Autostart applications
    home.file.".config/hypr/autostart.conf".text = let
      # Stuff that is not negotiable
      always-exec = [
        "dunst" # Notifications
        "hyprpaper"
        "wl-paste -t text --watch clipman store --no-persist"
        "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
        "hyprctl setcursor Bibata-Modern-Classic 16"
      ];

      mkExec = prog: "exec-once = ${prog}";
    in
      lib.pipe (cfg.autostart ++ always-exec) [
        (builtins.map mkExec)
        (builtins.concatStringsSep "\n")
      ];

    # Assign windows to workspaces
    home.file.".config/hypr/workspacerules.conf".text = let
      mkWorkspaceRule = workspace: class: "windowrulev2 = workspace ${workspace}, class:^(${class})$";
      mkWorkspaceRules = workspace: class-list: map (mkWorkspaceRule workspace) class-list;
    in
      lib.pipe cfg.workspacerules [
        (builtins.mapAttrs mkWorkspaceRules)
        builtins.attrValues
        builtins.concatLists
        (builtins.concatStringsSep "\n")
      ];

    # Make windows float
    home.file.".config/hypr/floatingrules.conf".text = let
      mkFloatingRule = attrs:
        "windowrulev2 = float"
        + (lib.optionalString (builtins.hasAttr "class" attrs) ", class:^(${attrs.class})$")
        + (lib.optionalString (builtins.hasAttr "title" attrs) ", title:^(${attrs.title})$");
    in
      lib.pipe cfg.floating [
        (builtins.map mkFloatingRule)
        (builtins.concatStringsSep "\n")
      ];

    # Make windows translucent
    home.file.".config/hypr/translucentrules.conf".text = let
      opacity = 0.8;
      mkTranslucentRule = class: "windowrulev2 = opacity ${toString opacity} ${toString opacity}, class:^(${class})$";
    in
      lib.pipe cfg.transparent [
        (builtins.map mkTranslucentRule)
        (builtins.concatStringsSep "\n")
      ];

    # Set wallpaper for each configured monitor
    home.file.".config/hypr/hyprpaper.conf".text = let
      mkWallpaper = monitor: "wallpaper = ${monitor}, ${config.home.homeDirectory}/NixFlake/wallpapers/${cfg.theme}.png";
      wallpapers = lib.pipe cfg.monitors [
        builtins.attrNames
        (builtins.map mkWallpaper)
        (builtins.concatStringsSep "\n")
      ];
    in ''
      preload = ~/NixFlake/wallpapers/${cfg.theme}.png
      ${wallpapers}
    '';

    # Keyboard layout
    home.file.".config/hypr/input.conf".text = ''
      input {
          kb_layout = ${cfg.kb-layout}
          kb_variant = ${cfg.kb-variant}
          kb_model = pc104
          kb_options =
          kb_rules =

          follow_mouse = 1

          touchpad {
              natural_scroll = no
          }

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }
    '';

    home.activation = {
      # NOTE: Keep the hyprland config symlinked, to allow easy changes with hotreload
      # TODO: Don't symlink at all, why not just tell Hyprland where the config is? Much easier
      linkHyprlandConfig =
        lib.hm.dag.entryAfter ["writeBoundary"]
        (mylib.modules.mkLink "~/NixFlake/config/hyprland/hyprland.conf" "~/.config/hypr/hyprland.conf");
    };
  };
}
