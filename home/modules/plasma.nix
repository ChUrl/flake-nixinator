# TODO: KDE Connect config
# TODO: Plasma Configuration (https://github.com/pjones/plasma-manager)
{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.plasma;
in {
  options.modules.plasma = {
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [];
  };
}
