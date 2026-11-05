{config, ...}: let
  version = "v9.3.7-1";
in {
  # Shared with the Nextcloud connector, see system/services/nixos/nextcloud.nix.
  sops.secrets."eurooffice-jwt-secret" = {};

  sops.templates."eurooffice_secrets.env".content = ''
    JWT_SECRET=${config.sops.placeholder."eurooffice-jwt-secret"}
  '';

  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.office = {
    # 8080 is Nextcloud, 8083 is free
    port = 8083;
    aliases = ["office.vps.chriphost.gay"];
  };

  virtualisation.oci-containers.containers = {
    eurooffice = {
      image = "ghcr.io/euro-office/documentserver:${version}";
      autoStart = true;

      # Public ghcr.io image, so no DockerHub login here.

      dependsOn = [];

      ports = [
        "127.0.0.1:8083:80"
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
