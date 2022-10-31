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
      # functions = {};
      # plugins = [];
      shellAbbrs = let
        hasBat = config.programs.bat.enable;
        batify = string: string + (optionalString hasBat " | bat");
      in mkMerge [
        {
          c = "clear";
          q = "exit";
          h = batify "history";

          # tools
          cd = "z";
          # cp = "cp -puri"; # TODO: Is rsync a good replacement?
          mkdir = "mkdir -p";
          blk = batify "lsblk -o NAME,LABEL,UUID,FSTYPE,SIZE,FSUSE%,MOUNTPOINT,MODEL";
          grep = "grep --color=auto -E";
          watch = "watch -d -c -n -0.5";

          # git
          gs = "git status";
          gcm = "git commit -m";
          ga = "git add";
          glg = "git log --graph --decorate --oneline";
          gcl = "git clone";

          failed = "systemctl --failed";
          errors = "journalctl -p 3 -xb";
          kerrors = "journalctl -p 3 -xb -k";

          xxhamster = "TERM=ansi ssh christoph@217.160.142.51";

          mp4 = "yt-dlp -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' --recode-video mp4"; # the -f options are yt-dlp defaults
          mp3 = "yt-dlp -f 'ba' --extract-audio --audio-format mp3";
        }

        (optionalAttrs (contains config.home.packages pkgs.lazygit) { lg = "lazygit"; })
        (optionalAttrs (contains config.home.packages pkgs.gping) { ping = "gping"; })
        (optionalAttrs (contains config.home.packages pkgs.duf) { df = "duf"; })
        (optionalAttrs (contains config.home.packages pkgs.gdu) { du = "gdu"; })
        (optionalAttrs (contains config.home.packages pkgs.fzf) {
          fz = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
        })

        (optionalAttrs (contains config.home.packages pkgs.rsync) {
          cp = "rsync -ahv --inplace --partial --info=progress2";
          rsync = "rsync -ahv --inplace --partial --info=progress2";
        })

        (optionalAttrs config.programs.exa.enable {
          ls = "exa --color always --group-directories-first -F --git --icons"; # color-ls
          lsl = "exa --color always --group-directories-first -F -l --git --icons";
          lsa = "exa --color always --group-directories-first -F -l -a --git --icons";
          tre = "exa --color always --group-directories-first -F -T -L 2 ---icons";
        })

        (optionalAttrs config.modules.ranger.enable {
          r = "ranger --choosedir=$HOME/.rangerdir; set LASTDIR (cat $HOME/.rangerdir); cd $LASTDIR";
        })

        (optionalAttrs (contains config.home.packages pkgs.protonvpn-cli) {
          vpnat = "protonvpn-cli c --cc at";
          vpnch = "protonvpn-cli c --cc ch";
          vpnlu = "protonvpn-cli c --cc lu";
          vpnus = "protonvpn-cli c --cc us";
          vpnhk = "protonvpn-cli c --cc hk";
          vpnkr = "protonvpn-cli c --cc kr";
          vpnoff = "protonvpn-cli d";
        })
      ];

      shellInit = ''
        set -e fish_greeting
      '';
    };

    # I put these programs here as they all have fish integration and are connected to the shell,
    # don't know if I will keep it that way

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    # NOTE: If error occurs after system update on fish init run "ssh-add"
    programs.keychain = {
      enable = true;
      enableFishIntegration = true;
      enableXsessionIntegration = true;
      agents = [ "ssh" ];
      keys = [ "id_ed25519" ];
    };

    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
