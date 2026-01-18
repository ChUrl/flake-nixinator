# TODO: Expose some settings
{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) nnn;
in {
  options.modules.nnn = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf nnn.enable {
    home.sessionVariables = {
      # NNN_TERMINAL = "alacritty";
      # NNN_FIFO = "/tmp/nnn.fifo"; # For nnn preview

      NNN_PAGER = "bat";
      NNN_OPENER = "xdg-open";
      NNN_ARCHIVE = "\\.(7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)$";
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
