{
  lib,
  mylib,
  ...
}: {
  secrets = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = ''
      Secrets from the system sops file (sops-nix/secrets.yaml) that the user
      session needs. The system sops module installs them and chowns them to
      the user. HM modules can't set system options, so declaring them in the
      module that uses them is done through this option.
    '';
    example = ''
      ["jellyfin-password"]
    '';
    default = [];
  };
}
