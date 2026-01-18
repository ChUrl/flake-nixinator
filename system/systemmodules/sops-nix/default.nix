{
  config,
  lib,
  mylib,
  pkgs,
  username,
  ...
}: let
  inherit (config.systemmodules) sops-nix;
in {
  options.systemmodules.sops-nix = import ./options.nix {inherit lib mylib;};

  config = {
    environment.systemPackages = with pkgs; [
      sops
      age
      # ssh-to-age
    ];

    environment.variables = {
      # Set this environment variable to make "sops edit secrets.yaml" work
      SOPS_AGE_KEY_FILE = config.sops.age.keyFile;
    };

    sops = {
      defaultSopsFile = ./secrets.yaml;

      age = {
        keyFile = lib.mkDefault "/home/${username}/.secrets/age/age.key";
        generateKey = false;
        sshKeyPaths = [];
      };

      secrets = let
        mkSecret = name: {
          ${name} = {
            owner = config.users.users.${username}.name;
            group = config.users.users.${username}.group;
          };
        };

        mkBootSecret = name: {
          ${name} = {
            # Make these secrets available before creating users.
            # This means we can't set the owner or group.
            neededForUsers = true;
          };
        };
      in
        lib.mkMerge [
          (
            if (builtins.hasAttr "${username}" sops-nix.secrets)
            then lib.mergeAttrsList (builtins.map mkSecret sops-nix.secrets.${username})
            else {}
          )
          (
            if (builtins.hasAttr "${username}" sops-nix.bootSecrets)
            then lib.mergeAttrsList (builtins.map mkBootSecret sops-nix.bootSecrets.${username})
            else {}
          )
        ];
    };
  };
}
