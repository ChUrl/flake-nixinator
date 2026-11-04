{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  cfg = config.systemmodules.monitoring;

  # nixpkgs stores the TSDB in /var/lib/<versioned StateDirectory>/data
  # (currently "prometheus2"). Ask the unit instead of hardcoding it.
  prometheusStateDir = toString config.systemd.services.prometheus.serviceConfig.StateDirectory;
  prometheusStateDataDir = "/var/lib/${prometheusStateDir}/data";

  # The exporter's own $VAR expansion does not cover auths.community, so render
  # the config from sops at activation instead.
  snmpConfig =
    builtins.replaceStrings
    ["\${SNMP_COMMUNITY_OPNSENSE}" "\${SNMP_COMMUNITY_SYNOLOGY}" "\${SNMP_COMMUNITY_TRUENAS}"]
    [
      config.sops.placeholder."snmp-community-opnsense"
      config.sops.placeholder."snmp-community-synology"
      config.sops.placeholder."snmp-community-truenas"
    ]
    (builtins.readFile ./snmp.yml);

  # Plain HTTP checks. `valid_status_codes` includes the auth redirects of
  # Nextcloud/Paperless/Gitea, so the probe measures reachability and TLS, not
  # whether the login page answers 200.
  blackboxConfig = pkgs.writeText "blackbox.yml" (builtins.toJSON {
    modules = {
      http_2xx = {
        prober = "http";
        timeout = "5s";
        http = {
          preferred_ip_protocol = "ip4";
          valid_status_codes = [200 301 302 401 403];
        };
      };
      tcp_connect = {
        prober = "tcp";
        timeout = "5s";
      };
      icmp = {
        prober = "icmp";
        timeout = "5s";
      };
      dns_public = {
        prober = "dns";
        timeout = "5s";
        dns = {
          query_name = "chriphost.gay";
          query_type = "A";
          valid_rcodes = ["NOERROR"];
        };
      };
      dns_lan = {
        prober = "dns";
        timeout = "5s";
        dns = {
          query_name = "grafana.local.chriphost.gay";
          query_type = "A";
          valid_rcodes = ["NOERROR"];
        };
      };
      # Probes thinknix directly with SNI/Host for a local name, so the local
      # wildcard certificate's expiry is exported as well.
      https_local_cert = {
        prober = "http";
        timeout = "5s";
        http = {
          preferred_ip_protocol = "ip4";
          valid_status_codes = [200 301 302 401 403];
          headers.Host = "grafana.local.chriphost.gay";
          tls_config.server_name = "grafana.local.chriphost.gay";
        };
      };
    };
  });

  # Alerting rules live in Prometheus, not Grafana: they are plain YAML/JSON,
  # reviewable in git, and Alertmanager already handles the ntfy delivery.
  mkAlert = {
    alert,
    expr,
    duration,
    severity ? "warning",
    summary,
  }: {
    inherit alert expr;
    for = duration;
    labels.severity = severity;
    annotations = {inherit summary;};
  };

  fsSelector = ''fstype!~"tmpfs|ramfs|overlay|nfs|nfs4|fuse.*",mountpoint!~"/boot|/nix/store"'';

  # `services.prometheus.rules` takes rule content, not a file path.
  rulesContent = builtins.toJSON {
    groups = [
      {
        name = "monitoring";
        rules = [
          (mkAlert {
            alert = "HostDown";
            expr = ''up{job="node",instance!="nixinator"} == 0'';
            duration = "3m";
            severity = "critical";
            summary = "{{ $labels.instance }} is not responding";
          })
          (mkAlert {
            alert = "ExporterDown";
            expr = ''up{job=~"pve|blackbox.*|vps-wireguard|vps-fail2ban|caddy-.*|smokeping|nixinator-smart|snmp-.*|hass"} == 0'';
            duration = "10m";
            summary = "Exporter {{ $labels.job }} is down";
          })
          (mkAlert {
            alert = "FilesystemLow";
            expr = ''node_filesystem_avail_bytes{${fsSelector}} / node_filesystem_size_bytes{${fsSelector}} < 0.10'';
            duration = "10m";
            summary = "{{ $labels.instance }}: {{ $labels.mountpoint }} has less than 10% free";
          })
          (mkAlert {
            alert = "RootFilesystemLow";
            expr = ''node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} < 0.20'';
            duration = "10m";
            summary = "{{ $labels.instance }}: root filesystem is above 80%";
          })
          (mkAlert {
            alert = "FilesystemFullPrediction";
            expr = ''predict_linear(node_filesystem_avail_bytes{${fsSelector}}[24h], 7 * 24 * 3600) < 0 and node_filesystem_avail_bytes{${fsSelector}} / node_filesystem_size_bytes{${fsSelector}} < 0.25'';
            duration = "6h";
            summary = "{{ $labels.instance }}: {{ $labels.mountpoint }} will fill up within 7 days and has less than 25% free";
          })
          (mkAlert {
            alert = "MemoryLow";
            expr = ''node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.05'';
            duration = "10m";
            summary = "{{ $labels.instance }}: less than 5% memory available";
          })
          (mkAlert {
            alert = "SystemdUnitFailed";
            expr = ''node_systemd_unit_state{state="failed"} == 1'';
            duration = "5m";
            summary = "{{ $labels.instance }}: unit {{ $labels.name }} failed";
          })
          (mkAlert {
            alert = "PostgresDown";
            expr = ''pg_up == 0'';
            duration = "2m";
            severity = "critical";
            summary = "PostgreSQL exporter cannot reach the database";
          })
          (mkAlert {
            alert = "ProxmoxDown";
            expr = ''pve_up{id=~"node/.*|cluster/.*"} == 0'';
            duration = "3m";
            severity = "critical";
            summary = "Proxmox VE {{ $labels.id }} is not reachable";
          })
          (mkAlert {
            alert = "ProbeFailed";
            expr = ''probe_success == 0'';
            duration = "3m";
            severity = "critical";
            summary = "{{ $labels.probe }} is not reachable";
          })
          (mkAlert {
            alert = "CertificateExpiring";
            expr = ''probe_ssl_earliest_cert_expiry - time() < 14 * 24 * 3600'';
            duration = "1h";
            summary = "{{ $labels.probe }}: certificate expires in less than 14 days";
          })
          (mkAlert {
            alert = "CertificateExpiringCritical";
            expr = ''probe_ssl_earliest_cert_expiry - time() < 7 * 24 * 3600'';
            duration = "1h";
            severity = "critical";
            summary = "{{ $labels.probe }}: certificate expires in less than 7 days";
          })
          (mkAlert {
            alert = "ResticBackupFailed";
            expr = ''restic_last_run_success == 0'';
            duration = "10m";
            severity = "critical";
            summary = "{{ $labels.host }}: the last restic run failed";
          })
          (mkAlert {
            alert = "ResticBackupStale";
            expr = ''time() - restic_last_success_timestamp_seconds > 48 * 3600'';
            duration = "10m";
            severity = "critical";
            summary = "{{ $labels.host }}: no successful restic backup in 48h";
          })
          (mkAlert {
            alert = "PVEQuorumLost";
            expr = ''pve_cluster_info{quorate!="1"} == 1'';
            duration = "2m";
            severity = "critical";
            summary = "Proxmox cluster quorum lost";
          })
          (mkAlert {
            alert = "PVEGuestDown";
            expr = ''pve_up{id=~"qemu/.*",id!="qemu/108"} == 0'';
            duration = "5m";
            severity = "critical";
            summary = "PVE guest {{ $labels.id }} is not running";
          })
          (mkAlert {
            alert = "PVEStorageHigh";
            expr = ''pve_disk_usage_bytes{id=~"storage/.*"} / pve_disk_size_bytes{id=~"storage/.*"} > 0.95'';
            duration = "15m";
            summary = "PVE storage {{ $labels.id }} is above 95%";
          })
          (mkAlert {
            alert = "PVENodeSaturated";
            expr = ''pve_cpu_usage_ratio > 0.9'';
            duration = "15m";
            summary = "PVE node {{ $labels.id }} CPU above 90%";
          })
          (mkAlert {
            alert = "PVENotBackedUp";
            expr = ''pve_not_backed_up_total > 0'';
            duration = "1h";
            summary = "PVE reports guests without a backup";
          })
          (mkAlert {
            alert = "PVEBackupFailed";
            expr = ''pve_backup_last_status == 0'';
            duration = "10m";
            severity = "critical";
            summary = "PVE backup on {{ $labels.node }} failed";
          })
          (mkAlert {
            alert = "PVEBackupStale";
            expr = ''time() - pve_backup_last_timestamp_seconds > 10 * 24 * 3600'';
            duration = "1h";
            severity = "critical";
            summary = "PVE backup on {{ $labels.node }} is older than 10 days";
          })
          (mkAlert {
            alert = "WireGuardHandshakeStale";
            expr = ''time() - wireguard_latest_handshake_seconds{interface="wg0",public_key="bsvabi6V4XZx7ZS/53Tai0s1n0Tf/6KRvMn+9yNnymY="} > 600'';
            duration = "5m";
            summary = "WireGuard peer OPNsense has not handshaked in 10 minutes";
          })
          (mkAlert {
            alert = "WireGuardPeerMissing";
            expr = ''absent(wireguard_latest_handshake_seconds{interface="wg0",public_key="bsvabi6V4XZx7ZS/53Tai0s1n0Tf/6KRvMn+9yNnymY="})'';
            duration = "5m";
            summary = "WireGuard exporter no longer reports the OPNsense peer";
          })
          (mkAlert {
            alert = "SnmpDeviceUnreachable";
            expr = ''snmp_scrape_pdus_returned == 0'';
            duration = "5m";
            summary = "SNMP device {{ $labels.instance }} returned no PDUs";
          })
          (mkAlert {
            alert = "Caddy5xx";
            expr = ''sum(rate(caddy_http_requests_total{code=~"5.."}[5m])) > 0'';
            duration = "10m";
            summary = "Caddy is returning 5xx responses";
          })
          (mkAlert {
            alert = "CaddyUpstreamUnhealthy";
            expr = ''caddy_reverse_proxy_upstreams_healthy == 0'';
            duration = "5m";
            summary = "Caddy reports an unhealthy upstream";
          })
          (mkAlert {
            alert = "SmartFailure";
            expr = ''smartctl_device_smart_status != 1'';
            duration = "10m";
            severity = "critical";
            summary = "SMART health check failed on {{ $labels.instance }} {{ $labels.device }}";
          })
          (mkAlert {
            alert = "SmartMediaErrors";
            expr = ''smartctl_device_media_errors > 0'';
            duration = "10m";
            summary = "SMART media errors on {{ $labels.instance }} {{ $labels.device }}";
          })
          (mkAlert {
            alert = "SmartTemperature";
            expr = ''smartctl_device_temperature_celsius > 55'';
            duration = "15m";
            summary = "SMART temperature high on {{ $labels.instance }} {{ $labels.device }}";
          })
          (mkAlert {
            alert = "PVEDiskHealth";
            expr = ''pve_disk_health == 0'';
            duration = "10m";
            severity = "critical";
            summary = "PVE disk {{ $labels.disk }} on {{ $labels.node }} reports FAILED";
          })
          (mkAlert {
            alert = "PVEDiskWearout";
            expr = ''pve_disk_wearout > 90'';
            duration = "1h";
            summary = "PVE disk {{ $labels.disk }} on {{ $labels.node }} is above 90% wearout";
          })
          (mkAlert {
            alert = "PVEDiskTemperature";
            expr = ''pve_disk_temperature_celsius > 55'';
            duration = "15m";
            summary = "PVE disk {{ $labels.disk }} on {{ $labels.node }} is above 55°C";
          })
          (mkAlert {
            alert = "HassDown";
            expr = ''up{job="hass"} == 0'';
            duration = "5m";
            summary = "Home Assistant Prometheus endpoint is down";
          })
          (mkAlert {
            alert = "Fail2banSocketDown";
            expr = ''f2b_up == 0'';
            duration = "5m";
            summary = "Fail2ban exporter on {{ $labels.instance }} cannot reach the fail2ban socket";
          })
          (mkAlert {
            alert = "Fail2banSocketErrors";
            expr = ''increase(f2b_errors{type=~"socket_.*"}[15m]) > 0'';
            duration = "5m";
            summary = "Fail2ban exporter on {{ $labels.instance }} has socket errors";
          })
          (mkAlert {
            alert = "Fail2banManyBans";
            expr = ''sum by (jail, instance) (f2b_jail_banned_current) > 20'';
            duration = "15m";
            summary = "Fail2ban jail {{ $labels.jail }} on {{ $labels.instance }} has more than 20 banned IPs";
          })
          (mkAlert {
            alert = "SmokepingPacketLoss";
            expr = ''(sum by (host) (rate(smokeping_requests_total[10m])) - sum by (host) (rate(smokeping_response_duration_seconds_count[10m]))) / sum by (host) (rate(smokeping_requests_total[10m])) > 0.05'';
            duration = "15m";
            summary = "Packet loss to {{ $labels.host }} is above 5%";
          })
        ];
      }
    ];
  };

  # One static_config per node so the name (not the IP) becomes `instance`.
  nodeStaticConfigs =
    lib.mapAttrsToList (name: target: {
      targets = [target];
      labels.instance = name;
    })
    cfg.nodes;

  blackboxJobs = let
    modules = lib.unique (map (probe: probe.module) (lib.attrValues cfg.probes));
  in
    map (module: {
      job_name = "blackbox-${module}";
      metrics_path = "/probe";
      params.module = [module];
      static_configs = lib.mapAttrsToList (name: probe: {
        targets = [probe.url];
        labels.probe = name;
      }) (lib.filterAttrs (_: probe: probe.module == module) cfg.probes);
      relabel_configs = [
        {
          source_labels = ["__address__"];
          target_label = "__param_target";
        }
        {
          source_labels = ["__param_target"];
          target_label = "instance";
        }
        {
          target_label = "__address__";
          replacement = "127.0.0.1:9115";
        }
      ];
    })
    modules;

  # One SNMP job per device; the auth is selected by the exporter's `auth`
  # query parameter, so all devices can share the same module definitions.
  snmpJob = name: target: auth: modules: {
    job_name = name;
    metrics_path = "/snmp";
    params = {
      auth = [auth];
      module = modules;
    };
    static_configs = [{targets = [target];}];
    relabel_configs = [
      {
        source_labels = ["__address__"];
        target_label = "__param_target";
      }
      {
        source_labels = ["__param_target"];
        target_label = "instance";
      }
      {
        target_label = "__address__";
        replacement = "127.0.0.1:9116";
      }
    ];
  };

  scrapeConfigs =
    lib.optional (cfg.nodes != {}) {
      job_name = "node";
      scrape_interval = cfg.scrapeInterval;
      static_configs = nodeStaticConfigs;
    }
    ++ lib.optional (cfg.proxmoxTargets != []) {
      job_name = "pve";
      metrics_path = "/pve";
      static_configs = [{targets = cfg.proxmoxTargets;}];
      relabel_configs = [
        {
          source_labels = ["__address__"];
          target_label = "__param_target";
        }
        {
          source_labels = ["__param_target"];
          target_label = "instance";
        }
        {
          target_label = "__address__";
          replacement = "127.0.0.1:9221";
        }
      ];
    }
    ++ blackboxJobs
    ++ [
      {
        job_name = "prometheus";
        static_configs = [{targets = ["127.0.0.1:${toString cfg.prometheusPort}"];}];
      }
      {
        job_name = "alertmanager";
        static_configs = [{targets = ["127.0.0.1:${toString cfg.alertmanagerPort}"];}];
      }
      {
        job_name = "caddy";
        static_configs = [{targets = ["127.0.0.1:2019"];}];
      }
    ]
    ++ lib.optional config.services.postgresql.enable {
      job_name = "postgres";
      static_configs = [{targets = ["127.0.0.1:9187"];}];
    }
    ++ lib.optional cfg.cadvisor {
      job_name = "cadvisor";
      static_configs = [{targets = ["127.0.0.1:8083"];}];
    }
    ++ lib.optional cfg.processExporter.enable {
      job_name = "process";
      static_configs = [{targets = ["127.0.0.1:9256"];}];
    }
    ++ lib.optional cfg.nvidiaGpu {
      job_name = "nvidia";
      static_configs = [{targets = ["127.0.0.1:9835"];}];
    }
    ++ lib.optional cfg.smokeping.enable {
      job_name = "smokeping";
      static_configs = [{targets = ["127.0.0.1:9374"];}];
    }
    ++ [
      {
        job_name = "vps-wireguard";
        static_configs = [{targets = ["10.10.10.1:9586"];}];
      }
      {
        job_name = "vps-fail2ban";
        static_configs = [{targets = ["10.10.10.1:9191"];}];
      }
      {
        job_name = "caddy-thinknix";
        static_configs = [{targets = ["192.168.86.26:9180"];}];
      }
      {
        job_name = "caddy-vps";
        static_configs = [{targets = ["10.10.10.1:9180"];}];
      }
      {
        job_name = "nixinator-smart";
        static_configs = [{targets = ["192.168.86.50:9633"];}];
      }
    ]
    ++ lib.optional (cfg.hassTarget != null) {
      job_name = "hass";
      metrics_path = "/api/prometheus";
      static_configs = [{targets = [cfg.hassTarget];}];
      authorization = {
        type = "Bearer";
        credentials_file = config.sops.secrets."hass-prometheus-token".path;
      };
    }
    ++ lib.optionals cfg.snmp.enable [
      (snmpJob "snmp-opnsense" "192.168.86.5" "opnsense" ["if_mib" "hrSystem" "hrStorage" "ucd_memory" "ucd_system_stats" "system"])
      (snmpJob "snmp-synology" "192.168.86.15" "synology" ["synology" "if_mib" "hrSystem" "hrStorage" "ucd_memory" "ucd_system_stats" "ucd_la_table" "system"])
      (snmpJob "snmp-truenas" "192.168.86.20" "truenas" ["if_mib" "hrSystem" "hrStorage" "ucd_memory" "ucd_system_stats" "system"])
    ];
