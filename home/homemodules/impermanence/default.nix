{
  config,
  lib,
  mylib,
  ...
}: {
  options.homemodules.impermanence = import ./options.nix {inherit lib mylib;};

  # Read by the system impermanence module, see
  # system/systemmodules/impermanence.
  config = {};
}
