{
  inputs,
  hostname,
  username,
  lib,
  mylib,
  config,
  nixosConfig,
  pkgs,
  ...
}:
# Here goes the stuff that will only be enabled on the desktop
rec {
  imports = [
    ../../modules
  ];

  config = {
    # Use mkForce to not pull the entire ballast from /home/christoph/default.nix

    modules = lib.mkForce {
      flatpak.enable = false;
      fish.enable = true;
      helix.enable = true;
      nnn.enable = true;
    };

    home.packages = with pkgs; lib.mkForce [
      ffmpeg_5-full # v5, including ffplay
      imagemagick # Convert image (magic)
      gdu # Alternative to du-dust (I like it better)
      duf # Disk usage analyzer (for all disk overview)
      fd # find alternative
      sd # sed alternative
      fclones # duplicate file finder
      unrar
      p7zip
      ffmpegthumbnailer # Video thumbnails
      mediainfo
      tree # Folder preview
      progress
      wget # download that shit
      cachix
    ];

    programs = lib.mkForce {
      home-manager.enable = true;
      
      bat = {
        enable = true;

        themes = {
          catppuccin-latte = builtins.readFile (pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
            sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
          } + "/Catppuccin-latte.tmTheme");
        };

        config = {
          theme = "catppuccin-latte";
        };
      };

      exa.enable = true;

      ssh.enable = true;

      starship = let
        flavour = "latte"; # One of `latte`, `frappe`, `macchiato`, or `mocha`
      in {
        enable = true;
        enableFishIntegration = config.modules.fish.enable;
        settings =
          {
            # Other config here
            format = "$all"; # Remove this line to disable the default prompt format
            palette = "catppuccin_${flavour}";
          }
          // builtins.fromTOML (builtins.readFile
            (pkgs.fetchFromGitHub
              {
                owner = "catppuccin";
                repo = "starship";
                rev = "3e3e54410c3189053f4da7a7043261361a1ed1bc";
                sha256 = "sha256-soEBVlq3ULeiZFAdQYMRFuswIIhI9bclIU8WXjxd7oY=";
              }
              + /palettes/${flavour}.toml));
      };

      yt-dlp.enable = true;
    };
  };
}
