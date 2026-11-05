{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Systemd Network Configuration";

  useNetworkManager = mkEnableOption "Use NetworkManager instead of systemd-networkd";

  hostname = mkOption {
    type = types.str;
    description = "The System's Hostname";
    example = ''
      "Nixinator"
    '';
  };

  networks = mkOption {
    type = types.attrs;
    default = {};
    description = "Systemd-Networkd Networks";
    example = ''
      {
        "50-ether" = {
          [...]
        };
      }
    '';
  };

  profiles = mkOption {
    type = types.attrs;
    default = {};
    description = "NetworkManager Profiles";
    example = ''
      "50-ether" = {
        [...]
      };
    '';
  };

  allowedTCPPorts = mkOption {
    type = types.listOf types.int;
    default = [];
    description = "Open TCP Ports in the Firewall";
    example = ''
      [22 80 443]
    '';
  };

  allowedUDPPorts = mkOption {
    type = types.listOf types.int;
    default = [];
    description = "Open UDP Ports in the Firewall";
    example = ''
      [22 80 443]
    '';
  };

  checkPortCollisions = mkBoolOption true ''
    Fail evaluation when two services bind the same host socket.

    Sockets are collected from declarations that already exist: container port
    mappings (`ports`), host-network container flags (`--port`, `--listen_ip`),
    `systemmodules.caddy.vhosts.*.port`, `services.nginx.virtualHosts.*.listen`,
    the caddy ports, and the options of common services (postgresql, prometheus
    and its exporters, grafana, loki, gatus, alloy, immich, mailpit, openssh,
    gitea). Use `extraPorts` for anything that declares its port nowhere else.
  '';

  extraPorts = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Address the service binds (\"*\" for all interfaces).";
        };

        port = mkOption {
          type = types.port;
          description = "Port the service binds.";
        };

        protocol = mkOption {
          type = types.enum ["tcp" "udp"];
          default = "tcp";
          description = "Transport protocol.";
        };
      };
    });
    default = {};
    description = ''
      Sockets of services whose port is not declared anywhere else (free-form
      daemons, host-network containers without a `--port` flag).

      The attribute name is only the owner label used in collision errors, so
      the port itself still lives in exactly one place.
    '';
    example = ''
      {
        scanopy-daemon = {port = 60073; address = "0.0.0.0";};
        dns-tcp = {port = 53; address = "0.0.0.0";};
        dns-udp = {port = 53; address = "0.0.0.0"; protocol = "udp";};
      }
    '';
  };
}
