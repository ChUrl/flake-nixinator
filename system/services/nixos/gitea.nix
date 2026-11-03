{lib, ...}: {
  # uid matches the container's USER_UID, so the copied /data volume keeps its
  # ownership and needs no chown.
  users.users.gitea.uid = 500;

  services.gitea = {
    enable = true;
    stateDir = "/var/lib/gitea";

    database = {
      type = "postgres";
      createDatabase = true;
      name = "gitea";
      user = "gitea";
    };

    lfs = {
      enable = true;

      # Old container stored LFS objects in /data/git/lfs
      contentDir = "/var/lib/gitea/git/lfs";
    };

    settings = {
      server = {
        # Public identity (links, clone URLs, LFS endpoint)
        SSH_DOMAIN = "gitea.vps.chriphost.gay";
        ROOT_URL = "https://gitea.vps.chriphost.gay/";

        # Internal hooks must not go through the public URL
        LOCAL_ROOT_URL = "http://127.0.0.1:3000/";

        # 0.0.0.0 so the runner container can reach it; the firewall only
        # allows 3000 on the docker bridges.
        HTTP_ADDR = "0.0.0.0";
        HTTP_PORT = 3000;

        START_SSH_SERVER = true;
        SSH_PORT = 222;
        SSH_LISTEN_PORT = 222;
        APP_DATA_PATH = "/var/lib/gitea/gitea";

        # Caddy terminates TLS in front of gitea
        REVERSE_PROXY_LIMIT = 1;
        REVERSE_PROXY_TRUSTED_PROXIES = "127.0.0.1";
      };

      # Behaviour carried over from the old app.ini
      repository = {
        USE_COMPAT_SSH_URI = true;
        ENABLE_PUSH_CREATE_USER = true;
        ENABLE_PUSH_CREATE_ORG = true;
      };

      security.INSTALL_LOCK = true;
    };

    # Keep the old container layout so /data can be copied 1:1
    repositoryRoot = "/var/lib/gitea/git/repositories";
  };

  networking.firewall.extraInputRules = ''
    iifname "br-*" tcp dport 3000 accept
  '';

  # The built-in SSH server listens on 222, which needs a privileged port
  # capability because gitea runs unprivileged. The module drops all
  # capabilities, so the bounding set has to be overridden.
  #
  # PrivateUsers must be disabled: inside a private user namespace the service
  # has no capabilities over the host network namespace, so it cannot bind
  # port 222 no matter which ambient capabilities are granted.
  systemd.services.gitea.serviceConfig = {
    AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
    CapabilityBoundingSet = lib.mkForce ["CAP_NET_BIND_SERVICE"];
    PrivateUsers = lib.mkForce false;
  };
}
