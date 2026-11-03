{
  config,
  lib,
  mylib,
  ...
}: {
  options.homemodules.sops = import ./options.nix {inherit lib mylib;};

  # Read by the system sops module, see system/systemmodules/sops-nix.
  config = {};
}
