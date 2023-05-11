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
  # TODO: I also want a function to generate these configs, I just want to pass volumes, ports, env and image
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

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };
    };

    # TODO: When setting PUID/PGID fileflows can't access /temp dir
    # fileflows = {
    #   image = "revenz/fileflows";
    #   autoStart = false;

    #   ports = [
    #     "5000:5000"
    #   ];

    #   volumes = [
    #     "fileflows-cache:/temp:Z"
    #     "fileflows-data:/app/Data:Z"
    #     "/home/christoph/Videos/Video:/media"
    #   ];

    #   environment = {
    #     PUID = "1000";
    #     PGID = "1000";
    #     TZ = "Europe/Berlin";
    #   };
    # };

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

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };
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

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };
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

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };
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

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };
    };

    # picard = {
    #   image = "mikenye/picard";
    #   autoStart = false;

    #   ports = [
    #     "5800:5800"
    #   ];

    #   volumes = [
    #     "picard-config:/config:Z"
    #     "/home/christoph/Music/Spotify:/storage:rw,private"
    #   ];

    #   environment = {
    #     PUID = "1000";
    #     PGID = "1000";
    #     TZ = "Europe/Berlin";
    #   };
    # };

    homeassistant = {
      image = "homeassistant/home-assistant";
      autoStart = false;

      ports = [
        "8123:8123"
      ];

      volumes = [
        "homeassistant-config:/config:Z"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };
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

    # TODO: Doesn't work, image is too large, no space left on device
    # stablediffusion = let
    #   webui = pkgs.dockerTools.buildImage {
    #     name = "stablediffusion-webui";
    #     # tag = "latest";

    #     # fromImage = "rocm/pytorch";
    #     fromImage = pkgs.dockerTools.pullImage {
    #       imageName = "rocm/pytorch";
    #       imageDigest = "sha256:994bc9eff6839143433caa6b665b7584dd623b03c65dc132f3827cf6480dcec1";
    #       sha256 = "";
    #     };
    #     fromImageTag = "latest";

    #     runAsRoot = ''
    #       #!${pkgs.runtimeShell}
    #       cd /webui-data
    #       git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui
    #       cd stable-diffusion-webui
    #       python -m pip install --upgrade pip wheel
    #     '';

    #     config = {
    #       WorkingDir = "/webui-data/stable-diffusion-webui";
    #       Env = {
    #         REQS_FILE = "/webui-data/stable-diffusion-webui/requirements.txt";
    #       };
    #       Cmd = [
    #         "python"
    #         "launch.py"
    #         "--prevision"
    #         "full"
    #         "--no-half"
    #       ];
    #       ExposedPorts = {
    #         "7860" = {};
    #       };
    #     };
    #   };
    # in {
    #   image = "${webui}";
    #   autoStart = false;

    #   extraOptions = [
    #     "--network=host"
    #     "--device=/dev/kfd"
    #     "--device=/dev/dri"
    #     "--group-add=video"
    #     "--ipc=host"
    #     "--cap-add=SYS_PTRACE"
    #     "--security-opt seccomp=unconfined"
    #   ];

    #   ports = [
    #     "7860:7860"
    #   ];

    #   volumes = [
    #     "/home/christoph/NoSync/PodmanROCM:/webui-data"
    #   ];

    #   environment = {
    #     PUID = "1000";
    #     PGID = "1000";
    #     TZ = "Europe/Berlin";
    #   };
    # };

    # NOTE: This requires to setup the PodmanROCM direcory beforehand, as described here:
    #       https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Install-and-Run-on-AMD-GPUs#running-inside-docker
    stablediffusion = {
      image = "rocm/pytorch";
      autoStart = false;

      extraOptions = [
        "--network=host"
        "--device=/dev/kfd"
        "--device=/dev/dri"
        "--group-add=video"
        "--ipc=host"
        "--cap-add=SYS_PTRACE"
        "--security-opt=seccomp=unconfined"
      ];

      volumes = [
        "/home/christoph/NoSync/StableDiffusionWebUI:/webui-data"
      ];

      # TODO: User christoph not found in passwd file
      # user = "christoph:users";

      environment = {
        UID = "1000";
        GID = "100";
        TZ = "Europe/Berlin";
      };

      entrypoint = "/webui-data/launch.sh";
    };
  };

  # Make the system services available to the user
  # NOTE: This doesn't work, since the cidfile is located in /run, which is not writable for regular users...
  systemd.user.services = let 
    # Filter all system service attributes that the user units don't have and add some required attributes
    system2user = attrs: lib.mergeAttrs (lib.attrsets.filterAttrs (n: v: !(
      n == "confinement" ||
      n == "runner" ||
      n == "environment"
    )) attrs) {
      startLimitIntervalSec = 1;
      startLimitBurst = 5;
    };
  in {
      # podman-stablediffusion = system2user config.systemd.services.podman-stablediffusion;
  };
}
