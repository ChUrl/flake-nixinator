{
  config,
  lib,
  mylib,
  pkgs,
  hostname,
  ...
}: let
  cfg = config.systemmodules.restic;

  synology = "192.168.86.15";
in {
  options.systemmodules.restic = import ./options.nix {inherit lib mylib hostname;};

  config = lib.mkIf cfg.enable {
    # Repo password and the SSH key used for the sftp transport.
    sops.secrets."restic-repo-key" = {};
    sops.secrets."restic-ssh-key" = {};

    # restic's local cache for this host's backup
    systemmodules.impermanence.directories = [
      {
        directory = "/var/cache/restic-backups-${hostname}";
        mode = "u=rwx,g=,o=";
      }
    ];

    programs.ssh = {
      extraConfig = ''
        Match host ${synology} localuser root
          IdentityFile ${config.sops.secrets."restic-ssh-key".path}
          IdentitiesOnly yes
          BatchMode yes
      '';

      # Synology: ssh-keyscan -t ed25519 192.168.86.15
      knownHosts.${synology}.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFOJqeggEhZxg4iJq4dN34TPjDBjqherMxqiBGC7gwI";
    };

    services.restic.backups.${hostname} = {
      repository = cfg.repository;
      passwordFile = config.sops.secrets."restic-repo-key".path;
      initialize = true;

      paths = lib.unique (cfg.paths ++ lib.optionals cfg.includeServicePaths cfg.servicePaths);

      inherit (cfg) extraBackupArgs createWrapper;

      backupPrepareCommand =
        if cfg.prepareCommand == ""
        then null
        else cfg.prepareCommand;

      backupCleanupCommand =
        if cfg.cleanupCommand == ""
        then null
        else cfg.cleanupCommand;

      inherit (cfg) pruneOpts;

      runCheck = true;
      checkOpts = ["--read-data-subset=5%"];

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        inherit (cfg) randomizedDelaySec;
      };
    };
  };
}
