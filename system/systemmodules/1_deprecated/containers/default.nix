# TODO: Generate file with names for rofi
{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.virtualisation;
with mylib.modules; let
  cfg = config.modules.containers;
in {
  options.modules.containers = import ./options.nix {inherit lib mylib;};

  # TODO: These need config options exposed through the module,
  #       e.g. to set paths/volumes/binds differently per system...

  config = mkIf cfg.enable rec {
    virtualisation.oci-containers.containers = {
      # Examples how to use the mkOciContainer function:

      # stablediffusion = mkIf cfg.stablediffusion.enable (mkOciContainer {
      #   image = "rocm/pytorch:rocm5.5_ubuntu20.04_py3.8_pytorch_1.13.1";
      #   vols = [
      #     "/home/christoph/NoSync/StableDiffusionWebUI:/webui-data"
      #   ];
      #   opts = [
      #     "--network=host"
      #     "--device=/dev/kfd"
      #     "--device=/dev/dri"
      #     "--group-add=video"
      #     "--ipc=host"
      #     "--cap-add=SYS_PTRACE"
      #     "--security-opt=seccomp=unconfined"
      #   ];
      #   extraConfig = {
      #     entrypoint = "/webui-data/launch.sh";
      #   };
      # });

      # sonarr = mkIf cfg.sonarr.enable (mkOciContainer {
      #   image = "linuxserver/sonarr:3.0.10";
      #   id-ports = [8989];
      #   vols = [
      #     "sonarr-config:/config:Z"
      #     "/media/Shows:/media/Shows"
      #     "/media/Usenet:/media/Usenet"
      #   ];
      #   netns = "wg0-de-115";
      #   netdns = "10.2.0.1";
      # });
    };

    # Allow start/stop containers without root password
    modules.polkit.allowedSystemServices = let
      container-services =
        virtualisation.oci-containers.containers
        |> builtins.attrNames
        |> builtins.filter (c: cfg.${c}.enable)
        |> builtins.map (c: "podman-${c}.service");
    in
      container-services;

    # Generate list of containers for rofi menu
    environment.etc."rofi-containers".text = let
      containers =
        virtualisation.oci-containers.containers
        |> builtins.attrNames
        |> builtins.filter (c: cfg.${c}.enable)
        |> builtins.concatStringsSep "\n";
    in
      containers;
  };
}
