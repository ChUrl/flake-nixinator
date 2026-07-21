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
  inherit (config.homemodules) hyprland color;

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
  options.homemodules.hyprland = import ./options.nix {inherit lib mylib;};

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
      iconTheme.package = lib.mkDefault color.iconPackage;
      iconTheme.name = color.iconTheme;
    };

    homemodules = {
      hyprpanel.enable = hyprland.hyprpanel.enable;
    };

    home = {
      pointerCursor = {
        gtk.enable = lib.mkDefault true;
        x11.enable = lib.mkDefault true;
        package = lib.mkDefault color.cursorPackage;
        name = color.cursor;
        size = color.cursorSize;
      };

      packages = with pkgs; [
        hyprpicker # Color picker
        # hyprpolkitagent # Ugly polkit authentication GUI
        hyprland-qt-support
        hyprsunset # Blue light filter

        wl-clipboard
        # clipman # Clipboard manager (wl-paste)
        libnotify
        inotify-tools # Includes inotifywait

        # ncpamixer # Audio control
        slurp # Region selector for screensharing
        grim # Grab images from compositor

        # Deps for Qt5 and Qt6 apps (e.g., Nextcloud)
        qt5.qtwayland
        qt6.qtwayland

        # xwayland
        # wayland-protocols
      ];
    };

    programs = {
      hyprlock = import ./hyprlock.nix {inherit config hyprland color;};
    };

    services = {
      hypridle = import ./hypridle.nix {inherit config hyprland color;};
    };

    # Make sure the units only start when using Hyprland
    systemd.user.services.hypridle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];
    systemd.user.services.hypridle.Unit.After = lib.mkForce ["hyprland-session.target"];
    systemd.user.services.hypridle.Unit.PartOf = lib.mkForce ["hyprland-session.target"];
    systemd.user.services.elephant.Install.WantedBy = lib.mkForce ["hyprland-session.target" "graphical-session.target"];
    systemd.user.services.elephant.Unit.After = lib.mkForce ["hyprland-session.target" "graphical-session.target"];
    systemd.user.services.elephant.Unit.PartOf = lib.mkForce ["hyprland-session.target" "graphical-session.target"];

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      configType = "hyprlang";

      systemd.enable = true; # Enable hyprland-session.target
      systemd.variables = ["--all"]; # Import PATH into systemd
      xwayland.enable = true;

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
