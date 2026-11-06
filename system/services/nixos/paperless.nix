{
  config,
  lib,
  pkgs,
  ...
}: let
  # Folder trees whose PDFs are mirrored into Paperless' consume dir.
  # Everything below a path is walked recursively; the path relative to it
  # becomes the tag chain in Paperless (with PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS).
  pdfSourcePaths = let
    nextcloud = "/var/lib/nextcloud/data/christoph/files";
  in [
    "${nextcloud}/Documents"
  ];

  importScript = pkgs.writeShellScript "paperless-nc-import" ''
    set -euo pipefail

    state=/var/lib/paperless-nc-import/state.tsv
    staging=/var/lib/paperless-nc-import/staging
    consume='${config.services.paperless.consumptionDir}'

    ${pkgs.coreutils}/bin/mkdir -p "$staging" "$consume"
    ${pkgs.coreutils}/bin/touch "$state"
    ${pkgs.findutils}/bin/find "$staging" -type f -delete

    roots=(${lib.escapeShellArgs pdfSourcePaths})

    for root in "''${roots[@]}"; do
      ${pkgs.findutils}/bin/find "$root" -xdev -type f -iname '*.pdf' -print0 |
      while IFS= read -r -d "" file; do
        # size + mtime + inode instead of find -newer: Nextcloud preserves the
        # mtime of the client that uploaded a file, so a PDF added today can
        # carry a mtime from years back and find -newer would miss it.
        meta=$(${pkgs.coreutils}/bin/stat -c '%s %Y %i' "$file")

        if ${pkgs.gnugrep}/bin/grep -qxF "$meta $file" "$state"; then
          continue
        fi

        rel=''${file#"$root"/}
        target="$consume/$rel"

        # The consume subdirs must be writable by the paperless user, or the
        # consumer cannot delete what it has consumed. Position: 0640 is set
        # below, so the consumer (and only it) can read the file.
        ${pkgs.coreutils}/bin/install -d -o paperless -g paperless -m 0755 "$(dirname "$target")"
        # Copy+chown into staging first, then rename into the consume dir:
        # the consumer only ever sees complete files, and both sides live on
        # the same filesystem, so the rename is atomic.
        ${pkgs.coreutils}/bin/install -o paperless -g paperless -m 0640 "$file" "$staging/pending"
        ${pkgs.coreutils}/bin/mv -f "$staging/pending" "$target"

        ${pkgs.coreutils}/bin/printf '%s %s\n' "$meta" "$file" >> "$state"
      done
    done
  '';
in {
  sops.secrets."paperless-admin-password" = {};

  # Backed up by systemmodules/restic
  systemmodules.restic.servicePaths = [config.services.paperless.dataDir];

  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.paperless = {
    port = config.services.paperless.port;
    aliases = ["paperless.vps.chriphost.gay"];
  };

  services.paperless = {
    enable = true;

    # Public URL for links/CSRF; Caddy terminates TLS in front of it.
    domain = "paperless.vps.chriphost.gay";
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
      PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://paperless.local.chriphost.gay,https://paperless.vps.chriphost.gay";
      PAPERLESS_ALLOWED_HOSTS = "paperless.local.chriphost.gay,paperless.vps.chriphost.gay";

      # Payslips and similar repeat several dates in the text (pay period,
      # payment date, birth date, entry date) and Paperless takes the first
      # one it finds. The source filenames carry ISO dates, so a filename
      # date wins over the text here.
      PAPERLESS_FILENAME_DATE_ORDER = "DMY";

      # Understands German month names in text dates; set explicitly instead
      # of being inferred from the OCR language config.
      PAPERLESS_DATE_PARSER_LANGUAGES = "de+en";

      # paperless-nc-import below mirrors the Nextcloud PDF tree into the
      # consume dir.
      # Nested folders are walked and their names become tags; the byte size +
      # mtime + inode key in the state file means a reset of the state drops
      # everything again instead of creating duplicates.
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      PAPERLESS_CONSUMER_DELETE_DUPLICATES = true;
      # Poll instead of inotify: the bulk first import creates hundreds of
      # nested dirs in the consume dir at once and the watch limit of inotify
      # does not survive that.
      PAPERLESS_CONSUMER_POLLING_INTERVAL = 10;
    };

    tesseractLanguages = [
      "deu"
      "eng"
    ];

    # Uses the shared services.postgresql instance
    database.createLocally = true;
  };

  systemd.services.paperless-nc-import = {
    description = "Mirror new Nextcloud PDFs into the Paperless consume dir";
    after = ["paperless-web.service"];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${importScript}";
      StateDirectory = "paperless-nc-import";

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      # Keeps the state file private; consume subdirs set their own mode.
      UMask = "0077";
    };
  };

  systemd.timers.paperless-nc-import = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "15min";
      RandomizedDelaySec = "5min";
      Persistent = true;
    };
  };
}
