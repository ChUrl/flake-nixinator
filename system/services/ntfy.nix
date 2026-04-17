{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  ntfyVersion = "v2.21";
in {
  # If we need to pass secrets to containers we can't use plain env variables.
  sops.templates."ntfy_secrets.env".content = ''
    NTFY_AUTH_USERS=${config.sops.placeholder.ntfy-auth-users}
    NTFY_AUTH_TOKENS=${config.sops.placeholder.ntfy-auth-tokens}
  '';

  virtualisation.oci-containers.containers = {
    #     NTFY_AUTH_USERS='admin:$2b$10$13iMkFcSNXcb/DKlUSS03OM25saLd8/hDlKkowFtXYctu2fQBoLJK:admin,christoph:$2b$10$8jgrgBltBXj/Qw0BxBWf1eIfH53VV6wTdlJZEqWBIH3htwEP9PKgq:user'
    #     NTFY_AUTH_TOKENS="christoph:tk_rx8fd6hojuz4ekcb72j7juugkbmga:FAIL*-Notif"

    #     NTFY_BASE_URL="https://ntfy.vps.chriphost.de"
    #     NTFY_BEHIND_PROXY="true"
    #     NTFY_AUTH_FILE="/var/lib/ntfy/auth.db"
    #     NTFY_AUTH_DEFAULT_ACCESS="deny-all"
    #     NTFY_ENABLE_LOGIN="true"
    #     NTFY_REQUIRE_LOGIN="true"
    #     NTFY_ATTACHMENT_CACHE_DIR="/var/cache/ntfy/attachments"
    #     NTFY_CACHE_FILE="/var/cache/ntfy/cache.db"
    #     NTFY_UPSTREAM_BASE_URL="https://ntfy.sh"
    #     NTFY_AUTH_ACCESS="christoph:*:read-write"
    ntfy = {
      image = "binwiederhier/ntfy:${ntfyVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        "8042:80"
      ];

      volumes = [
        "ntfy_cache:/var/cache/ntfy"
        "ntfy_attachments:/var/cache/ntfy/attachments"
        "ntfy_lib:/var/lib/ntfy"
        "ntfy_etc:/etc/ntfy"
      ];

      cmd = ["serve"];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";

        NTFY_BASE_URL = "https://ntfy.vps.chriphost.de";
        NTFY_BEHIND_PROXY = "true";
        NTFY_AUTH_FILE = "/var/lib/ntfy/auth.db";
        NTFY_AUTH_DEFAULT_ACCESS = "deny-all";
        NTFY_ENABLE_LOGIN = "true";
        NTFY_REQUIRE_LOGIN = "true";
        NTFY_ATTACHMENT_CACHE_DIR = "/var/cache/ntfy/attachments";
        NTFY_CACHE_FILE = "/var/cache/ntfy/cache.db";
        NTFY_UPSTREAM_BASE_URL = "https://ntfy.sh";
        NTFY_AUTH_ACCESS = "christoph:*:read-write";
      };

      environmentFiles = [
        config.sops.templates."ntfy_secrets.env".path
      ];

      extraOptions = [
        # "--privileged"
        # "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
