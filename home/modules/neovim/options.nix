{
  lib
}:
with lib;
{
  enable = mkEnableOpt "NeoVim";
  alias = mkBoolOpt false "Link nvim to vim/vi";
}