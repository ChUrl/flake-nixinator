{
  # Backed up by systemmodules/restic
  systemmodules.restic.servicePaths = ["/var/lib/actual"];

  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.budget = {port = 5006;};

  users.groups.actual.gid = 3001;
  users.users.actual = {
    isSystemUser = true;
    group = "actual";
    uid = 3001;
    home = "/var/lib/actual";
  };

  services.actual = {
    enable = true;

    # Static user (instead of the module's DynamicUser) so the data from the
    # old container volume can be migrated with a known UID.
    user = "actual";
    group = "actual";

    settings = {
      hostname = "127.0.0.1";
      port = 5006;
      dataDir = "/var/lib/actual";
    };
  };
}
