{config, ...}: {
  sops.secrets."paperless-admin-password" = {};

  services.paperless = {
    enable = false;

    # Public URL for links/CSRF; Caddy terminates TLS in front of it.
    domain = "paperless.vps.chriphost.de";
    address = "127.0.0.1";
    port = 8000;

    # Fresh start: media/consume stay in the module's state dir.
    dataDir = "/var/lib/paperless";

    # Superuser "admin" with this password (change it in the UI afterwards)
    passwordFile = config.sops.secrets."paperless-admin-password".path;

    tesseractLanguages = [
      "deu"
      "eng"
    ];

    # Uses the shared services.postgresql instance
    database.createLocally = true;
  };
}
