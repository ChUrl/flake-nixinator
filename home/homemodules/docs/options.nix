{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Enable Document Support (e.g. LaTeX)";
}
