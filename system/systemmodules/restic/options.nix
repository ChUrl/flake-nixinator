{
  lib,
  mylib,
  hostname,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  enable = mkEnableOption "restic backups over SFTP to the Synology NAS";

  repository = mkOption {
    type = types.str;
    default = "sftp:backup@192.168.86.15:/Restic/${hostname}";
    description = ''
      Restic repository.
    '';
  };

  paths = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Paths to back up.";
  };

  extraBackupArgs = mkOption {
    type = types.listOf types.str;
    default = [
      "--exclude-caches"
      "--cleanup-cache"
    ];
    description = "Extra arguments passed to `restic backup`.";
  };

  prepareCommand = mkOption {
    type = types.lines;
    default = "";
    description = ''
      Runs before the backup, e.g. to dump databases into a directory that is
      part of `paths`. A failing command aborts the backup.
    '';
  };

  cleanupCommand = mkOption {
    type = types.lines;
    default = "";
    description = "Runs after the backup.";
  };

  pruneOpts = mkOption {
    type = types.listOf types.str;
    default = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
    description = "Retention policy passed to `restic forget`.";
  };

  randomizedDelaySec = mkOption {
    type = types.str;
    default = "2h";
    description = "Random delay added to the daily timer.";
  };

  createWrapper = mylib.modules.mkBoolOption false ''
    Create a wrapper script for manual restic invocations against this repo.
  '';
}
