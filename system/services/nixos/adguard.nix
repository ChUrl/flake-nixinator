{lib, ...}: {
  # Backed up by systemmodules/restic
  systemmodules.restic.servicePaths = ["/var/lib/AdGuardHome"];

  # DNS for the LAN. TCP is needed for answers that don't fit into a UDP
  # datagram. The module's own openFirewall only opens the web UI.
  systemmodules.network.allowedTCPPorts = [53];
  systemmodules.network.allowedUDPPorts = [53];

  # DNS binds on all interfaces; the web UI is declared by the vhost below.
  systemmodules.network.extraPorts = {
    adguard-dns-tcp = {
      port = 53;
      address = "0.0.0.0";
    };
    adguard-dns-udp = {
      port = 53;
      address = "0.0.0.0";
      protocol = "udp";
    };
  };

  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.adguard = {port = 3000;};

  # Static owner (instead of the module's DynamicUser) so the state directory
  # migrated from the container has a predictable owner.
  users.groups.adguard.gid = 3002;
  users.users.adguard = {
    isSystemUser = true;
    group = "adguard";
    uid = 3002;
    home = "/var/lib/AdGuardHome";
  };

  services.adguardhome = {
    enable = true;

    # Everything else (upstreams, filters, rewrites, users) stays authoritative
    # in /var/lib/AdGuardHome/AdGuardHome.yaml and is edited in the UI.
    # Only the listen address is pinned: Caddy owns :80/:443 on this host.
    settings = {
      http.address = "127.0.0.1:3000";
    };

    mutableSettings = true;
  };

  systemd.services.adguardhome.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "adguard";
    Group = "adguard";
  };
}
