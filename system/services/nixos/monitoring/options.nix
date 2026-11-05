{
  lib,
  mylib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
  inherit (mylib.modules) mkBoolOption;
in {
  enable = mkEnableOption "the central Prometheus/Grafana monitoring stack";

  grafanaPort = mkOption {
    type = types.port;
    default = 3030;
    description = ''
      Loopback port of Grafana. The default avoids 3000/3001, which are used by
      gitea and other services on servenix.
    '';
  };

  prometheusPort = mkOption {
    type = types.port;
    default = 9090;
    description = "Loopback port of Prometheus.";
  };

  alertmanagerPort = mkOption {
    type = types.port;
    default = 9093;
    description = "Loopback port of Alertmanager.";
  };

  retentionTime = mkOption {
    type = types.str;
    default = "30d";
    description = "How long Prometheus keeps samples (e.g. `30d`, `1y`).";
  };

  prometheusDataDir = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = ''
      Move Prometheus' time-series database to this directory (e.g. a
      dedicated SSD). It is bind-mounted over the service's state directory;
      the directory is created with mode 0700 and owned by `prometheus`.

      Leave null to keep the data under /var/lib.
    '';
    example = ''"/home/christoph/ssd/prometheus"'';
  };

  scrapeInterval = mkOption {
    type = types.str;
    default = "30s";
    description = "Default scrape interval.";
  };

  nodes = mkOption {
    type = types.attrsOf types.str;
    default = {};
    description = ''
      node_exporter targets, as `name = "host:port"`. The name becomes the
      `instance` label, so alerts read `servenix is not responding` instead of
      an IP address.
    '';
    example = ''
      {
        servenix = "127.0.0.1:9100";
        thinknix = "192.168.86.26:9100";
      }
    '';
  };

  proxmoxTargets = mkOption {
    type = types.listOf types.str;
    default = [];
    description = ''
      Proxmox VE API endpoints polled by prometheus-pve-exporter. Both the PVE
      hosts and their guests/storage are exported from these.
    '';
    example = ''["192.168.86.4" "192.168.86.13"]'';
  };

  probes = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        url = mkOption {
          type = types.str;
          description = "URL the blackbox exporter probes.";
        };

        module = mkOption {
          type = types.enum ["http_2xx" "tcp_connect" "icmp" "dns_public" "dns_lan" "https_local_cert"];
          default = "http_2xx";
          description = "Blackbox probe module.";
        };
      };
    });
    default = {};
    description = ''
      End-to-end probes (HTTP status, latency, TLS expiry, ICMP, DNS). The
      attribute name becomes the `probe` label.
    '';
  };

  smokeping = {
    enable = mkBoolOption true "Probe WAN latency and packet loss with smokeping_prober.";

    hosts = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Hosts to ping continuously.";
    };

    pingInterval = mkOption {
      type = types.str;
      default = "60s";
      description = "Interval between pings.";
    };
  };

  snmp.enable =
    mkBoolOption false
    "Scrape OPNsense (192.168.86.5), Synology (192.168.86.15) and TrueNAS (192.168.86.20) via SNMP.";

  ntfyTopic = mkOption {
    type = types.str;
    default = "alerts";
    description = "ntfy topic Alertmanager publishes to.";
  };

  ntfyUser = mkOption {
    type = types.str;
    default = "grafana";
    description = ''
      ntfy user Alertmanager authenticates as. Needs write access to
      `ntfyTopic` and its password in `ntfy-grafana-password`.
    '';
  };

  processExporter.enable =
    mkBoolOption true
    "Export per-process CPU/RAM for the native services on this host.";

  processExporter.names = mkOption {
    type = types.listOf types.attrs;
    default = [
      {
        name = "gitea";
        cmdline = ["gitea"];
      }
      {
        name = "immich";
        cmdline = ["immich"];
      }
      {
        name = "jellyfin";
        cmdline = ["jellyfin"];
      }
      {
        name = "nextcloud";
        cmdline = ["php-fpm"];
      }
      {
        name = "paperless";
        cmdline = ["paperless"];
      }
      {
        name = "actual";
        cmdline = ["actual"];
      }
      {
        name = "ntfy";
        cmdline = ["ntfy"];
      }
      {
        name = "kiwix";
        cmdline = ["kiwix"];
      }
      {
        name = "postgres";
        comm = ["postgres"];
      }
      {
        name = "caddy";
        comm = ["caddy"];
      }
      {
        name = "grafana";
        comm = ["grafana"];
      }
      {
        name = "prometheus";
        comm = ["prometheus"];
      }
    ];
    description = "process_exporter process groups.";
  };

  nvidiaGpu =
    mkBoolOption false
    "Export GPU utilisation/VRAM/temperature via nvidia-gpu-exporter (servenix only).";

  cadvisor =
    mkBoolOption true
    "Scrape the cAdvisor container on 127.0.0.1:8083 for Docker container metrics.";
}
