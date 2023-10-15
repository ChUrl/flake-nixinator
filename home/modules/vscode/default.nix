# TODO: Expose some settings
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
  cfg = config.modules.vscode;
in {
  options.modules.vscode = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        alefragnani.bookmarks
        # alefragnani.project-manager # Not much sense with flake dev environments
        # bradlc.vscode-tailwindcss
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        christian-kohler.path-intellisense
        codezombiech.gitignore
        coolbear.systemd-unit-file
        eamodio.gitlens
        # formulahendry.auto-rename-tag
        # formulahendry.auto-close-tag
        # gitlab.gitlab-workflow
        # irongeek.vscode-env
        jnoortheen.nix-ide
        kamadorueda.alejandra
        # kamikillerto.vscode-colorize
        llvm-vs-code-extensions.vscode-clangd
        matklad.rust-analyzer
        mechatroner.rainbow-csv
        # mikestead.dotenv
        # mkhl.direnv
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-python.python # TODO: Reenable, was disabled bc build failure
        ms-toolsai.jupyter
        ms-vscode.cmake-tools
        ms-vscode.cpptools
        ms-vscode.hexeditor
        ms-vscode.makefile-tools
        ms-vscode-remote.remote-ssh
        # naumovs.color-highlight
        njpwerner.autodocstring
        james-yu.latex-workshop
        redhat.java
        redhat.vscode-xml
        redhat.vscode-yaml
        rubymaniac.vscode-paste-and-indent
        ryu1kn.partial-diff
        serayuzgur.crates
        shd101wyy.markdown-preview-enhanced
        skyapps.fish-vscode
        tamasfe.even-better-toml
        timonwong.shellcheck
        # tomoki1207.pdf # Incompatible with latex workshop
        valentjn.vscode-ltex
        vscodevim.vim
        vscode-icons-team.vscode-icons
        yzhang.markdown-all-in-one
      ];
      # haskell = {};
      # keybindings = {};

      userSettings = {
        # VSCode Internals
        "editor.fontFamily" = "JetBrainsMono Nerd Font Mono";
        "editor.fontSize" = 14;
        "editor.renderWhitespace" = "selection";
        "editor.cursorStyle" = "line"; # Use line for vim plugin
        "editor.lineNumbers" = "relative";
        "editor.linkedEditing" = true;
        "editor.smoothScrolling" = true;
        "editor.stickyScroll.enabled" = true;
        "editor.tabCompletion" = "on";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.cursorSurroundingLines" = 10;
        "editor.minimap.renderCharacters" = false;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";
        "editor.guides.bracketPairsHorizontal" = "active";
        "editor.guides.highlightActiveIndentation" = false;

        "files.autoSave" = "onFocusChange";
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true; # NOTE: If this is enabled with frequent autosave, the current lines whitespace will always be removed, which is obnoxious

        "window.restoreWindows" = "none";

        "window.titleBarStyle" = "custom"; # NOTE: Should help with crashing on wayland?
        # "window.titleBarStyle" = "native";
        # "window.menuBarVisibility" = "toggle";

        "workbench.enableExperiments" = false;
        "workbench.list.smoothScrolling" = true;
        # "workbench.colorTheme" = "Default Light Modern";
        # "workbench.iconTheme" = "vscode-icons";
        "workbench.colorTheme" = "Catppuccin Latte";
        "workbench.iconTheme" = "catppuccin-latte";

        "remote.SSH.configFile" = "~/.ssh/custom-config";

        "security.workspace.trust.enabled" = false;

        # Language Tool
        "ltex.checkFrequency" = "manual";

        # LaTeX
        "latex-workshop.latex.tools" = [
          {
            "name" = "latexmk";
            "command" = "latexmk";
            "args" = [
              "-synctex=1"
              "-shell-escape"
              "-interaction=nonstopmode"
              "-file-line-error"
              "-pdf"
              "-outdir=%OUTDIR%"
              "%DOC%"
            ];
            "env" = {};
          }
        ];
        "latex-workshop.latexindent.args" = [
          "-c"
          "%DIR%/"
          "%TMPFILE%"
          "-m"
          "-y=defaultIndent: '%INDENT%'"
        ];

        # Nix
        "[nix]"."editor.tabSize" = 2;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.formatterPath" = "alejandra";
      };
      # TODO: Snippets
    };
  };
}
