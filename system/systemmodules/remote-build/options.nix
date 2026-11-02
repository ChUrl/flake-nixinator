{
  lib,
  mylib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  enable = mkEnableOption "remote builds on nixinator and its binary cache";

  builderHost = mkOption {
    type = types.str;
    default = "192.168.86.50";
    description = "Address of the build machine (nixinator).";
  };

  builderPort = mkOption {
    type = types.port;
    default = 5432;
    description = "SSH port of the build machine (nixinator's sshd runs on 5432).";
  };

  builderAlias = mkOption {
    type = types.str;
    default = "nixbuilder";
    description = "SSH host alias used for the builder (declared in ssh_config).";
  };

  sshUser = mkOption {
    type = types.str;
    default = "christoph";
    description = "User used to connect to the builder. Must be in its trusted-users.";
  };

  cacheUrl = mkOption {
    type = types.str;
    default = "http://192.168.86.50:5000";
    description = "Binary cache served by the builder.";
  };

  cachePublicKey = mkOption {
    type = types.str;
    default = "nixinator-cache-1:JTE74WSNp+9VplHVxBfT3lQHCUP2sgUmKB6vJx+hGHA=";
    description = "Public signing key of that cache.";
  };

  maxJobs = mkOption {
    type = types.ints.positive;
    default = 8;
    description = "Concurrent jobs on the builder.";
  };

  speedFactor = mkOption {
    type = types.ints.positive;
    default = 4;
    description = "Relative speed of the builder.";
  };

  supportedFeatures = mkOption {
    type = types.listOf types.str;
    default = [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
    ];
    description = "Features the builder supports.";
  };
}
