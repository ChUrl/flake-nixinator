{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.ags;
in {
  options.modules.ags = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    programs.ags = {
      enable = true;
      systemd.enable = true;

      # configDir = ./config;
    };

    home.file = {
      # NOTE: Keep this symlinked as long as I'm configuring
      ".config/ags".source = config.lib.file.mkOutOfStoreSymlink "/home/christoph/NixFlake/home/modules/ags/config";

      # LSP typechecking support (use ags --init)
      # ".config/ags/types".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.ags}/share/com.github.Aylur.ags/types";
    };
  };
}
