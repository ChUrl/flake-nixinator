{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) latex;
in {
  options.modules.latex = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf latex.enable {
    home = {
      packages = with pkgs; [
        texliveFull
        inkscape
      ];

      file = {
        # Collection of macros and environments I once used, but not anymore...
        # "texmf/tex/latex/custom/christex.sty".source = ../../../config/latex/christex.sty;
        "Notes/Obsidian/Chriphost/christex.sty".source = ../../../config/latex/christex.sty; # For old obsidian notes

        ".indentconfig.yaml".source = ../../../config/latex/.indentconfig.yaml;
        ".indentsettings.yaml".source = ../../../config/latex/.indentsettings.yaml;

        # TODO: These don't belong into a latex module
        "Notes/Obsidian/Chriphost/latex_snippets.json".source = ../../../config/obsidian/latex_snippets.json; # TODO: Symlink
        "Notes/Obsidian/Chriphost/.obsidian/snippets/latex_preview.css".source = ../../../config/obsidian/css_snippets/latex_preview.css;
        "Notes/Obsidian/Chriphost/.obsidian/snippets/center_image.css".source = ../../../config/obsidian/css_snippets/center_image.css;
      };
    };
  };
}
