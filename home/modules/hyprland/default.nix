{
  inputs,
  config,
  lib,
  mylib,
  pkgs,
  nixosConfig,
  username,
  ...
}: let
  inherit (config.modules) hyprland color;

  # Autostart programs
  always-exec = import ./autostart.nix {inherit lib pkgs config hyprland;};

  # Keybindings
  always-bind = import ./mappings.nix {inherit lib config hyprland;};

  # Mousebindings
  always-bindm = {
    "$mainMod, mouse:272" = ["movewindow"];
    "$mainMod, mouse:273" = ["resizewindow"];
  };
in {
  options.modules.hyprland = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf hyprland.enable {
    assertions = [
      {
        assertion = nixosConfig.programs.hyprland.enable;
        message = "Can't enable Hyprland module with Hyprland disabled!";
      }
      {
        assertion = builtins.hasAttr "hyprlock" nixosConfig.security.pam.services;
        message = "Can't enable Hyprland module without Hyprlock PAM service!";
      }
    ];

    gtk = {
      enable = true;
      iconTheme.package = pkgs.papirus-icon-theme;
      iconTheme.name = "Papirus";
    };

    home = {
      pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      packages = with pkgs; [
        hyprpaper # Wallpaper setter
        hyprpicker # Color picker
        # hyprpolkitagent # Ugly polkit authentication GUI
        hyprland-qt-support
        hyprsunset # Blue light filter

        wl-clipboard
        clipman # Clipboard manager (wl-paste)
        libnotify
        inotify-tools # Includes inotifywait

        ncpamixer # Audio control
        slurp # Region selector for screensharing
        grim # Grab images from compositor

        # Deps for Qt5 and Qt6 apps (e.g., Nextcloud)
        qt5.qtwayland
        qt6.qtwayland
      ];

      file = {
        ".config/hypr/keybindings.info".text = let
          fixupHomeDir = key:
            builtins.replaceStrings ["/home/${username}"] ["~"] key;

          fixupNixStore = key: let
            # The pattern has to match the entire string, otherwise it won't work
            matches = builtins.match ".*/nix/store/(.*)/.*" key;
          in
            if (matches == null)
            then key
            else builtins.replaceStrings matches ["..."] key;

          fixupNoMod = key:
            builtins.replaceStrings ["<-"] ["<"] key;

          mkBindHelpKey = key:
            builtins.replaceStrings ["$mainMod" " " ","] ["${hyprland.keybindings.main-mod}" "-" ""] key;

          mkBindHelpAction = action:
            builtins.replaceStrings [","] [""] action;

          mkBindHelp = key: action: "<${mkBindHelpKey key}>: ${mkBindHelpAction action}";

          mkBindsHelp = key: actions:
            actions
            |> builtins.map (mkBindHelp key)
            |> builtins.map fixupNoMod
            |> builtins.map fixupNixStore
            |> builtins.map fixupHomeDir;
        in
          (hyprland.keybindings.bindings // always-bind)
          |> builtins.mapAttrs mkBindsHelp
          |> builtins.attrValues
          |> builtins.concatLists
          |> builtins.concatStringsSep "\n";
      };
    };

    programs = {
      hyprlock = import ./hyprlock.nix {inherit config hyprland color;};

      # TODO: IMV shouldn't be part of the hyprland module
      imv = {
        enable = true;
        settings = {
          options = {
            background = "${color.hex.base}";
            overlay = true;
            overlay_font = "${color.font}:12";
            overlay_background_color = "${color.hex.accent}";
            overlay_text_color = "${color.hex.accentText}";
          };
        };
      };
    };

    services = {
      # TODO: Dunst shouldn't be part of the hyprland module
      dunst = import ./dunst.nix {inherit pkgs config hyprland color;};
      hypridle = import ./hypridle.nix {inherit config hyprland color;};
      hyprpaper = import ./hyprpaper.nix {inherit config hyprland color;};
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;

      systemd.enable = true; # Enable hyprland-session.target
      systemd.variables = ["--all"]; # Import PATH into systemd
      xwayland.enable = true;

      plugins = builtins.concatLists [
        (lib.optionals
          hyprland.bars.enable
          [inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars])
        (lib.optionals
          hyprland.dynamicCursor.enable
          [inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors])
        (lib.optionals
          hyprland.trails.enable
          [inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails])
        (lib.optionals
          hyprland.hyprspace.enable
          [inputs.hyprspace.packages.${pkgs.system}.Hyprspace])
      ];

      settings = import ./settings.nix {
        inherit
          lib
          config
          hyprland
          color
          always-exec
          always-bind
          always-bindm
          ;
      };
    };
  };
}
