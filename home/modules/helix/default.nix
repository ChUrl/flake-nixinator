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
  cfg = config.modules.helix;
in {
  options.modules.helix = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
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
        # theme = "base16_terminal";
        editor = {
          scrolloff = 10;
          mouse = false; # Default true
          middle-click-paste = false; # Default true
          line-number = "relative";
          cursorline = true;
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
