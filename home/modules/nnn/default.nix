# TODO: Expose some settings
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
  cfg = config.modules.nnn;
in {
  options.modules.nnn = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    programs.nnn = {
      package = pkgs.nnn.override {
        # These two are mutually exclusive
        withIcons = false;
        withNerdIcons = true;
      };
      enable = true;

      extraPackages = with pkgs; [
        xdragon # Drag and drop (why man)
      ];

      bookmarks = {
        c = "~/.config";
        d = "~/Documents";
        D = "~/Downloads";
        n = "~/Notes";
        t = "~/Notes/TU";
        h = "~/Notes/HHU";
        N = "~/NixFlake";
        p = "~/Pictures";
        v = "~/Videos";
      };

      plugins = {
        mappings = {
          c = "fzcd";
          d = "dragdrop";
          f = "finder";
          j = "autojump";
          k = "kdeconnect";
          p = "preview-tui";
          # s = "suedit";
          # s = "x2sel";
          v = "imgview";
        };

        src =
          (pkgs.fetchFromGitHub {
            owner = "jarun";
            repo = "nnn";
            rev = "aaf60b93d741ffff211902a10a159434629bbdb9";
            sha256 = "sha256-MwI3PqPfSyblURUAds4aVsw8WFBAgbDo5hqXMmRbAW4=";
          })
          + "/plugins";
      };
    };
  };
}
