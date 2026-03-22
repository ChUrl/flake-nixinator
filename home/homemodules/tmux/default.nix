{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) tmux color;
in {
  options.homemodules.tmux = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf tmux.enable {
    programs.tmux = {
      enable = true;

      clock24 = true;
      escapeTime = 0; # Delay after pressing escape
      # keyMode = "vi";
      terminal = "xterm-256color";

      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            set -g @plugin 'catppuccin/tmux'
            set -g @catppuccin_flavour 'latte' # or frappe, macchiato, mocha
          '';
        }
      ];

      extraConfig = ''
        set -g default-terminal "xterm-256color"
        set-option -ga terminal-overrides ",xterm-256color:Tc"
      '';
    };
  };
}
