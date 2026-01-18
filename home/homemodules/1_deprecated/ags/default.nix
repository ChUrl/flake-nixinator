{
  inputs,
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) ags;
in {
  options.homemodules.ags = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf ags.enable {
    programs.ags = {
      enable = true;
      systemd.enable = false; # Currently only supports GTK3, use own service below

      # AGS libs go here
      extraPackages = [
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.apps
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.auth
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.battery
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.bluetooth
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.cava
        # inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.greet
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.mpris
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.network
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.notifd
        # inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.powerprofiles
        # inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.river
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.tray
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.wireplumber
      ];

      # This should symlink but doesn't, it copies the files :/
      # configDir = ./config;
    };

    # The ags module doesn't expose the "astal" cli tool or extraPackages
    home.packages =
      [
        inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.io
      ]
      ++ config.programs.ags.extraPackages;

    systemd.user.services.ags = {
      Unit = {
        Description = "AGS - Tool for scaffolding Astal+TypeScript projects.";
        Documentation = "https://github.com/Aylur/ags";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session-pre.target"];
      };

      Service = {
        ExecStart = "${config.programs.ags.finalPackage}/bin/ags run --gtk4";
        Restart = "on-failure";
        KillMode = "mixed";
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    home.file = {
      # Keep this symlinked as long as I'm configuring (not required anymore since I can start AGS locally)
      # ".config/ags".source = config.lib.file.mkOutOfStoreSymlink "${config.paths.nixflake}/home/modules/ags/config";

      # NOTE: Don't symlink to ~/.config/ags/colors.scss, since that is already used by configDir
      ".config/_colors.scss".text = with config.homemodules.color.hex; ''
        $dark-rosewater: #${dark.rosewater};
        $dark-flamingo: #${dark.flamingo};
        $dark-pink: #${dark.pink};
        $dark-mauve: #${dark.mauve};
        $dark-red: #${dark.red};
        $dark-maroon: #${dark.maroon};
        $dark-peach: #${dark.peach};
        $dark-yellow: #${dark.yellow};
        $dark-green: #${dark.green};
        $dark-teal: #${dark.teal};
        $dark-sky: #${dark.sky};
        $dark-sapphire: #${dark.sapphire};
        $dark-blue: #${dark.blue};
        $dark-lavender: #${dark.lavender};

        $dark-text: #${dark.text};
        $dark-subtext1: #${dark.subtext1};
        $dark-subtext0: #${dark.subtext0};
        $dark-overlay2: #${dark.overlay2};
        $dark-overlay1: #${dark.overlay1};
        $dark-overlay0: #${dark.overlay0};
        $dark-surface2: #${dark.surface2};
        $dark-surface1: #${dark.surface1};
        $dark-surface0: #${dark.surface0};
        $dark-base: #${dark.base};
        $dark-mantle: #${dark.mantle};
        $dark-crust: #${dark.crust};

        $light-rosewater: #${light.rosewater};
        $light-flamingo: #${light.flamingo};
        $light-pink: #${light.pink};
        $light-mauve: #${light.mauve};
        $light-red: #${light.red};
        $light-maroon: #${light.maroon};
        $light-peach: #${light.peach};
        $light-yellow: #${light.yellow};
        $light-green: #${light.green};
        $light-teal: #${light.teal};
        $light-sky: #${light.sky};
        $light-sapphire: #${light.sapphire};
        $light-blue: #${light.blue};
        $light-lavender: #${light.lavender};

        $light-text: #${light.text};
        $light-subtext1: #${light.subtext1};
        $light-subtext0: #${light.subtext0};
        $light-overlay2: #${light.overlay2};
        $light-overlay1: #${light.overlay1};
        $light-overlay0: #${light.overlay0};
        $light-surface2: #${light.surface2};
        $light-surface1: #${light.surface1};
        $light-surface0: #${light.surface0};
        $light-base: #${light.base};
        $light-mantle: #${light.mantle};
        $light-crust: #${light.crust};
      '';
    };
  };
}
