# TODO: Expose some settings
# TODO: Fix language config
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
  cfg = config.homemodules.helix;
in {
  options.homemodules.helix = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    programs.helix = {
      enable = true;

      # NOTE: Syntax changed
      # languages = [
      #   {
      #     name = "verilog";
      #     roots = [
      #       ".svls.toml"
      #       ".svlint.toml"
      #     ];
      #     language-server = {
      #       command = "svls";
      #       args = [];
      #     };
      #   }
      # ];

      # https://docs.helix-editor.com/configuration.html
      settings = {
        theme = "catppuccin_latte";
        editor = {
          scrolloff = 10;
          mouse = false; # Default true
          middle-click-paste = false; # Default true
          line-number = "relative";
          cursorline = true;
          color-modes = true;
          auto-completion = true; # Default
          bufferline = "multiple";
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          lsp.display-messages = true;
          indent-guides.render = false;
        };
      };
    };
  };
}
