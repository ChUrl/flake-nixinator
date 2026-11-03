{
  config,
  lib,
  pkgs,
  ...
}: let
  pocketbaseVersion = "0.33.0";
  f11Version = "latest";
in {
  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts = {
    f11 = {
      port = 5173;
      aliases = ["f11.vps.chriphost.gay"];
    };

    f11pb = {
      port = 8090;
      aliases = ["f11pb.vps.chriphost.gay"];
    };
  };

  virtualisation.oci-containers.containers = {
    formula11_pocketbase = {
      image = "gitea.vps.chriphost.gay/christoph/pocketbase:${pocketbaseVersion}";
      autoStart = true;

      dependsOn = [];

      ports = [
        "127.0.0.1:8090:8080" # Bind for VPS
      ];

      volumes = [
        "formula11_pb_data:/pb/pb_data"
      ];

      environment = {};

      extraOptions = [
        "--net=behind-nginx"
      ];
    };

    formula11 = {
      image = "gitea.vps.chriphost.gay/christoph/formula11:${f11Version}";
      autoStart = true;

      dependsOn = [
        "formula11_pocketbase"
      ];

      ports = [
        # "8080:8090"
        "127.0.0.1:5173:3000"
      ];

      volumes = [];

      environment = {
        # PB_PROTOCOL="http";
        # PB_HOST="formula11_pocketbase";
        # PB_PORT="8000";

        # PB_PROTOCOL="https";
        # PB_URL="f11pb.vps.chriphost.gay";

        PUBLIC_PBURL = "https://f11pb.vps.chriphost.gay";

        # Required by SvelteKit to prevent cross-site POST errors
        ORIGIN = "https://f11.vps.chriphost.gay";
      };

      extraOptions = [
        "--net=behind-nginx"
      ];
    };
  };
}
