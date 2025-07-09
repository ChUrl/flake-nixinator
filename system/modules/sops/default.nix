{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) sops;
in {
  options.modules.sops = import ./options.nix {inherit lib mylib;};

  config = {
    environment.systemPackages = [pkgs.sops];
  };
}
