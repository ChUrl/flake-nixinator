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

      # Multimedia
      jellyfin = mkIf cfg.jellyfin.enable (mkOciContainer {
        image = "linuxserver/jellyfin:10.8.10";
        id-ports = [8096];
        vols = [
          "jellyfin-cache:/cache:Z"
          "jellyfin-config:/config:Z"
          "/home/christoph/Videos/Video:/media/Video"
          "/home/christoph/Videos/Picture:/media/Picture"
          "/home/christoph/GameHDD/Video:/media/Video2"
        ];
      });

      fileflows = mkIf cfg.fileflows.enable (mkOciContainer {
        image = "revenz/fileflows";
        id-ports = [5000];
        vols = [
          "fileflows-cache:/temp:Z"
          "fileflows-data:/app/Data:Z"
          "/home/christoph/Videos/Video:/media"
        ];
      });

      # Errr...
      sonarr = mkIf cfg.sonarr.enable (mkOciContainer {
        image = "linuxserver/sonarr:3.0.10";
        id-ports = [8989];
        vols = [
          "sonarr-config:/config:Z"
          "/home/christoph/Videos/Shows:/tv"
          "/home/christoph/Videos/SabNzbd:/downloads"
        ];
        netns = "wg0-de-115";
        netdns = "10.2.0.1";
      });

      radarr = mkIf cfg.radarr.enable (mkOciContainer {
        image = "linuxserver/radarr:4.4.4";
        id-ports = [7878];
        vols = [
          "radarr-config:/config:Z"
          "/home/christoph/Videos/Movies:/movies"
          "/home/christoph/Videos/SabNzbd:/downloads"
        ];
        netns = "wg0-de-115";
        netdns = "10.2.0.1";
      });

      hydra = mkIf cfg.hydra.enable (mkOciContainer {
        image = "linuxserver/nzbhydra2:5.1.8";
        id-ports = [5076];
        vols = [
          "hydra-config:/config:Z"
          "/home/christoph/Videos/SabNzbd:/downloads"
        ];
        netns = "wg0-de-115";
        netdns = "10.2.0.1";
      });

      sabnzbd = mkIf cfg.sabnzbd.enable (mkOciContainer {
        image = "linuxserver/sabnzbd:4.0.1";
        id-ports = [8080];
        vols = [
          "sabnzbd-config:/config:Z"
          "/home/christoph/Videos/SabNzbd:/downloads"
          "/home/christoph/Videos/.sabnzbd:/incomplete-downloads"
        ];
        netns = "wg0-de-115";
        netdns = "10.2.0.1";
      });
    };

    environment.etc."rofi-containers".text = let
      containers-list = attrNames virtualisation.oci-containers.containers;
      containers-filtered = filter (c: cfg.${c}.enable) containers-list;
      containers = concatStringsSep "\n" containers-filtered;
    in
      containers;
  };
}
