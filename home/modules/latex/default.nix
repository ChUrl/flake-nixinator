{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.latex;
in {
  options.modules.latex = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        texliveFull
        inkscape
      ];

      file = {
        # Old collection of macros and environments I once used, but not anymore...
        # "texmf/tex/latex/custom/christex.sty".source = ../../../config/latex/christex.sty;
        # "Notes/Obsidian/Chriphost/christex.sty".source = ../../../config/latex/christex.sty; # For obsidian notes

        ".indentconfig.yaml".source = ../../../config/latex/.indentconfig.yaml;
        ".indentsettings.yaml".source = ../../../config/latex/.indentsettings.yaml;
        "Notes/Obsidian/Chriphost/latex_snippets.json".source = ../../../config/obsidian/latex_snippets.json; # TODO: Symlink
        "Notes/Obsidian/Chriphost/.obsidian/snippets/latex_preview.css".source = ../../../config/obsidian/css_snippets/latex_preview.css;
      };
    };
  };
}
