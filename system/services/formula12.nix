{
  config,
  lib,
  pkgs,
  ...
}: let
  pocketbaseVersion = "0.33.0";
  f12Version = "latest";
in {
  virtualisation.oci-containers.containers = {
    formula12_pocketbase = {
      image = "gitea.vps.chriphost.de/christoph/pocketbase:${pocketbaseVersion}";
      autoStart = true;

      dependsOn = [];

      ports = [
        "8091:8080" # Bind for VPS
      ];

      volumes = [
        "formula12_pb_data:/pb/pb_data"
      ];

      environment = {};

      extraOptions = [
        "--net=behind-nginx"
      ];
    };

    formula12 = {
      image = "gitea.vps.chriphost.de/christoph/formula12:${f12Version}";
      autoStart = true;

      dependsOn = [
        "formula12_pocketbase"
      ];

      ports = [
        # "8080:8090"
        "5174:3000"
      ];

      volumes = [];

      environment = {
        # PB_PROTOCOL="http";
        # PB_HOST="formula11_pocketbase";
        # PB_PORT="8000";

        # PB_PROTOCOL="https";
        # PB_URL="f11pb.vps.chriphost.de";

        PUBLIC_PBURL = "https://f12pb.vps.chriphost.de";

        # Required by SvelteKit to prevent cross-site POST errors
        ORIGIN = "https://f12.vps.chriphost.de";
      };

      extraOptions = [
        "--net=behind-nginx"
      ];
    };
  };
}
