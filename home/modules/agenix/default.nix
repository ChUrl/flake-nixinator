{
  config,
  nixosConfig,
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
    # The user will be able to decrypt .age files using agenix.
    # On each user/machine, this should generate a corresponding secrets.nix
    home.file."${config.paths.nixflake}/home/modules/agenix/secrets.nix".text = let
      mkSecret = key: name: "\"${name}.age\".publicKeys = [\"${key}\"];";
    in ''
      # NOTE: This file will contain keys depending on the host/by which user it was built on.
      {
        ${lib.optionalString
        # If this user defined any secrets...
        (builtins.hasAttr "${username}" agenix.secrets)
        # ...we will add them to the current secrets.nix,
        # s.t. agenix can be used to encrypt the secret.
        (builtins.concatStringsSep "\n"
          (builtins.map
            (mkSecret publicKeys.${username}.ssh)
            agenix.secrets.${username}))}
      }
    '';

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
