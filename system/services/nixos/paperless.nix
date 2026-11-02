{config, ...}: {
  sops.secrets."paperless-admin-password" = {};

  services.paperless = {
    enable = true;

    # Public URL for links/CSRF; Caddy terminates TLS in front of it.
    domain = "paperless.vps.chriphost.de";
    address = "127.0.0.1";
    port = 8000;

    # Fresh start: media/consume stay in the module's state dir.
    dataDir = "/var/lib/paperless";

    # Superuser "admin" with this password (change it in the UI afterwards)
    passwordFile = config.sops.secrets."paperless-admin-password".path;

    settings = {
      # Caddy terminates TLS and forwards over HTTP; without this Django thinks
      # the request is insecure and the CSRF origin check fails.
      PAPERLESS_PROXY_SSL_HEADER = ''["HTTP_X_FORWARDED_PROTO", "https"]'';

      # Both names the browser may use (LAN and public)
      PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://paperless.local.chriphost.de,https://paperless.vps.chriphost.de";
      PAPERLESS_ALLOWED_HOSTS = "paperless.local.chriphost.de,paperless.vps.chriphost.de";
    };

    tesseractLanguages = [
      "deu"
      "eng"
    ];

    # Uses the shared services.postgresql instance
    database.createLocally = true;
  };
}
