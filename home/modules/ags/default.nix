{
  inputs,
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) ags;
in {
  options.modules.ags = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf ags.enable {
    programs.ags = {
      enable = true;
      systemd.enable = false; # Currently only supports GTK3, use own service below

      # AGS libs go here
      extraPackages = [
        inputs.ags.packages.${pkgs.system}.apps
        inputs.ags.packages.${pkgs.system}.auth
        inputs.ags.packages.${pkgs.system}.battery
        inputs.ags.packages.${pkgs.system}.bluetooth
        inputs.ags.packages.${pkgs.system}.cava
        # inputs.ags.packages.${pkgs.system}.greet
        inputs.ags.packages.${pkgs.system}.hyprland
        inputs.ags.packages.${pkgs.system}.mpris
        inputs.ags.packages.${pkgs.system}.network
        inputs.ags.packages.${pkgs.system}.notifd
        # inputs.ags.packages.${pkgs.system}.powerprofiles
        # inputs.ags.packages.${pkgs.system}.river
        inputs.ags.packages.${pkgs.system}.tray
        inputs.ags.packages.${pkgs.system}.wireplumber
      ];

      # This should symlink
      configDir = ./config;
    };

    # The ags module doesn't expose the "astal" cli tool or extraPackages
    home.packages =
      [
        inputs.ags.packages.${pkgs.system}.io
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
      # NOTE: Keep this symlinked as long as I'm configuring
      # ".config/ags".source = config.lib.file.mkOutOfStoreSymlink "${config.paths.nixflake}/home/modules/ags/config";

      # LSP typechecking support (use ags --init)
      # ".config/ags/types".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.ags}/share/com.github.Aylur.ags/types";
    };
  };
}
