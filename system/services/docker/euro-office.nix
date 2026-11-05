{
  config,
  lib,
  ...
}: let
  version = "v9.3.7-1";
in {
  # Shared with the Nextcloud connector, see system/services/nixos/nextcloud.nix.
  sops.secrets."eurooffice-jwt-secret" = {};

  sops.templates."eurooffice_secrets.env".content = ''
    JWT_SECRET=${config.sops.placeholder."eurooffice-jwt-secret"}
  '';

  # Served by systemmodules/caddy
  #
  # NOTE: The Document Server is not just an admin panel. Browsers load the
  #       editor (JS, UI, websockets) from DocumentServerUrl, so it has to be
  #       reachable from wherever Nextcloud is used - including the internet.
  #       Server-side requests use DocumentServerInternalUrl instead (see
  #       system/services/nixos/nextcloud.nix).
  systemmodules.caddy.vhosts.office = {
    port = 8086;
    aliases = ["office.vps.chriphost.gay"];
  };

  assertions = [
    {
      assertion = lib.elem "office.vps.chriphost.gay" config.systemmodules.caddy.vhosts.office.aliases;
      message = "eurooffice: office.vps.chriphost.gay must stay an alias of the vhost. Browsers load the editor from DocumentServerUrl; removing the public name breaks Office for WAN users (use DocumentServerInternalUrl for server-side requests).";
    }
  ];

  virtualisation.oci-containers.containers = {
    eurooffice = {
      image = "ghcr.io/euro-office/documentserver:${version}";
      autoStart = true;

      # Public ghcr.io image, so no DockerHub login here.

      dependsOn = [];

      ports = [
        "127.0.0.1:8086:80"
      ];

      volumes = [
        "eurooffice_data:/var/lib/euro-office/documentserver"
        "eurooffice_www:/var/www/euro-office/Data"
        "eurooffice_logs:/var/log/euro-office/documentserver"
        "eurooffice_config:/etc/euro-office/documentserver"
      ];

      environment = {
        JWT_ENABLED = "true";

        # The Document Server downloads and posts documents to Nextcloud,
        # which is also reachable as nextcloud.local (private ULA) on the LAN.
        ALLOW_PRIVATE_IP_ADDRESS = "true";

        GENERATE_FONTS = "true";
      };

      environmentFiles = [
        config.sops.templates."eurooffice_secrets.env".path
      ];

      # Same network as the other containers; the published port stays on
      # loopback and only Caddy reaches it.
      extraOptions = [
        "--net=behind-nginx"
      ];
    };
  };
}