in {
  options.systemmodules.monitoring = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # ---------------------------------------------------------------- metrics
      services.prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = cfg.prometheusPort;
        retentionTime = cfg.retentionTime;

        # The HA bearer token is a runtime file; full promtool checks cannot
        # see it inside the Nix sandbox.
        checkConfig = "syntax-only";

        inherit scrapeConfigs;
        rules = [rulesContent];

        alertmanager = {
          enable = true;
          listenAddress = "127.0.0.1";
          port = cfg.alertmanagerPort;

          # The password is interpolated by envsubst (see the template below),
          # because Alertmanager runs as a DynamicUser and cannot own a file.
          environmentFile = config.sops.templates."alertmanager.env".path;

          configuration = {
            global.resolve_timeout = "5m";

            route = {
              receiver = "ntfy";
              group_by = ["alertname" "instance"];
              group_wait = "30s";
              group_interval = "5m";
              repeat_interval = "4h";
            };

            receivers = [
              {
                name = "ntfy";

                webhook_configs = [
                  {
                    # ntfy >= 2.14 understands Alertmanager's payload natively.
                    url = "http://127.0.0.1:8042/${cfg.ntfyTopic}?template=alertmanager";
                    send_resolved = true;

                    http_config.basic_auth = {
                      username = cfg.ntfyUser;
                      password = "$NTFY_GRAFANA_PASSWORD";
                    };
                  }
                ];
              }
            ];
          };
        };
      };

      # ------------------------------------------------------------- exporters
      services.prometheus.exporters.blackbox = lib.mkIf (cfg.probes != {}) {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9115;
        configFile = blackboxConfig;
      };

      services.prometheus.exporters.pve = lib.mkIf (cfg.proxmoxTargets != []) {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9221;
        environmentFile = config.sops.templates."pve-exporter.env".path;
      };

      # Connects through the local unix socket as the postgres super user, so
      # no password has to be managed.
      services.prometheus.exporters.postgres = lib.mkIf config.services.postgresql.enable {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9187;
        runAsLocalSuperUser = true;
      };

      services.prometheus.exporters.process = lib.mkIf cfg.processExporter.enable {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9256;
        settings.process_names = cfg.processExporter.names;
      };

      services.prometheus.exporters.nvidia-gpu = lib.mkIf cfg.nvidiaGpu {
        enable = true;
        listenAddress = "127.0.0.1";
      };

      services.prometheus.exporters.smokeping = lib.mkIf cfg.smokeping.enable {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9374;
        hosts = cfg.smokeping.hosts;
        pingInterval = cfg.smokeping.pingInterval;
      };

      services.prometheus.exporters.snmp = lib.mkIf cfg.snmp.enable {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9116;
        configurationPath = config.sops.templates."snmp.yml".path;
        enableConfigCheck = false;
      };

      # --------------------------------------------------------------- grafana
      services.grafana = {
        enable = true;

        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = cfg.grafanaPort;
            domain = "grafana.local.chriphost.gay";
            root_url = "https://grafana.local.chriphost.gay/";
            serve_from_sub_path = false;
          };

          security = {
            admin_user = "admin";
            # Read from the sops-rendered files at runtime; never written to
            # the Nix store.
            admin_password = "$__file{${config.sops.secrets."grafana-admin-password".path}}";
            secret_key = "$__file{${config.sops.secrets."grafana-secret-key".path}}";
            disable_gravatar = true;
            cookie_secure = true;
            allow_embedding = false;
          };

          users.allow_sign_up = false;
          analytics = {
            reporting_enabled = false;
            check_for_updates = false;
          };
          "auth.anonymous".enabled = false;
          log.mode = "console";
        };

        provision = {
          datasources.settings.datasources = [
            {
              name = "Prometheus";
              uid = "prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:${toString cfg.prometheusPort}";
              isDefault = true;
              editable = false;
              jsonData.timeInterval = cfg.scrapeInterval;
            }
            {
              name = "Alertmanager";
              uid = "alertmanager";
              type = "alertmanager";
              access = "proxy";
              url = "http://127.0.0.1:${toString cfg.alertmanagerPort}";
              editable = false;
              jsonData.implementation = "prometheus";
            }
          ];

          dashboards.settings.providers = [
            {
              name = "monitoring";
              orgId = 1;
              folder = "Monitoring";
              type = "file";
              disableDeletion = false;
              updateIntervalSeconds = 30;
              allowUiUpdates = false;
              options.path = ./dashboards;
            }
          ];
        };
      };

      # ------------------------------------------------------- reverse proxy
      # Served as grafana.local.chriphost.gay by systemmodules.caddy.
      systemmodules.caddy.vhosts.grafana = {
        port = cfg.grafanaPort;
      };

      # LAN-only Prometheus UI/API.
      systemmodules.caddy.vhosts.prometheus = {
        port = cfg.prometheusPort;
      };

      # ------------------------------------------------ impermanence/restic
      systemmodules.impermanence.directories = [
        "/var/lib/${prometheusStateDir}"
        "/var/lib/grafana"
        "/var/lib/alertmanager"
      ];

      # Dashboards/datasources are provisioned; only the Grafana database
      # (users, preferences) is worth backing up.
      systemmodules.restic.servicePaths = ["/var/lib/grafana"];

      # ---------------------------------------------------------------- secrets
      # Grafana reads these directly (file provider), so they must be readable
      # by its user.
      sops.secrets."grafana-admin-password" = {
        owner = "grafana";
        group = "grafana";
        mode = "0400";
      };
      sops.secrets."grafana-secret-key" = {
        owner = "grafana";
        group = "grafana";
        mode = "0400";
      };

      sops.secrets."proxmox-monitor-token" = {};

      # Read by Alertmanager, which runs unprivileged.
      sops.secrets."ntfy-grafana-password" = {};

      sops.secrets."snmp-community-opnsense" = {};
      sops.secrets."snmp-community-synology" = {};
      sops.secrets."snmp-community-truenas" = {};

      # Prometheus reads this via authorization.credentials_file.
      sops.secrets."hass-prometheus-token" = {
        owner = "prometheus";
        group = "prometheus";
        mode = "0400";
      };

      sops.templates."snmp.yml" = {
        # Read by the exporter's DynamicUser; lives in tmpfs, not the store.
        mode = "0444";
        content = snmpConfig;
        restartUnits = ["prometheus-snmp-exporter.service"];
      };

      # systemd reads EnvironmentFile as root; the exporter does not need
      # access to the rendered file.
      sops.templates."alertmanager.env" = {
        mode = "0400";

        content = ''
          NTFY_GRAFANA_PASSWORD=${config.sops.placeholder."ntfy-grafana-password"}
        '';
      };

      # systemd reads EnvironmentFile as root, so the exporter does not need
      # access to the rendered file. Both Proxmox nodes are in one cluster, so
      # a single token authenticates against .4 and .13.
      sops.templates."pve-exporter.env" = {
        mode = "0400";

        content = ''
          PVE_USER=monitoring@pve
          PVE_TOKEN_NAME=prometheus
          PVE_TOKEN_VALUE=${config.sops.placeholder."proxmox-monitor-token"}
          PVE_VERIFY_SSL=false
        '';
      };
    }

    # PVE/PVF backup freshness. The pve-exporter does not expose task history,
    # so query the API with the same token and write textfile metrics.
    (lib.mkIf (cfg.proxmoxTargets != []) {
      systemd.services.pve-backup-metrics = {
        description = "Export Proxmox backup task status for Prometheus";
        after = ["sops-install-secrets.service"];
        path = [pkgs.curl pkgs.jq pkgs.coreutils];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };

        script = ''
          set -eu
          set -a
          . ${config.sops.templates."pve-exporter.env".path}
          set +a

          out=/var/lib/node-exporter/textfile/pve-backup.prom
          mkdir -p "$(dirname "$out")"
          tmp="$out.tmp"
          : > "$tmp"

          for node in pve pvf; do
            case "$node" in
              pve) host=192.168.86.4 ;;
              pvf) host=192.168.86.13 ;;
            esac

            curl -sk \
              -H "Authorization: PVEAPIToken=''${PVE_USER}!''${PVE_TOKEN_NAME}=''${PVE_TOKEN_VALUE}" \
              "https://$host:8006/api2/json/nodes/$node/tasks?typefilter=vzdump&limit=200" |
              jq -r --arg node "$node" '
                .data
                | map(select(.status != null and .endtime != null))
                | max_by(.starttime) // empty
                | "pve_backup_last_status{node=\"\($node)\"} \(if .status == "OK" then 1 else 0 end)\npve_backup_last_timestamp_seconds{node=\"\($node)\"} \(.endtime)\npve_backup_last_duration_seconds{node=\"\($node)\"} \(.endtime - .starttime)"
              ' >> "$tmp" || true
          done

          mv "$tmp" "$out"
        '';
      };

      systemd.timers.pve-backup-metrics = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "10m";
          OnUnitActiveSec = "1h";
          Persistent = true;
        };
      };

      # PVE has no smartctl_exporter package; the API's disks/list and
      # disks/smart endpoints give health, wearout and SMART text without
      # installing anything on the Proxmox hosts.
      systemd.services.pve-disk-metrics = {
        description = "Export PVE disk SMART health for Prometheus";
        after = ["sops-install-secrets.service"];
        path = [pkgs.curl pkgs.jq pkgs.coreutils pkgs.gawk];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };

        script = ''
          set -eu
          set -a
          . ${config.sops.templates."pve-exporter.env".path}
          set +a

          out=/var/lib/node-exporter/textfile/pve-disks.prom
          mkdir -p "$(dirname "$out")"
          tmp="$out.tmp"
          : > "$tmp"

          auth="PVEAPIToken=''${PVE_USER}!''${PVE_TOKEN_NAME}=''${PVE_TOKEN_VALUE}"

          for node in pve pvf; do
            case "$node" in
              pve) host=192.168.86.4 ;;
              pvf) host=192.168.86.13 ;;
            esac

            curl -sk -H "Authorization: $auth" \
              "https://$host:8006/api2/json/nodes/$node/disks/list" |
              jq -r '.data[] | [.devpath, (.health // "UNKNOWN"), (.wearout // "N/A"), (.type // "unknown"), (.size // 0)] | @tsv' |
              while IFS=$'\t' read -r dev health wearout type size; do
                case "$wearout" in
                  "" | N/A | *[!0-9]*) wearout=-1 ;;
                esac
                case "$health" in
                  PASSED) health_val=1 ;;
                  FAILED) health_val=0 ;;
                  *) health_val=-1 ;;
                esac

                temp=$(curl -sk -H "Authorization: $auth" \
                  "https://$host:8006/api2/json/nodes/$node/disks/smart?disk=$dev" |
                  jq -r 'if .data.text then (.data.text | capture("Temperature:\s+(?<t>[0-9]+) Celsius").t? // "") else ([.data.attributes[]? | select(.name == "Temperature_Celsius" or .name == "Airflow_Temperature_Cel") | (.raw | tostring)] | first // "") end' |
                  awk 'NF {print $1; exit}')
                case "$temp" in "" | *[!0-9]*) temp=-1 ;; esac

                {
                  echo "pve_disk_health{node=\"$node\",disk=\"$dev\",type=\"$type\"} $health_val"
                  echo "pve_disk_wearout{node=\"$node\",disk=\"$dev\"} $wearout"
                  echo "pve_disk_temperature_celsius{node=\"$node\",disk=\"$dev\"} $temp"
                  echo "pve_disk_size_bytes{node=\"$node\",disk=\"$dev\"} $size"
                } >> "$tmp"
              done || true
          done

          mv "$tmp" "$out"
        '';
      };

      systemd.timers.pve-disk-metrics = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "15m";
          OnUnitActiveSec = "1h";
          Persistent = true;
        };
      };
    })

    # Optional: put the TSDB on a dedicated disk. systemd applies bind mounts
    # before ProtectHome, so a source inside /home works without weakening the
    # sandbox. The destination is the module's own state directory, so the unit
    # keeps its default ExecStart.
    (lib.mkIf (cfg.prometheusDataDir != null) {
      systemd.tmpfiles.rules = [
        "d ${cfg.prometheusDataDir} 0700 prometheus prometheus -"
        "d ${prometheusStateDataDir} 0700 prometheus prometheus -"
      ];

      # If the disk fails to mount, do not fall back to writing the TSDB onto
      # the root filesystem.
      systemd.services.prometheus.unitConfig.RequiresMountsFor = [
        (builtins.dirOf cfg.prometheusDataDir)
      ];

      systemd.services.prometheus.serviceConfig.BindPaths = [
        "${cfg.prometheusDataDir}:${prometheusStateDataDir}"
      ];
    })
  ]);
}
