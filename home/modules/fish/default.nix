{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) fish;
in {
  options.modules.fish = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf fish.enable {
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

      functions = lib.mergeAttrsList [
        (lib.optionalAttrs config.modules.nnn.enable {
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
        })
      ];

      plugins = [
        # Oh-my-fish plugins are stored in their own repositories, which
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
        batify = command: command + (lib.optionalString config.programs.bat.enable " | bat");

        # Same as above but with args for bat
        batifyWithArgs = command: args: command + (lib.optionalString config.programs.bat.enable (" | bat " + args));

        # These can be used for my config.modules and for HM config.programs,
        # as both of these add the package to home.packages
        hasHomePackage = package: (mylib.modules.contains config.home.packages package);

        # Only add fish abbr if package is installed
        abbrify = package: abbr: (lib.optionalAttrs (hasHomePackage package) abbr);
      in
        lib.mkMerge [
          # Abbrs that are always available are defined here.
          {
            # Shell basics
            c = "clear";
            q = "exit";

            # Fish
            h = batifyWithArgs "history" "-l fish"; # -l fish sets syntax highlighting to fish
            abbrs = batifyWithArgs "abbr" "-l fish";

            # Tools
            cd = "z"; # zoxide for quickjump to previously visited locations
            cdd = "zi";
            b = "z -"; # jump to previous dir
            mkdir = "mkdir -p"; # also create parents (-p)
            blk = batify "lsblk -o NAME,LABEL,ID,UUID,FSTYPE,SIZE,FSUSE%,MOUNTPOINT,MODEL";
            watch = "watch -d -c -n 0.5";
            nd = "nix develop";
            nb = "nix build -L";
            nps = "nps -e";
          }

          # Abbrs only available if package is installed

          (abbrify pkgs.duf {
            # df = "duf";
            disks = "duf";
          })

          (abbrify pkgs.eza {
            ls = "eza --color=always --group-directories-first -F --git --icons=always --octal-permissions";
            lsl = "eza --color=always --group-directories-first -F --git --icons=always --octal-permissions -l";
            lsa = "eza --color=always --group-directories-first -F --git --icons=always --octal-permissions -l -a";
            tre = "eza --color=always --group-directories-first -F --git --icons=always --octal-permissions -T -L 2";
          })

          (abbrify pkgs.fd {find = "fd";})

          (abbrify pkgs.fzf {fuzzy = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";})

          (abbrify pkgs.gdu {
            # du = "gdu";
            storage = "gdu";
          })

          (abbrify pkgs.git {
            gs = "git status";
            gd = "git diff --output-indicator-new=' ' --output-indicator-old=' '";
            gl = "git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n'";
            ga = "git add";
            gap = "git add --patch";
            gc = "git commit --verbose";
            gcm = "git commit -m";
            gcl = "git clone";
          })

          (lib.optionalAttrs config.modules.kitty.enable {ssh = "kitty +kitten ssh";})

          (abbrify pkgs.lazygit {lg = "lazygit";})

          (abbrify pkgs.nix-search-tv {search = "nix-search-tv print --indexes 'nixos,home-manager,nixpkgs,nur' | fzf --preview 'nix-search-tv preview {}' --scheme history";})

          # Doesn't work with abbrify because I have nnn.override...
          (lib.optionalAttrs config.modules.nnn.enable {n = "nnncd -a";})
          (lib.optionalAttrs config.modules.nnn.enable {np = "nnncd -a -P p";})

          (abbrify pkgs.ranger {r = "ranger --choosedir=$HOME/.rangerdir; set LASTDIR (cat $HOME/.rangerdir); cd $LASTDIR";})

          (abbrify pkgs.ripgrep rec {
            rg = "rg --trim --pretty";
            grep = rg;
          })

          (abbrify pkgs.rsync rec {
            rsync = "rsync -ahv --inplace --partial --info=progress2";
            copy = rsync;
          })

          (abbrify pkgs.sd {sed = "sd";})
        ];
    };

    programs.starship = let
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
  };
}
