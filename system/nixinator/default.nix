{
  inputs,
  config,
  lib,
  mylib,
  pkgs,
  ...
}: rec {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    inputs.musnix.nixosModules.musnix
  ];

  # Low latency audio
  musnix = {
    enable = true;
    # musnix.soundcardPciId = ;
  };

  services.xserver = {
    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";

    # videoDrivers = [ "nvidia" ]; # NVIDIA
    videoDrivers = ["amdgpu"];
  };

  # TODO: System module for this
  systemd.network = let
    eth-interface = "enp0s31f6";
    wireless-interface = "wlp5s0";
  in {
    enable = true;

    # LAN
    networks."50-ether" = {
      # name = "enp0s31f6"; # Network interface name?
      enable = true;

      # See man systemd.link, man systemd.netdev, man systemd.network
      matchConfig = {
        # This corresponds to the [MATCH] section
        Name = eth-interface; # Match ethernet interface
      };

      # See man systemd.network
      networkConfig = {
        # This corresponds to the [NETWORK] section
        DHCP = "yes";

        # TODO: What does this all do?
        # IPv6AcceptRA = true;
        # MulticastDNS = "yes"; # Needed?
        # LLMNR = "no"; # Needed?
        # LinkLocalAddressing = "no"; # Needed?
      };

      linkConfig = {
        # This corresponds to the [LINK] section
        # RequiredForOnline = "routable";
      };
    };
  };

  # TODO: System module for these
  virtualisation.oci-containers.containers = {
    jellyfin = {
      image = "linuxserver/jellyfin";
      autoStart = false;

      ports = [
        "8096:8096/tcp"
      ];

      volumes = [
        "jellyfin-cache:/cache:Z"
        "jellyfin-config:/config:Z"
        "/home/christoph/Videos/Movies:/media/Movies"
        "/home/christoph/Videos/Shows:/media/Shows"
        "/home/christoph/Videos/Video:/media/Video"
        "/home/christoph/Videos/Picture:/media/Picture"
        "/home/christoph/Videos/Concerts:/media/Concerts"
        # "/home/christoph/Music/Spotify:/media/Music:ro"
      ];
    };

    sonarr = {
      image = "linuxserver/sonarr";
      autoStart = false;

      extraOptions = [
        "--network=ns:/var/run/netns/vpn"
        "--dns=10.2.0.1"
      ];

      ports = [
        "8989:8989"
      ];

      volumes = [
        "sonarr-config:/config:Z"
        "/home/christoph/Videos/Shows:/tv"
        "/home/christoph/Videos/SabNzbd:/downloads"
      ];
    };

    radarr = {
      image = "linuxserver/radarr";
      autoStart = false;

      extraOptions = [
        "--network=ns:/var/run/netns/vpn"
        "--dns=10.2.0.1"
      ];

      ports = [
        "7878:7878"
      ];

      volumes = [
        "radarr-config:/config:Z"
        "/home/christoph/Videos/Movies:/movies"
        "/home/christoph/Videos/SabNzbd:/downloads"
      ];
    };

    hydra = {
      image = "linuxserver/nzbhydra2";
      autoStart = false;
      
      extraOptions = [
        "--network=ns:/var/run/netns/vpn"
        "--dns=10.2.0.1"
      ];

      ports = [
        "5076:5076"
      ];

      volumes = [
        "hydra-config:/config:Z"
        "/home/christoph/Videos/SabNzbd:/downloads"
      ];
    };

    sabnzbd = {
      image = "linuxserver/sabnzbd";
      autoStart = false;

      extraOptions = [
        "--network=ns:/var/run/netns/vpn"
        "--dns=10.2.0.1"
      ];

      ports = [
        "8080:8080"
      ];

      volumes = [
        "sabnzbd-config:/config:Z"
        "/home/christoph/Videos/SabNzbd:/downloads"
        "/home/christoph/Videos/.sabnzbd:/incomplete-downloads"
      ];
    };

    picard = {
      image = "mikenye/picard";
      autoStart = false;

      ports = [
        "5800:5800"
      ];

      volumes = [
        "picard-config:/config:Z"
        "/home/christoph/Music/Spotify:/storage:rw,private"
      ];
    };

    homeassistant = {
      image = "homeassistant/home-assistant";
      autoStart = false;

      ports = [
        "8123:8123"
      ];

      volumes = [
        "homeassistant-config:/config:Z"
      ];
    };

    # plex = {
    #   image = "linuxserver/plex";
    #   autoStart = false;

    #   ports = [
    #     "32400:32400/tcp"
    #   ];

    #   volumes = [
    #     "plex-config:/config:Z"
    #     "plex-transcode:/transcode:Z"
    #     "/home/christoph/Videos/Movies:/data/Movies:ro"
    #     "/home/christoph/Music/Spotify:/data/Music:ro"
    #   ];
    # };

    # emby = {
    #   image = "linuxserver/emby";
    #   autoStart = false;

    #   ports = [
    #     # Host port 8096 already used by Jellyfin
    #     "8097:8096"
    #   ];

    #   volumes = [
    #     "emby-config:/config:Z"
    #     "/home/christoph/Videos/Movies:/data/movies:ro"
    #     "/home/christoph/Videos/Pictures:/data/pictures:ro"
    #     "/home/christoph/Music/Spotify:/data/music:ro"
    #   ];
    # };
  };
}
