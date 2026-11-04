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
      "/var/lib/restic-metrics"
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

    # Freshness metrics for the node_exporter textfile collector. The restic
    # unit's own timestamps are cleared when it becomes inactive, so the timer's
    # last trigger is the reliable "last run" timestamp.
    systemd.services.restic-metrics = {
      description = "Export restic backup status for Prometheus";
      after = ["restic-backups-${hostname}.service"];
      path = [config.systemd.package pkgs.coreutils];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };

      script = ''
        set -eu
        unit="restic-backups-${hostname}.service"
        timer="restic-backups-${hostname}.timer"
        state=/var/lib/restic-metrics
        out=/var/lib/node-exporter/textfile/restic.prom

        mkdir -p "$state" "$(dirname "$out")"

        result=$(systemctl show "$unit" -p Result --value 2>/dev/null || true)
        status=$(systemctl show "$unit" -p ExecMainStatus --value 2>/dev/null || true)
        last=$(systemctl show "$timer" -p LastTriggerUSec --timestamp=unix --value 2>/dev/null || true)
        last=''${last#@}
        case "$last" in
          "" | n/a | *[!0-9]*) last=0 ;;
        esac

        success=0
        if [ "$result" = "success" ] && [ "$status" = "0" ] && [ "$last" -gt 0 ]; then
          success=1
          echo "$last" > "$state/last-success"
        fi

        last_success=0
        if [ -r "$state/last-success" ]; then
          last_success=$(cat "$state/last-success")
        fi

        {
          echo '# HELP restic_last_run_success Whether the last scheduled restic run succeeded.'
          echo '# TYPE restic_last_run_success gauge'
          echo "restic_last_run_success{host=\"${hostname}\"} $success"
          echo '# HELP restic_last_run_exit_code Exit code of the last restic run.'
          echo '# TYPE restic_last_run_exit_code gauge'
          echo "restic_last_run_exit_code{host=\"${hostname}\"} ''${status:-0}"
          echo '# HELP restic_last_run_timestamp_seconds Start time of the last scheduled restic run.'
          echo '# TYPE restic_last_run_timestamp_seconds gauge'
          echo "restic_last_run_timestamp_seconds{host=\"${hostname}\"} $last"
          echo '# HELP restic_last_success_timestamp_seconds Time of the last successful restic run.'
          echo '# TYPE restic_last_success_timestamp_seconds gauge'
          echo "restic_last_success_timestamp_seconds{host=\"${hostname}\"} $last_success"
        } > "$out.tmp"

        mv "$out.tmp" "$out"
      '';
    };

    systemd.timers.restic-metrics = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "15m";
        Persistent = true;
      };
    };
  };
}
