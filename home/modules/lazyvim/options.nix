{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "LazyVim";
  alias = mkBoolOpt false "Link nvim to vim/vi";
  neovide = mkEnableOpt "NeoVide";
}
