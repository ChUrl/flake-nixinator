{ config, nixosConfig, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.fish;
in {

  options.modules.fish = {
    enable = mkEnableOpt "Fish";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;

      # TODO:
      # functions = {};

      # TODO:
      # plugins = [];

      shellAbbrs = let
        # Only add " | bat" if bat is installed
        batify = command: command + (optionalString config.programs.bat.enable " | bat");
        # Same as above but with args for bat
        batifyWithArgs = command: args: command + (optionalString config.programs.bat.enable (" | bat " + args));

        # NOTE: These can be used for my config.modules and for HM config.programs, as both of these add the package to home.packages
        hasHomePackage = package: (contains config.home.packages package);
        # Only add fish abbr if package is installed
        abbrify = package: abbr: (optionalAttrs (hasHomePackage package) abbr);
      in mkMerge [
        # Default abbrs, always available
        {
          # Shell basic
          c = "clear";
          q = "exit";

          # Fish
          h = batifyWithArgs "history" "-l fish"; # -l fish sets syntax highlighting to fish
          listabbrs = batifyWithArgs "abbr" "-l fish";

          # tools
          cd = "z"; # zoxide for quickjump to previously visited locations
          mkdir = "mkdir -p"; # also create parents (-p)
          blk = batify "lsblk -o NAME,LABEL,UUID,FSTYPE,SIZE,FSUSE%,MOUNTPOINT,MODEL";
          grep = "grep --color=auto -E"; # grep with extended regex
          watch = "watch -d -c -n -0.5";

          # systemd
          failed = "systemctl --failed";
          errors = "journalctl -p 3 -xb";
          kernelerrors = "journalctl -p 3 -xb -k";
          uniterrors = "journalctl -xb --unit=";
          useruniterrors = "journalctl -xb --user-unit=";

          # ssh locations
          xxhamster = "TERM=ansi ssh christoph@217.160.142.51";
        }

        # Abbrs only available if package is installed
        (abbrify pkgs.btop { top = "btop"; })
        (abbrify pkgs.duf {
          df = "duf";
          disksummary = "duf";
        })
        (abbrify pkgs.exa {
          ls = "exa --color always --group-directories-first -F --git --icons"; # color-ls
          lsl = "exa --color always --group-directories-first -F -l --git --icons";
          lsa = "exa --color always --group-directories-first -F -l -a --git --icons";
          tre = "exa --color always --group-directories-first -F -T -L 2 ---icons";
        })
        (abbrify pkgs.fd { find = "fd"; })
        (abbrify pkgs.fzf { fuzzy = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"; })
        (abbrify pkgs.gdu {
          du = "gdu";
          storageanalysis = "gdu";
        })
        (abbrify pkgs.git {
          gs = "git status";
          gcm = "git commit -m";
          ga = "git add";
          glg = "git log --graph --decorate --oneline";
          gcl = "git clone";
        })
        (abbrify pkgs.gping { ping = "gping"; })
        (abbrify pkgs.lazygit { lg = "lazygit"; })
        (abbrify pkgs.protonvpn-cli {
          vpnat = "protonvpn-cli c --cc at";
          vpnch = "protonvpn-cli c --cc ch";
          vpnlu = "protonvpn-cli c --cc lu";
          vpnus = "protonvpn-cli c --cc us";
          vpnhk = "protonvpn-cli c --cc hk";
          vpnkr = "protonvpn-cli c --cc kr";
          vpnoff = "protonvpn-cli d";
        })
        (abbrify pkgs.ranger { r = "ranger --choosedir=$HOME/.rangerdir; set LASTDIR (cat $HOME/.rangerdir); cd $LASTDIR"; })
        (abbrify pkgs.rsync {
          cp = "rsync -ahv --inplace --partial --info=progress2";
          rsync = "rsync -ahv --inplace --partial --info=progress2";
        })
        (abbrify pkgs.sd { sed = "sd"; })
        (abbrify pkgs.yt-dlp {
          mp4 = "yt-dlp -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' --recode-video mp4"; # the -f options are yt-dlp defaults
          mp3 = "yt-dlp -f 'ba' --extract-audio --audio-format mp3";
        })
      ];

      shellInit = ''
        set -e fish_greeting
      '';
    };
  };
}
