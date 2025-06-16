{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) hyprpanel;
in {
  options.modules.hyprpanel = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf hyprpanel.enable {
    programs.hyprpanel = {
      enable = true;

      overwrite.enable = true;
    };
  };
}
