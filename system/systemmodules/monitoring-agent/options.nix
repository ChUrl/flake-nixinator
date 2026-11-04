{
  lib,
  mylib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
  inherit (mylib.modules) mkBoolOption;
in {
  enable = mkEnableOption "node_exporter for the central monitoring stack";

  listenAddress = mkOption {
    type = types.str;
    default = "0.0.0.0";
    description = ''
      Address node_exporter binds to. Remote hosts keep `0.0.0.0` and rely on
      the firewall rule generated from `scrapeSources`; the host that runs
      Prometheus can bind to `127.0.0.1`.
    '';
  };

  scrapeSources = mkOption {
    type = types.listOf types.str;
    default = ["192.168.86.25" "10.10.10.0/24"];
    description = ''
      Source addresses allowed to reach node_exporter. Defaults to servenix on
      the LAN and the WireGuard network, so the VPS works without an override.
    '';
  };

  textfileDirectory = mkOption {
    type = types.str;
    default = "/var/lib/node-exporter/textfile";
    description = ''
      Directory for the textfile collector (backup timestamps and similar).
    '';
  };

  logs = {
    enable = mkBoolOption true "Ship journald logs to Loki via Grafana Alloy.";

    lokiUrl = mkOption {
      type = types.str;
      default = "http://192.168.86.25:3100";
      description = ''
        Loki push endpoint base URL. The host running Loki overrides this to
        `http://127.0.0.1:3100`.
      '';
    };

    docker =
      mkBoolOption false
      "Also collect Docker container logs (hosts that run Docker, currently servenix).";
  };
}
