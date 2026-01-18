{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Misc module";

  keepass = {
    enable = mkEnableOption "KeePassXC";
    autostart = mkBoolOption false "Autostart KeePassXC";
  };

  protonmail = {
    enable = mkEnableOption "ProtonMail";
    autostart = mkBoolOption false "Autostart ProtonMail Bridge";
  };
}
