{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Ivanti Secure Access Client (Pulse Secure)";
}
