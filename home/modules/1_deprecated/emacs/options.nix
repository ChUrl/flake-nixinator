{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Emacs module";

  # TODO: Use an enum for this not individual options
  nixpkgs = mkBoolOption false "Use Emacs from the official repositories";
  nativeComp = mkBoolOption false "Use Emacs 28.x branch with native comp support";
  pgtkNativeComp = mkBoolOption false "Use Emacs 29.x branch with native comp and pure gtk support";

  doom = {
    enable = mkEnableOption "Doom Emacs framework";
    autoSync = mkBoolOption false "Sync Doom Emacs on nixos-rebuild";
    autoUpgrade = mkBoolOption false "Upgrade Doom Emacs on nixos-rebuild";
  };
}
