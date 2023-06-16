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
    home.sessionVariables = {
      # NNN_TERMINAL = "alacritty";
      NNN_PAGER = "bat";
      # NNN_FIFO = "/tmp/nnn.fifo"; # For nnn preview
    };

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
        h = "~/Notes/HHU";
        l = "~/Local";
        m = "~/Mount";
        n = "~/Notes";
        N = "~/NixFlake";
        p = "~/Pictures";
        t = "~/Notes/TU";
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
            rev = "26d5b5c6141f0424869db8ca47e1d370f7b898d5";
            sha256 = "sha256-a2Fq17mS/m7wRvPc1EkUun198SoeRZtJEABGjPWW+6E=";
          })
          + "/plugins";
      };
    };

    xdg.desktopEntries.nnn = {
      type = "Application";
      name = "nnn";
      comment = "Terminal file manager";
      exec = "nnn";
      terminal = true;
      icon = "nnn";
      mimeType = ["inode/directory"];
      categories = ["System" "FileTools" "FileManager" "ConsoleOnly"];
      # keywords = ["File" "Manager" "Management" "Explorer" "Launcher"];
    };
  };
}
