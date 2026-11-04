{
  config,
  lib,
  mylib,
  pkgs,
  hostname,
  ...
}: let
  cfg = config.systemmodules.monitoring-agent;

  alloyConfig = ''
    loki.source.journal "journal" {
      forward_to = [loki.write.default.receiver]
      labels = {
        "host" = "${hostname}",
      }
    }

    ${
      lib.optionalString cfg.logs.docker ''
        discovery.docker "containers" {
          host = "unix:///var/run/docker.sock"
        }

        discovery.relabel "containers" {
          targets = discovery.docker.containers.targets

          rule {
            source_labels = ["__meta_docker_container_name"]
            target_label  = "container"
            regex         = "/(.*)"
          }

          rule {
            target_label = "host"
            replacement  = "${hostname}"
          }
        }

        loki.source.docker "containers" {
          host       = "unix:///var/run/docker.sock"
          targets    = discovery.relabel.containers.output
          forward_to = [loki.write.default.receiver]
        }
      ''
    }

    loki.write "default" {
      endpoint {
        url = "${cfg.logs.lokiUrl}/loki/api/v1/push"
      }
    }
  '';
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

    services.alloy = lib.mkIf cfg.logs.enable {
      enable = true;
      extraFlags = ["--disable-reporting"];
    };

    environment.etc."alloy/config.alloy" = lib.mkIf cfg.logs.enable {
      text = alloyConfig;
    };

    # The Docker log collector needs read access to the Docker socket.
    systemd.services.alloy.serviceConfig.SupplementaryGroups =
      lib.mkIf cfg.logs.docker (lib.mkAfter ["docker"]);
  };
}
