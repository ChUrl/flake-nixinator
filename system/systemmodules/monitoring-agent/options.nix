{
  lib,
  mylib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
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
}
