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
      systemd.enable = false; # TODO: Enable once configured

      # AGS libs go here
      extraPackages = [];

      # This should symlink
      configDir = ./config;
    };

    # The ags module doesn't expose the "astal" cli tool
    home.packages = [inputs.ags.packages.${pkgs.system}.io];

    home.file = {
      # NOTE: Keep this symlinked as long as I'm configuring
      # ".config/ags".source = config.lib.file.mkOutOfStoreSymlink "${config.paths.nixflake}/home/modules/ags/config";

      # LSP typechecking support (use ags --init)
      # ".config/ags/types".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.ags}/share/com.github.Aylur.ags/types";
    };
  };
}
