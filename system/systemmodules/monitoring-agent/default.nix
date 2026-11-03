{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  cfg = config.systemmodules.monitoring-agent;
in {
  options.systemmodules.monitoring-agent = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;

      inherit (cfg) listenAddress;
      port = 9100;

      # systemd: unit state/failed units, processes: process counts,
      # textfile: metrics written by other services (e.g. backup timestamps).
      enabledCollectors = ["systemd" "processes" "textfile"];
      extraFlags = [
        "--collector.textfile.directory=${cfg.textfileDirectory}"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.textfileDirectory} 0755 root root -"
    ];

    # Kept across reboots on hosts that use impermanence (nixinator).
    systemmodules.impermanence.directories = ["/var/lib/node-exporter"];

    networking.firewall.extraInputRules = ''
      ip saddr { ${lib.concatStringsSep ", " cfg.scrapeSources} } tcp dport 9100 accept
    '';
  };
}
