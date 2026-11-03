{config, ...}: let
  # Public endpoints, checked from the VPS. If the tunnel to thinknix is down,
  # every one of these fails
  mkEndpoint = name: url: {
    inherit name url;

    group = "public";
    interval = "1m";

    conditions = [
      "[STATUS] >= 200"
      "[STATUS] < 400"
      "[CERTIFICATE_EXPIRATION] > 720h"
    ];
  };

  endpoints = [
    (mkEndpoint "gitea" "https://gitea.vps.chriphost.gay")
    (mkEndpoint "immich" "https://immich.vps.chriphost.gay")
    (mkEndpoint "jellyfin" "https://jellyfin.vps.chriphost.gay")
    (mkEndpoint "nextcloud" "https://nextcloud.vps.chriphost.gay")
    (mkEndpoint "paperless" "https://paperless.vps.chriphost.gay")
    (mkEndpoint "ntfy" "https://ntfy.vps.chriphost.gay")
    (mkEndpoint "f10" "https://f10.vps.chriphost.gay")
    (mkEndpoint "f11" "https://f11.vps.chriphost.gay")
    (mkEndpoint "f12" "https://f12.vps.chriphost.gay")
    (mkEndpoint "f11pb" "https://f11pb.vps.chriphost.gay/api/health")
    (mkEndpoint "f12pb" "https://f12pb.vps.chriphost.gay/api/health")
  ];
in {
  sops.secrets."gatus-discord-webhook" = {};

  # Read by systemd as root; Gatus itself never sees the file.
  sops.templates."gatus.env" = {
    mode = "0400";
    content = ''
      GATUS_DISCORD_WEBHOOK=${config.sops.placeholder."gatus-discord-webhook"}
    '';
  };

  services.gatus = {
    enable = true;
    environmentFile = config.sops.templates."gatus.env".path;

    settings = {
      web = {
        address = "127.0.0.1";
        port = 8080;
      };

      storage = {
        type = "sqlite";
        path = "/var/lib/gatus/data.db";
      };

      alerting.discord = {
        # Interpolated by Gatus from the environment file above.
        webhook-url = "\${GATUS_DISCORD_WEBHOOK}";

        # The watchdog must not page on a single lost packet.
        default-alert = {
          enabled = true;
          failure-threshold = 3;
          success-threshold = 2;
          send-on-resolved = true;
        };
      };

      inherit endpoints;
    };
  };

  systemmodules.impermanence.directories = ["/var/lib/gatus"];
}
