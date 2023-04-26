{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "NeoVim";
  alias = mkBoolOpt false "Link nvim to vim/vi";
}
