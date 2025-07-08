{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable light virtualization using containers";

  podman = lib.mkEnableOption "Use podman instead of docker";
  docker.rootless = lib.mkEnableOption "Use rootless docker (no effect if podman is used)";
}
