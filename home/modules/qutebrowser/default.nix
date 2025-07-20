{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) qutebrowser color;
in {
  options.modules.qutebrowser = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf qutebrowser.enable {
    programs.qutebrowser = {
      enable = true;

      loadAutoconfig = false; # Load settings set from GUI

      quickmarks = {
        nixpkgs = "https://github.com/NixOS/nixpkgs";
        home-manager = "https://github.com/nix-community/home-manager";
      };

      # greasemonkey = [];

      # Map keys to other keys
      # keyMappings = {};

      enableDefaultBindings = true;

      # Map keys to commands
      keyBindings = {
        # normal = {
        #   "<Ctrl-v>" = "spawn mpv {url}";
        #   ",p" = "spawn --userscript qute-pass";
        #   ",l" = ''config-cycle spellcheck.languages ["en-GB"] ["en-US"]'';
        #   "<F1>" = mkMerge [
        #     "config-cycle tabs.show never always"
        #     "config-cycle statusbar.show in-mode always"
        #     "config-cycle scrolling.bar never always"
        #   ];
        # };
        # prompt = {
        #   "<Ctrl-y>" = "prompt-yes";
        # };
      };

      searchEngines = {
        w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
        aw = "https://wiki.archlinux.org/?search={}";
        nw = "https://wiki.nixos.org/index.php?search={}";
        g = "https://www.google.com/search?hl=en&q={}";
      };

      # Same keys as qutebrowser.settings, but per domain
      # perDomainSettings = {
      #   "github.com".colors.webpage.darkmode.enabled = false;
      # };

      extraConfig = builtins.concatStringsSep "\n" [
        (builtins.readFile ./extraConfig.py)
        (builtins.readFile ./theme.py)
      ];
    };
  };
}
