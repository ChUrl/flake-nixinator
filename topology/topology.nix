{config, ...}: let
  inherit (config.lib.topology) mkInternet mkRouter mkConnection mkSwitch;
in {
  # Add a node for the internet
  nodes.internet = mkInternet {
    connections = mkConnection "router" "wan1";
  };

  nodes.switch = mkSwitch "Switch" {
    info = "TP-Link TL-SG108E";
    image = ./images/TPLinkTLSG108E.jpg;
    interfaceGroups = [["eth0" "eth1" "eth2" "eth3" "eth4" "eth5" "eth6" "eth7"]];
    # connections.eth1 = mkConnection "host1" "lan";
    # connections.eth2 = [(mkConnection "host2" "wan") (mkConnection "host3" "eth0")];

    # any other attributes specified here are directly forwarded to the node:
    interfaces.eth1.network = "home";
  };

  # Add a router that we use to access the internet
  nodes.router = mkRouter "Firewall" {
    info = "Protectli Vault FW2B";
    image = ./images/ProtectliVaultFW2B.png;
    interfaceGroups = [
      ["wan1"]
      ["eth1"]
    ];
    connections.eth1 = mkConnection "switch" "eth0";
    interfaces.eth1 = {
      addresses = ["192.168.86.5"];
      network = "home";
    };
  };

  networks.home = {
    name = "Mafia Home";
    cidrv4 = "192.168.86.0/24";
  };
}
