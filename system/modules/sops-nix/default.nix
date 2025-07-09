{
  config,
  lib,
  mylib,
  pkgs,
  username,
  ...
}: let
  inherit (config.modules) sops-nix;
in {
  options.modules.sops-nix = import ./options.nix {inherit lib mylib;};

  config = {
    environment.systemPackages = with pkgs; [
      sops
      age
      ssh-to-age
    ];

    sops = {
      defaultSopsFile = ./secrets.yaml;

      age = {
        keyFile = "/home/${username}/.secrets/age/age.key";
        generateKey = false;
        sshKeyPaths = [];
      };

      secrets = let
        mkSecret = name: {${name} = {};};
      in
        if (builtins.hasAttr "${username}" sops-nix.secrets)
        then lib.mergeAttrsList (builtins.map mkSecret sops-nix.secrets.${username})
        else {};
    };
  };
}
