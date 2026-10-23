{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  nginxVersion = "2.16.0";
in {
  virtualisation.oci-containers.containers = {
    nginx-proxy-manager = {
      image = "jc21/nginx-proxy-manager:${nginxVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        "80:80"
        # "81:81" # Web interface
        "443:443"

        # TODO: Should probably split the nginx configs for ServeNix and ThinkNix
        "5520:5520/tcp" # HyTale
        "5520:5520/udp" # HyTale
      ];

      volumes = [
        "nginx_config:/data"
        "nginx_snippets:/snippets"
        "nginx_letsencrypt:/etc/letsencrypt"
      ];

      environment = {
        # DISABLE_IPV6 = "true";
      };

      extraOptions = [
        # "--net=host"
        "--net=behind-nginx"
      ];
    };
  };
}
