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
  cfg = config.modules.fish;
in {
  options.modules.fish = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    home.file.".config/fish/themes/catppuccin-latte.theme".text = ''
      # name: 'Catppuccin Latte'
      # url: 'https://github.com/catppuccin/fish'
      # preferred_background: eff1f5

      fish_color_normal 4c4f69
      fish_color_command 1e66f5
      fish_color_param dd7878
      fish_color_keyword d20f39
      fish_color_quote 40a02b
      fish_color_redirection ea76cb
      fish_color_end fe640b
      fish_color_comment 8c8fa1
      fish_color_error d20f39
      fish_color_gray 9ca0b0
      fish_color_selection --background=ccd0da
      fish_color_search_match --background=ccd0da
      fish_color_option 40a02b
      fish_color_operator ea76cb
      fish_color_escape e64553
      fish_color_autosuggestion 9ca0b0
      fish_color_cancel d20f39
      fish_color_cwd df8e1d
      fish_color_user 179299
      fish_color_host_remote 40a02b
      fish_color_host 1e66f5
      fish_color_status d20f39
      fish_pager_color_progress 9ca0b0
      fish_pager_color_prefix ea76cb
      fish_pager_color_completion 4c4f69
      fish_pager_color_description 9ca0b0
    '';

    programs.fish = {
      enable = true;

      functions = {
        nnncd = {
          wraps = "nnn";
          description = "support nnn quit and change directory";
          body = ''
            # Block nesting of nnn in subshells
            if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
                echo "nnn is already running"
                return
            end

            # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
            # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
            # see. To cd on quit only on ^G, remove the "-x" from both lines below,
            # without changing the paths.
            if test -n "$XDG_CONFIG_HOME"
                set -x NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
            else
                set -x NNN_TMPFILE "$HOME/.config/nnn/.lastd"
            end

            # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
            # stty start undef
            # stty stop undef
            # stty lwrap undef
            # stty lnext undef

            # The command function allows one to alias this function to `nnn` without
            # making an infinitely recursive alias
            command nnn $argv

            if test -e $NNN_TMPFILE
                source $NNN_TMPFILE
                rm $NNN_TMPFILE
            end
          '';
        };
      };

      plugins = [
        # oh-my-fish plugins are stored in their own repositories, which
        # makes them simple to import into home-manager.
        # NOTE: Currently, HM ignores theme plugins
        # {
        #   name = "Catppuccin Latte";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "catppuccin";
        #     repo = "fish";
        #     rev = "91e6d6721362be05a5c62e235ed8517d90c567c9";
        #     sha256 = "sha256-l9V7YMfJWhKDL65dNbxaddhaM6GJ0CFZ6z+4R6MJwBA=";
        #   };
        # }
      ];

      shellInit = ''
        set -e fish_greeting
        yes | fish_config theme save "catppuccin-latte"
      '';

      shellAbbrs = let
        # Only add " | bat" if bat is installed
        batify = command: command + (optionalString config.programs.bat.enable " | bat");
        # Same as above but with args for bat
        batifyWithArgs = command: args: command + (optionalString config.programs.bat.enable (" | bat " + args));

        # NOTE: These can be used for my config.modules and for HM config.programs, as both of these add the package to home.packages
        hasHomePackage = package: (contains config.home.packages package);
        # Only add fish abbr if package is installed
        abbrify = package: abbr: (optionalAttrs (hasHomePackage package) abbr);
      in
        mkMerge [
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
            b = "z -"; # jump to previous dir
            mkdir = "mkdir -p"; # also create parents (-p)
            blk = batify "lsblk -o NAME,LABEL,UUID,FSTYPE,SIZE,FSUSE%,MOUNTPOINT,MODEL";
            grep = "grep --color=auto -E"; # grep with extended regex
            watch = "watch -d -c -n 0.5";
            n = "nnncd -a -e"; # Doesn't work with abbrify because I have nnn.override?
            np = "nnncd -a -P p -e";
            ssh = "kitty +kitten ssh";

            # systemd
            failed = "systemctl --failed";
            errors = "journalctl -p 3 -xb";
            kernelerrors = "journalctl -p 3 -xb -k";
            uniterrors = "journalctl -xb --unit=";
            useruniterrors = "journalctl -xb --user-unit=";

            # samba
            # TODO: Make a rofi menu out of this? Maybe general purpose menu? Or menu for all abbrs?
            musenet = "sudo mount.cifs -o credentials=/home/christoph/.samba.login,uid=1000,gid=100 //truenas/Usenet /media/Usenet";
            mpicture = "sudo mount.cifs -o credentials=/home/christoph/.samba.login,uid=1000,gid=100 //truenas/Picture /media/Picture";
            mvideo = "sudo mount.cifs -o credentials=/home/christoph/.samba.login,uid=1000,gid=100 //truenas/Video /media/Video";

            # ssh locations
            xxhamster = "TERM=ansi ssh christoph@217.160.142.51";

            # disassemble
            disassemble = "objdump -d -S -M intel";
          }

          # Abbrs only available if package is installed
          (abbrify pkgs.btop {top = "btop";})
          (abbrify pkgs.duf {
            df = "duf";
            disksummary = "duf";
          })
          (abbrify pkgs.exa {
            ls = "exa --color always --group-directories-first -F --git --icons"; # color-ls
            lsl = "exa --color always --group-directories-first -F -l --git --icons --octal-permissions";
            lsa = "exa --color always --group-directories-first -F -l -a --git --icons --octal-permissions";
            tre = "exa --color always --group-directories-first -F -T -L 2 ---icons";
          })
          (abbrify pkgs.fd {find = "fd";})
          (abbrify pkgs.fzf {fuzzy = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";})
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
          (abbrify pkgs.gping {ping = "gping";})
          (abbrify pkgs.lazygit {lg = "lazygit";})
          # (abbrify pkgs.navi {n = "navi";})
          (abbrify pkgs.notmuch {
            mailrefresh = "notmuch new";
            mailsearch = "notmuch search";
          })
          (abbrify pkgs.protonvpn-cli {
            vpnon = "protonvpn-cli c -f";
            vpnat = "protonvpn-cli c --cc at";
            vpnch = "protonvpn-cli c --cc ch";
            vpnlu = "protonvpn-cli c --cc lu";
            vpnus = "protonvpn-cli c --cc us";
            vpnhk = "protonvpn-cli c --cc hk";
            vpnkr = "protonvpn-cli c --cc kr";
            vpnoff = "protonvpn-cli d";
          })
          (abbrify pkgs.ranger {r = "ranger --choosedir=$HOME/.rangerdir; set LASTDIR (cat $HOME/.rangerdir); cd $LASTDIR";})
          (abbrify pkgs.rsync {
            cp = "rsync -ahv --inplace --partial --info=progress2";
            rsync = "rsync -ahv --inplace --partial --info=progress2";
          })
          (abbrify pkgs.sd {sed = "sd";})
          (abbrify pkgs.yt-dlp {
            mp4 = "yt-dlp -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' --recode-video mp4"; # the -f options are yt-dlp defaults
            mp3 = "yt-dlp -f 'ba' --extract-audio --audio-format mp3";
          })
        ];
    };
  };
}
