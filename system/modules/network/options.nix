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

  wireguard-tunnels = mkOption {
    type = types.attrs;
    default = {};
    description = "Wireguard VPN Tunnels";
    example = ''
      wg0-de-115 = {
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
}
