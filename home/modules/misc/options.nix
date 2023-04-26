{
  lib,
  mylib,
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Misc module";

  keepass = {
    enable = mkEnableOpt "KeePassXC";
    autostart = mkBoolOpt false "Autostart KeePassXC";
  };

  protonmail = {
    enable = mkEnableOpt "ProtonMail";
    autostart = mkBoolOpt false "Autostart ProtonMail Bridge";
  };
}
