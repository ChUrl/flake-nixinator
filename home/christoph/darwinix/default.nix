{
  pkgs,
  nixosConfig,
  config,
  lib,
  mylib,
  username,
  inputs,
  ...
}: {
  config = let
    inherit (config.homemodules) color;
  in {
    paths = rec {
      nixflake = "${config.home.homeDirectory}/NixFlake";
      dotfiles = "${nixflake}/config";
    };

    homemodules = {
      bat.enable = true;

      color = {
        scheme = "catppuccin-mocha";
        accent = "mauve";
        accentHl = "pink";
        accentDim = "lavender";
        accentText = "base";

        font = "MonoLisa Alt Script";
      };

      fastfetch.enable = true;
      fish.enable = true;

      git = {
        enable = true;

        userName = "Christoph Urlacher";
        userEmail = "christoph.urlacher@protonmail.com";
        signCommits = true;
      };

      kitty.enable = true;
      lazygit.enable = true;

      neovim = {
        enable = true;
        alias = true;
        neovide = true;
      };

      ssh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
    };

    home = {
      inherit username;

      homeDirectory = "/Users/${config.home.username}";
      enableNixpkgsReleaseCheck = true;

      sessionVariables = {
        LANG = "en_US.UTF-8";
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
        TERMINAL = "kitty";
      };

      packages = with pkgs; [
        (ripgrep.override {withPCRE2 = true;})
        gdu
        duf
        sd
        fclones
        tealdeer
        killall
        atool
        exiftool
        ouch
        ffmpegthumbnailer
        mediainfo
        file
        unrar
        p7zip
        unzip
        progress
        tokei
        nix-search-tv
        nix-tree
        just

        ffmpeg-full
        imagemagick

        poppler-utils
        pdf2svg
        pandoc

        dig
        tcpdump
        gping
        curlie
        wget
        doggo
        rsync
        rclone
        httpie

        inputs.nps.packages.${pkgs.stdenv.hostPlatform.system}.default

        cachix

        # GUI
        ripdrag
        jellyfin-tui
      ];

      stateVersion = "25.11";
    };

    # TODO: Deduplicate with other configs
    programs = {
      home-manager.enable = true;

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      eza = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };

      fd.enable = true;

      fzf = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };

      navi = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };

      yt-dlp.enable = true;

      zoxide = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };
    };

    services = {
    };
  };
}
