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
      shellAbbrs = {
        c = "clear";
        q = "exit";
        h = "history | bat";
        r = "ranger --choosedir=$HOME/.rangerdir; set LASTDIR (cat $HOME/.rangerdir); cd $LASTDIR";

        cd = "z";
        cp = "cp -i";
        ls = "exa --color always --group-directories-first -F --git --icons"; # color-ls
        lsl = "exa --color always --group-directories-first -F -l --git --icons";
        lsa = "exa --color always --group-directories-first -F -l -a --git --icons";
        tre = "exa --color always --group-directories-first -F -T -L 2 ---icons";
        mkd = "mkdir -p";

        blk = "lsblk -o NAME,LABEL,UUID,FSTYPE,SIZE,FSUSE%,MOUNTPOINT,MODEL | bat";
        fsm = "df -h | bat";
        grp = "grep --color=auto -E";
        fzp = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
        fre = "free -m";
        wat = "watch -d -c -n -0.5";
        dus = "sudo dust -r";
        dsi = "sudo du -sch . | bat";
        prc = "procs -t";

        lg = "lazygit";
        gs = "git status";
        gcm = "git commit -m";
        ga = "git add";
        glg = "git log --graph --decorate --oneline";
        gcl = "git clone";

        vpnat = "protonvpn-cli c --cc at";
        vpnch = "protonvpn-cli c --cc ch";
        vpnlu = "protonvpn-cli c --cc lu";
        vpnus = "protonvpn-cli c --cc us";
        vpnhk = "protonvpn-cli c --cc hk";
        vpnkr = "protonvpn-cli c --cc kr";
        vpnoff = "protonvpn-cli d";

        # This doesn't work at all, many things crash, no internet etc.
        # gnome = "dbus-run-session gnome-session"; # Requires XDG_SESSION_TYPE to be set for wayland

        failed = "systemctl --failed";
        errors = "journalctl -p 3 -xb";

        rsync = "rsync -chavzP --info=progress2";
        performance = "sudo cpupower frequency-set -g performance && nvidia-settings -a [gpu:0]/GPUPowerMizerMode=1";
        powersave = "sudo cpupower frequency-set -g powersave && nvidia-settings -a [gpu:0]/GPUPowerMizerMode=0";

        xxhamster = "TERM=ansi ssh christoph@217.160.142.51";

        mp4 = "yt-dlp -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' --recode-video mp4"; # the -f options are yt-dlp defaults
        mp3 = "yt-dlp -f 'ba' --extract-audio --audio-format mp3";
      };

      shellAliases = {
        # ".." = "cd ..";
        "please" = "sudo !!";
        "yeet" = "rm -rf";
      };

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
