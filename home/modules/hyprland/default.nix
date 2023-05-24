{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.hyprland;
in {
  options.modules.hyprland = import ./options.nix {inherit lib mylib;};

  config = let
    # Taken from https://github.com/Ruixi-rebirth/flakes/blob/main/modules/programs/wayland/waybar/workspace-patch.nix
    hyprctl = "${pkgs.hyprland}/bin/hyprctl";
    workspaces-patch = pkgs.writeTextFile {
      name = "waybar-hyprctl.diff";
      text = ''
        diff --git a/src/modules/wlr/workspace_manager.cpp b/src/modules/wlr/workspace_manager.cpp
        index 6a496e6..a689be0 100644
        --- a/src/modules/wlr/workspace_manager.cpp
        +++ b/src/modules/wlr/workspace_manager.cpp
        @@ -511,7 +511,9 @@ auto Workspace::handle_clicked(GdkEventButton *bt) -> bool {
           if (action.empty())
             return true;
           else if (action == "activate") {
        -    zext_workspace_handle_v1_activate(workspace_handle_);
        +    // zext_workspace_handle_v1_activate(workspace_handle_);
        +    const std::string command = "${hyprctl} dispatch workspace " + name_;
        +    system(command.c_str());
           } else if (action == "close") {
             zext_workspace_handle_v1_remove(workspace_handle_);
           } else {
      '';
    };

    waybar-hyprland = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      patches = (oldAttrs.patches or []) ++ [workspaces-patch];
    });
  in
    mkIf cfg.enable {
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

      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };

      home.sessionVariables = {
        # QT_QPA_PLATFORMTHEME = "qt5ct";
      };

      # Polkit
      home.file.".config/hypr/polkit.conf".text = ''exec-once = ${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1'';

      # Monitors for different systems
      home.file.".config/hypr/monitors.conf".text = let
        # Used by mapAttrs
        mkMonitor = name: conf: "monitor = ${name}, ${toString conf.width}x${toString conf.height}@${toString conf.rate}, ${toString conf.x}x${toString conf.y}, ${toString conf.scale}";
        # Makes "HDMI-A-1" = {width=2560;...} to "HDMI-A-1" = "monitor = ..."
        monitors-attrs = mapAttrs mkMonitor cfg.monitors;
        # Makes "HDMI-A-1" = "monitor = ..." to "monitor = ..."
        monitors-values = attrValues monitors-attrs;
        monitors = concatStringsSep "\n" monitors-values;
      in
        monitors;

      # Bind workspaces to monitors
      home.file.".config/hypr/workspaces.conf".text = let
        # Make a single monitor string
        mkWorkspace = monitor: workspace: "workspace = ${toString workspace}, monitor:${toString monitor}";
        # Used by mapAttrs
        mkWorkspaces = monitor: workspace-list: map (mkWorkspace monitor) workspace-list;
        # Makes {"HDMI-A-1" = [1 2]; ...} to {"HDMI-A-1" = ["monitor = ..." "monitor = ..."] ...}
        workspaces-attrs = mapAttrs mkWorkspaces cfg.workspaces;
        # Makes {"HDMI-A-1" = [1 2]; ...} to ["monitor = ..." "monitor = ..." ...]
        workspaces-values = concatLists (attrValues workspaces-attrs);
        workspaces = concatStringsSep "\n" workspaces-values;
      in
        workspaces;

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
        execs-list = map mkExec (cfg.autostart ++ always-exec);
        execs = concatStringsSep "\n" execs-list;
      in
        execs;

      # Assign windows to workspaces
      home.file.".config/hypr/workspacerules.conf".text = let
        mkWorkspaceRule = workspace: class: "windowrulev2 = workspace ${workspace}, class:^(${class})$";
        mkWorkspaceRules = workspace: class-list: map (mkWorkspaceRule workspace) class-list;
        workspace-rules-attrs = mapAttrs mkWorkspaceRules cfg.workspacerules;
        workspace-rules-values = concatLists (attrValues workspace-rules-attrs);
        workspace-rules = concatStringsSep "\n" workspace-rules-values;
      in
        workspace-rules;

      # Make windows float
      home.file.".config/hypr/floatingrules.conf".text = let
        mkFloatingRule = attrs:
          "windowrulev2 = float"
          + (lib.optionalString (hasAttr "class" attrs) ", class:^(${attrs.class})$")
          + (lib.optionalString (hasAttr "title" attrs) ", title:^(${attrs.title})$");
        floating-rules-list = map mkFloatingRule cfg.floating;
        floating-rules = concatStringsSep "\n" floating-rules-list;
      in
        floating-rules;

      # Make windows translucent
      home.file.".config/hypr/translucentrules.conf".text = let
        opacity = 0.8;

        mkTranslucentRule = class: "windowrulev2 = opacity ${toString opacity} ${toString opacity}, class:^(${class})$";
        translucent-rules-list = map mkTranslucentRule cfg.transparent;
        translucent-rules = concatStringsSep "\n" translucent-rules-list;
      in
        translucent-rules;

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

      # TODO: I want to generate the config in ~/.config/waybar through nix again
      #       to allow adding waybar options to the hyprland module (like monitor and style).
      #       The goal is to set the style completely through nix...
      home.file.".config/hypr/waybar-reload.conf".text = let
        waybar-reload = pkgs.writeScript "waybar-reload" ''
          #! ${pkgs.bash}/bin/bash

          trap "${pkgs.procps}/bin/pkill waybar" EXIT

          while true; do
              ${waybar-hyprland}/bin/waybar -c $HOME/NixFlake/config/waybar/config -s $HOME/NixFlake/config/waybar/style.css &
              ${pkgs.inotifyTools}/bin/inotifywait -e create,modify $HOME/NixFlake/config/waybar/config $HOME/NixFlake/config/waybar/style.css
              ${pkgs.procps}/bin/pkill waybar
          done
        '';
      in ''
        exec-once = ${waybar-reload}
      '';

      # Set wallpaper for each configured monitor
      home.file.".config/hypr/hyprpaper.conf".text = let
        mkWallpaper = monitor: "wallpaper = ${monitor}, ${config.home.homeDirectory}/NixFlake/wallpapers/${cfg.theme}.png";
        wallpapers-list = map mkWallpaper (attrNames cfg.monitors);
        wallpapers = concatStringsSep "\n" wallpapers-list;
      in ''
        preload = ~/NixFlake/wallpapers/${cfg.theme}.png
        ${wallpapers}
      '';

      home.activation = {
        # NOTE: Keep the hyprland/waybar config symlinked, to allow easy changes with hotreload
        # TODO: Don't symlink at all, why not just tell Hyprland where the config is? Much easier
        linkHyprlandConfig =
          hm.dag.entryAfter ["writeBoundary"]
          (mkLink "~/NixFlake/config/hyprland/hyprland.conf" "~/.config/hypr/hyprland.conf");
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
        };
      };

      programs = {
        rofi = {
          enable = true;
          package = pkgs.rofi-wayland;
          plugins = [
            pkgs.keepmenu # TODO: Rofi KeepassXC frontend
          ];

          # NOTE: Don't use this, use the configfile for hot-reload
          # terminal = "${pkgs.kitty}/bin/kitty";
          # font = "JetBrains Mono 14";
          # theme =
          # extraConfig = '''';
        };

        waybar = {
          enable = true;
          package = waybar-hyprland;

          systemd = {
            enable = false; # Gets started by hyprland
          };
        };
      };
    };
}
