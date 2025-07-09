{
  config,
  lib,
  mylib,
  pkgs,
  username,
  publicKeys,
  ...
}: let
  inherit (config.modules) agenix;
in {
  options.modules.agenix = import ./options.nix {inherit lib mylib;};

  config = {
    # NOTE: See the generated secrets.nix file in home/christoph/default.nix

    # Register generated secrets to the age system module
    age.secrets = let
      mkSecretIfExists = name:
      # If this user has already encrypted the secret...
        if builtins.pathExists ./${name}.age
        # ...we will register it with age...
        then {${name}.file = ./${name}.age;}
        # ...otherwise we link to a bogus file.
        else {${name}.file = ./void.age;};
    in
      lib.mkIf
      # If this user defined any secrets...
      (builtins.hasAttr "${username}" agenix.secrets)
      # ...we will register all secrets files that have already been generated.
      (lib.mkMerge (builtins.map mkSecretIfExists agenix.secrets.${username}));
  };
}
