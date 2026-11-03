{config, ...}: {
  # Backed up by systemmodules/restic (DynamicUser state lives in /var/lib/private)
  systemmodules.restic.servicePaths = ["/var/lib/private/ntfy-sh"];

  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.ntfy = {
    port = 8042;
    aliases = ["ntfy.vps.chriphost.gay"];
  };

  sops.secrets."ntfy-auth-users" = {};
  sops.secrets."ntfy-auth-tokens" = {};

  # Users and tokens are re-synchronised from sops on every start, so the old
  # auth database does not have to be carried over.
  sops.templates."ntfy_secrets.env".content = ''
    NTFY_AUTH_USERS=${config.sops.placeholder."ntfy-auth-users"}
    NTFY_AUTH_TOKENS=${config.sops.placeholder."ntfy-auth-tokens"}
  '';

  services.ntfy-sh = {
    enable = true;
    environmentFile = config.sops.templates."ntfy_secrets.env".path;

    settings = {
      base-url = "https://ntfy.vps.chriphost.gay";
      listen-http = "127.0.0.1:8042";
      behind-proxy = true;

      auth-file = "/var/lib/ntfy-sh/user.db";
      auth-default-access = "deny-all";
      auth-access = [
        "christoph:*:read-write"
        # Alertmanager publishes to the monitoring topic only.
        "grafana:alerts:write-only"
      ];
      enable-login = true;
      require-login = true;

      cache-file = "/var/lib/ntfy-sh/cache-file.db";
      attachment-cache-dir = "/var/lib/ntfy-sh/attachments";
      upstream-base-url = "https://ntfy.sh";
    };
  };
}
