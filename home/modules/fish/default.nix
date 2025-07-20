{
  config,
  lib,
  mylib,
  pkgs,
  username,
  nixosConfig,
  ...
}: let
  inherit (config.modules) fish color;
in {
  options.modules.fish = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf fish.enable {
    # https://github.com/catppuccin/fish/blob/main/themes/Catppuccin%20Mocha.theme
    home.file.".config/fish/themes/catppuccin-latte.theme".text = ''
      fish_color_normal ${color.hex.text}
      fish_color_command ${color.hex.blue}
      fish_color_param ${color.hex.flamingo}
      fish_color_keyword ${color.hex.red}
      fish_color_quote ${color.hex.green}
      fish_color_redirection ${color.hex.accentHl}
      fish_color_end ${color.hex.peach}
      fish_color_comment ${color.hex.overlay1}
      fish_color_error ${color.hex.red}
      fish_color_gray ${color.hex.overlay0}
      fish_color_selection --background=${color.hex.surface0}
      fish_color_search_match --background=${color.hex.surface0}
      fish_color_option ${color.hex.green}
      fish_color_operator ${color.hex.accentHl}
      fish_color_escape ${color.hex.maroon}
      fish_color_autosuggestion ${color.hex.overlay0}
      fish_color_cancel ${color.hex.red}
      fish_color_cwd ${color.hex.yellow}
      fish_color_user ${color.hex.teal}
      fish_color_host ${color.hex.blue}
      fish_color_host_remote ${color.hex.green}
      fish_color_status ${color.hex.red}
      fish_pager_color_progress ${color.hex.overlay0}
      fish_pager_color_prefix ${color.hex.accentHl}
      fish_pager_color_completion ${color.hex.text}
      fish_pager_color_description ${color.hex.overlay0}
    '';

    programs.fish = {
      enable = true;
      generateCompletions = nixosConfig.programs.fish.generateCompletions;

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
            blk = batify "lsblk -o NAME,LABEL,PARTLABEL,FSTYPE,SIZE,FSUSE%,MOUNTPOINT";
            blkids = batify "lsblk -o NAME,LABEL,FSTYPE,SIZE,PARTLABEL,MODEL,ID,UUID";
            watch = "watch -d -c -n 0.5";
            nps = "nps -e";
            nd = "nix develop";
            nb = "nix build -L";
            ns = "nix shell nixpkgs#";
          }

          # Impermanence
          # TODO: Those should be a single script to be called with the search path (/ or /home/christoph or just .)
          (let
            fdIgnoreHome = "fdignore-home";
            fdIgnoreRoot = "fdignore-root";

            cmdHome = "sudo fd --one-file-system --base-directory /home/${username} --type f --hidden --ignore-file /home/${username}/.config/impermanence/${fdIgnoreHome}";
            cmdRoot = "sudo fd --one-file-system --base-directory / --type f --hidden --ignore-file /home/${username}/.config/impermanence/${fdIgnoreRoot}";

            fzfHome = "sudo fzf --preview 'bat --color=always --theme=ansi --style=numbers --line-range=:100 {}'";
            fzfRoot = "sudo fzf --preview 'bat --color=always --theme=ansi --style=numbers --line-range=:100 /{}'";

            mvHome = "mkdir -p /persist/home/${username}/$(dirname {}) && mv {} /persist/home/${username}/$(dirname {})";
            mvRoot = "sudo mkdir -p /persist/$(dirname {}) && sudo mv {} /persist/$(dirname {})";

            header = "--header 'Press CTRL-R to reload, CTRL-M to move, CTRL-F to ignore file'";

            ignoreFileHome = "echo '{}' >> /home/${username}/.config/impermanence/${fdIgnoreHome}";
            ignoreFileRoot = "echo '{}' >> /home/${username}/.config/impermanence/${fdIgnoreRoot}";

            bindHome = "--bind 'ctrl-r:reload(${cmdHome}),ctrl-m:execute(${mvHome}),ctrl-f:execute(${ignoreFileHome})'";
            bindRoot = "--bind 'ctrl-r:reload(${cmdRoot}),ctrl-m:execute(${mvRoot}),ctrl-f:execute(${ignoreFileRoot})'";
          in {
            newhome = ''${cmdHome} | ${fzfHome} ${header} ${bindHome}'';
            newroot = ''${cmdRoot} | ${fzfRoot} ${header} ${bindRoot}'';
          })

          # Abbrs only available if package is installed

          (abbrify pkgs.duf {
            disks = "duf --hide-mp '/var/*,/etc/*,/usr/*,/home/christoph/.*'";
            alldisks = "duf";
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
            # grep = rg;
          })

          (abbrify pkgs.rsync rec {
            rsync = "rsync -ahv --inplace --partial --info=progress2";
            copy = rsync;
          })

          # (abbrify pkgs.sd {sed = "sd";})
        ];
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
      settings = {
        # Other config here
        format = "$all"; # Remove this line to disable the default prompt format
        palette = "nixos-palette";

        # https://github.com/catppuccin/starship/blob/main/themes/mocha.toml
        palettes."nixos-palette" = {
          rosewater = color.hexS.rosewater;
          flamingo = color.hexS.flamingo;
          pink = color.hexS.accentHl;
          mauve = color.hexS.accent;
          red = color.hexS.red;
          maroon = color.hexS.maroon;
          peach = color.hexS.peach;
          yellow = color.hexS.yellow;
          green = color.hexS.green;
          teal = color.hexS.teal;
          sky = color.hexS.sky;
          sapphire = color.hexS.sapphire;
          blue = color.hexS.blue;
          lavender = color.hexS.lavender;
          text = color.hexS.text;
          subtext1 = color.hexS.subtext1;
          subtext0 = color.hexS.subtext0;
          overlay2 = color.hexS.overlay2;
          overlay1 = color.hexS.overlay1;
          overlay0 = color.hexS.overlay0;
          surface2 = color.hexS.surface2;
          surface1 = color.hexS.surface1;
          surface0 = color.hexS.surface0;
          base = color.hexS.accentText;
          mantle = color.hexS.mantle;
          crust = color.hexS.crust;
        };
      };
    };
  };
}
