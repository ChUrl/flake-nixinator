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
  cfg = config.homemodules.vscode;
in {
  options.homemodules.vscode = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      mutableExtensionsDir = false;

      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        enableMcpIntegration = false;

        extensions = with pkgs.vscode-extensions; [
          # Theme
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          vscode-icons-team.vscode-icons

          # General
          vscodevim.vim
          christian-kohler.path-intellisense
          ryu1kn.partial-diff
          redhat.vscode-yaml
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          ms-vscode.remote-explorer

          # Python
          ms-python.python
          ms-python.vscode-pylance
          ms-python.black-formatter

          # C/C++
          ms-vscode.cpptools
          # llvm-vs-code-extensions.vscode-clangd
          ms-vscode.cmake-tools
          ms-vscode.makefile-tools
          # llvm-org.lldb-vscode
          vadimcn.vscode-lldb
          # "13xforever".language-x86-64-assembly

          # Latex
          # james-yu.latex-workshop
          # valentjn.vscode-ltex
        ];

        keybindings = [];
        globalSnippets = {};
        languageSnippets = {};
        userMcp = {};

        userSettings = {
          "editor.fontFamily" = config.homemodules.color.font;
          "editor.fontSize" = 14;
          "editor.smoothScrolling" = true;
          "editor.cursorSmoothCaretAnimation" = "on";
          "workbench.enableExperiments" = false;
          "workbench.list.smoothScrolling" = true;
          "workbench.colorTheme" = "Catppuccin Mocha";
          "workbench.iconTheme" = "catppuccin-mocha";
          "remote.SSH.configFile" = "~/.ssh/custom-config";
          "security.workspace.trust.enabled" = false;

          # C++
          # "C_Cpp.intelliSenseEngine" = "disabled"; # IntelliSense conflics with Clangd
        };

        userTasks = {};
      };
    };
  };
}
