{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "NeoVim";
  alias = mkBoolOption false "Link nvim to vim/vi";
  neovide = mkEnableOption "NeoVide";
}
