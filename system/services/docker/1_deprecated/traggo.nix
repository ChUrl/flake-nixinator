{
  mylib,
  config,
  ...
}: let
  traggoVersion = "0.8.3";
in {
  systemmodules.caddy.vhosts.time = {port = 3031;};

  sops.secrets."traggo-admin-password" = {};

  sops.templates."traggo_secrets.env".content = ''
    TRAGGO_DEFAULT_USER_PASS=${config.sops.placeholder."traggo-admin-password"}
  '';

  virtualisation.oci-containers.containers = {
    traggo = {
      image = "traggo/server:${traggoVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        # 3030 is Grafana
        "127.0.0.1:3031:3030"
      ];

      volumes = [
        "traggo_data:/opt/traggo/data"
      ];

      environment = {
        TRAGGO_DEFAULT_USER_NAME = "admin";
        TZ = "Europe/Berlin";
      };

      environmentFiles = [
        config.sops.templates."traggo_secrets.env".path
      ];

      extraOptions = [
        "--net=behind-nginx"
      ];
    };
  };
}
