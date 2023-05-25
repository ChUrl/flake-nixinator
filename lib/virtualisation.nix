{
  inputs,
  pkgs,
  lib,
  ...
}: rec {
  mkOciContainer = {
    image,
    autoStart ? false,
    id-ports ? [],
    ports ? [],
    vols ? [],
    env ? {},
    opts ? [],
    extraConfig ? {},
    netns ? "",
    netdns ? "",
  }: let
    expanded-id-ports = map (port: "${toString port}:${toString port}") id-ports;
    additional-opts =
      []
      ++ (lib.optionals (netns != "") [
        "--network=ns:/var/run/netns/${netns}"
      ])
      ++ (lib.optionals (netdns != "") [
        "--dns=${netdns}"
      ]);
  in
    lib.mergeAttrs extraConfig {
      image = image;
      autoStart = autoStart;
      ports = ports ++ expanded-id-ports;
      volumes = vols;
      environment = lib.mergeAttrs env {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };
      extraOptions = opts ++ additional-opts;
    };

  # Filter all system service attributes that the user units don't have and add some required attributes
  # Example: podman-stablediffusion = mkOciUserService config.systemd.services.podman-stablediffusion;
  # NOTE: This doesn't work, since the cidfile is located in /run, which is not writable for regular users...
  mkOciUserService = attrs:
    lib.mergeAttrs (lib.attrsets.filterAttrs (n: v:
      !((n == "confinement")
        || (n == "runner")
        || (n == "environment")))
    attrs) {
      startLimitIntervalSec = 1;
      startLimitBurst = 5;
    };
}
