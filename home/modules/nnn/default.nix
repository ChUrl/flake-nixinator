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
        b = "~/";
        c = "~/.config";
        d = "~/Documents";
        D = "~/Downloads";
        # h = "~/Notes/HHU";
        # l = "~/Local";
        # m = "~/Mount";
        # n = "~/Notes";
        N = "~/NixFlake";
        # p = "~/Pictures";
        t = "~/Notes/TU";
        # v = "~/Videos";
      };

      plugins = {
        mappings = {
          c = "fzcd";
          d = "dragdrop";
          # f = "finder";
          j = "autojump";
          # k = "kdeconnect";
          p = "preview-tui";
          # s = "suedit";
          # s = "x2sel";
          v = "imgview";
        };

        src =
          (pkgs.fetchFromGitHub {
            owner = "jarun";
            repo = "nnn";
            rev = "33126ee813ed92726aa66295b9771ffe93e7ff0a";
            sha256 = "sha256-g19uI36HyzTF2YUQKFP4DE2ZBsArGryVHhX79Y0XzhU=";
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
