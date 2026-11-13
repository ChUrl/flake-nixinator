{
  config,
  lib,
  mylib,
  pkgs,
  username,
  ...
}: let
  inherit (config.systemmodules) sops-nix;

  user = config.users.users.${username};

  # Secrets needed by the user session are declared in the respective
  # home-manager module: HM modules can't set system options themselves,
  # so the system sops module folds them in here.
  hmSecrets = config.home-manager.users.${username}.homemodules.sops.secrets or [];

  userSecrets = lib.unique (sops-nix.secrets ++ hmSecrets);
  allSecrets = lib.unique (userSecrets ++ sops-nix.bootSecrets);

  group =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "staff" # Apparently there's no way to get the primary group?
    else user.group;
in {
  options.systemmodules.sops-nix = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf sops-nix.enable {
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
        keyFile = lib.mkDefault "${user.home}/.secrets/age/age.key";
        generateKey = false;
        sshKeyPaths = [];
      };

      secrets = lib.genAttrs allSecrets (name:
        lib.mkMerge [
          (lib.mkIf (lib.elem name userSecrets) {
            # mkDefault so modules that need their own owner (e.g. authelia)
            # can still override it.
            owner = lib.mkDefault user.name;
            group = lib.mkDefault group;
          })
          (lib.mkIf (lib.elem name sops-nix.bootSecrets) {
            # Make these secrets available before creating users.
            # This means we can't set the owner or group.
            neededForUsers = true;
          })
        ]);
    };
  };
}
