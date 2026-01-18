{
  config,
  lib,
  mylib,
  pkgs,
  username,
  publicKeys,
  ...
}: let
  inherit (config.systemmodules) agenix;
in {
  options.systemmodules.agenix = import ./options.nix {inherit lib mylib;};

  config = {
    # NOTE: Add below snippet to home/christoph/default.nix to generate the secrets.nix file

    # The user will be able to decrypt .age files using agenix.
    # On each user/machine, this should generate a corresponding secrets.nix
    # "${config.paths.nixflake}/system/modules/agenix/secrets.nix".text = let
    #   mkSecret = key: name: "\"${name}.age\".publicKeys = [\"${key}\"];";
    # in ''
    #   # This file will contain keys depending on the host/by which user it was built on.
    #   {
    #     ${lib.optionalString
    #     # If this user defined any secrets...
    #     (builtins.hasAttr "${username}" nixosconfig.systemmodules.agenix.secrets)
    #     # ...we will add them to the current secrets.nix,
    #     # s.t. agenix can be used to encrypt/access them.
    #     (builtins.concatStringsSep "\n"
    #       (builtins.map
    #         (mkSecret publicKeys.${username}.ssh)
    #         nixosconfig.systemmodules.agenix.secrets.${username}))}
    #   }
    # '';

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
