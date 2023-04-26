{
  lib,
  mylib
}:
with lib;
with mylib.modules;
{
  enable = mkEnableOpt "Emacs module";

  # TODO: Use an enum for this not individual options
  nixpkgs = mkBoolOpt false "Use Emacs from the official repositories";
  nativeComp = mkBoolOpt false "Use Emacs 28.x branch with native comp support";
  pgtkNativeComp = mkBoolOpt false "Use Emacs 29.x branch with native comp and pure gtk support";

  doom = {
    enable = mkEnableOpt "Doom Emacs framework";
    autoSync = mkBoolOpt false "Sync Doom Emacs on nixos-rebuild";
    autoUpgrade = mkBoolOpt false "Upgrade Doom Emacs on nixos-rebuild";
  };
}