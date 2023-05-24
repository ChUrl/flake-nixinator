{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Systemd Network Configuration";

  hostname = mkOption {
    type = types.str;
    description = "The System's Hostname";
    example = ''
      "Nixinator"
    '';
  };

  networks = mkOption {
    type = types.attrSet;
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

  wireguard-tunnels = mkOption {
    type = types.attrSet;
    default = {};
    description = "Wireguard VPN Tunnels";
    example = ''
      wg0-de-115 = {
        [...]
      };
    '';
  };

  allowedTCPPorts = mkOption {
    type = types.list;
    default = [];
    description = "Open TCP Ports in the Firewall";
    example = ''
      [22 80 443]
    '';
  };

  allowedUDPPorts = mkOption {
    type = types.list;
    default = [];
    description = "Open UDP Ports in the Firewall";
    example = ''
      [22 80 443]
    '';
  };
}
