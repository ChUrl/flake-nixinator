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
      # Home Automation
      homeassistant = mkIf cfg.homeassistant.enable (mkOciContainer {
        image = "homeassistant/home-assistant:2023:5";
        id-ports = [8123];
        vols = [
          "homeassistant-config:/config:Z"
        ];
      });

      # Development
      # NOTE: PyTorch ROCM image is 36 GB large...
      # NOTE: This requires to setup the PodmanROCM direcory beforehand, as described here:
      #       https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Install-and-Run-on-AMD-GPUs#running-inside-docker
      # NOTE: This requires to manually link the launch.sh, since this is a system module (can't use home.file)
      stablediffusion = mkIf cfg.stablediffusion.enable (mkOciContainer {
        image = "rocm/pytorch:rocm5.5_ubuntu20.04_py3.8_pytorch_1.13.1";
        vols = [
          "/home/christoph/NoSync/StableDiffusionWebUI:/webui-data"
        ];
        opts = [
          "--network=host"
          "--device=/dev/kfd"
          "--device=/dev/dri"
          "--group-add=video"
          "--ipc=host"
          "--cap-add=SYS_PTRACE"
          "--security-opt=seccomp=unconfined"
        ];
        extraConfig = {
          entrypoint = "/webui-data/launch.sh";
        };
      });

      # Multimedia
      jellyfin = mkIf cfg.jellyfin.enable (mkOciContainer {
        image = "linuxserver/jellyfin:10.8.10";
        id-ports = [8096];
        vols = [
          "jellyfin-cache:/cache:Z"
          "jellyfin-config:/config:Z"
          "/home/christoph/HDD1/Video:/media/Video"
          "/home/christoph/HDD2/Video:/media/Video2"
          "/home/christoph/HDD2/Picture:/media/Picture"
        ];
      });

      fileflows = mkIf cfg.fileflows.enable (mkOciContainer {
        image = "revenz/fileflows";
        id-ports = [5000];
        vols = [
          "fileflows-cache:/temp:Z"
          "fileflows-data:/app/Data:Z"
          "/home/christoph/HDD1/Video:/media"
          "/home/christoph/HDD2/Video:/media"
        ];
      });

      # Errr...
      sonarr = mkIf cfg.sonarr.enable (mkOciContainer {
        image = "linuxserver/sonarr:3.0.10";
        id-ports = [8989];
        vols = [
          "sonarr-config:/config:Z"
          "/home/christoph/HDD2/Shows:/tv"
          "/home/christoph/HDD2/SabNzbd:/downloads"
        ];
        netns = "wg0-de-115";
        netdns = "10.2.0.1";
      });

      radarr = mkIf cfg.radarr.enable (mkOciContainer {
        image = "linuxserver/radarr:4.4.4";
        id-ports = [7878];
        vols = [
          "radarr-config:/config:Z"
          "/home/christoph/HDD2/Movies:/movies"
          "/home/christoph/HDD2/SabNzbd:/downloads"
        ];
        netns = "wg0-de-115";
        netdns = "10.2.0.1";
      });

      hydra = mkIf cfg.hydra.enable (mkOciContainer {
        image = "linuxserver/nzbhydra2:5.1.8";
        id-ports = [5076];
        vols = [
          "hydra-config:/config:Z"
          "/home/christoph/HDD2/SabNzbd:/downloads"
        ];
        netns = "wg0-de-115";
        netdns = "10.2.0.1";
      });

      sabnzbd = mkIf cfg.sabnzbd.enable (mkOciContainer {
        image = "linuxserver/sabnzbd:4.0.1";
        id-ports = [8080];
        vols = [
          "sabnzbd-config:/config:Z"
          "/home/christoph/HDD2/SabNzbd:/downloads"
          "/home/christoph/HDD2/.sabnzbd:/incomplete-downloads"
        ];
        netns = "wg0-de-115";
        netdns = "10.2.0.1";
      });
    };

    # Allow start/stop containers without root password
    modules.polkit.allowed-system-services = let
      container-services = lib.pipe virtualisation.oci-containers.containers [
        builtins.attrNames
        (builtins.filter (c: cfg.${c}.enable))
        (builtins.map (c: "podman-${c}.service"))
      ];
    in
      container-services;

    # Generate list of containers for rofi menu
    environment.etc."rofi-containers".text = let
      containers = lib.pipe virtualisation.oci-containers.containers [
        builtins.attrNames
        (builtins.filter (c: cfg.${c}.enable))
        (builtins.concatStringsSep "\n")
      ];
    in
      containers;
  };
}
