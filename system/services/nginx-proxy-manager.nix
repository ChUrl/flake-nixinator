{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.nginx-proxy-manager = {
    image = "jc21/nginx-proxy-manager:latest";
    autoStart = true;

    dependsOn = [
      # "pihole"
    ];

    ports = [
      "80:80"
      # "81:81" # Web interface
      "443:443"
    ];

    volumes = [
      "nginx_config:/data"
      "nginx_snippets:/snippets"
      "nginx_letsencrypt:/etc/letsencrypt"
    ];

    environment = {
      DISABLE_IPV6 = "true";
    };

    extraOptions = [
      # "--net=host"
      "--net=behind-nginx"
    ];
  };
}
