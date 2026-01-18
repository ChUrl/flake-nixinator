{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable light virtualization using containers";

  podman = lib.mkEnableOption "Use podman instead of docker";
  docker.rootless = lib.mkEnableOption "Use rootless docker (no effect if podman is used)";
  docker.buildkit = lib.mkEnableOption "Use Docker BuildKit (no effect if podman is used)";

  networks = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule ({
      lib,
      mylib,
      ...
    }: {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "The name of the docker/podman network";
          example = "behind-nginx";
        };

        disable_masquerade = lib.mkEnableOption "Disable IP masquerading for this network";

        ipv6 = {
          enable = lib.mkEnableOption "Enable IPv6 for this network";

          gateway = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "The IPv6 gateway for this network";
            example = "2000::1";
            default = null;
          };

          subnet = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "The IVv6 subnet mask for this network";
            example = "2000::/80";
            default = null;
          };
        };
      };
    }));
    description = "Docker/Podman networks to create";
    example = ''
      {
        behind-nginx = {
          disable_masquerade = false;
          ipv6 = {
            enable = true;
            gateway = "2000::1";
            subnet = "2000::/80";
          };
        }
      }
    '';
    default = [];
  };
}
