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
  cfg = config.modules.rofi;
in {
  options.modules.rofi = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    programs.rofi = {
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
  };
}
