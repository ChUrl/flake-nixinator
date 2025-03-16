{
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
      systemd.enable = true;

      # configDir = ./config;
    };

    home.file = {
      # NOTE: Keep this symlinked as long as I'm configuring
      ".config/ags".source = config.lib.file.mkOutOfStoreSymlink "${config.paths.nixflake}/home/modules/ags/config";

      # LSP typechecking support (use ags --init)
      # ".config/ags/types".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.ags}/share/com.github.Aylur.ags/types";
    };
  };
}
