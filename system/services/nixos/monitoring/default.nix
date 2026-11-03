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
            expr = ''up{job=~"pve|blackbox.*"} == 0'';
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
            expr = ''predict_linear(node_filesystem_avail_bytes{${fsSelector}}[6h], 86400) < 0'';
            duration = "1h";
            summary = "{{ $labels.instance }}: {{ $labels.mountpoint }} will fill up within 24h";
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
            expr = ''pve_up == 0'';
            duration = "3m";
            severity = "critical";
            summary = "Proxmox VE {{ $labels.instance }} is not reachable";
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
    };
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
