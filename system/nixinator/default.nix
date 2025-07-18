{
  mylib,
  pkgs,
  username,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disks.nix

    ../modules
  ];

  modules = {
    impermanence.enable = true;

    network = {
      useNetworkManager = true;

      # Systemd-networkd configs
      networks = {
        # This should override the default network 50-ether
        "10-ether-2_5G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "enp8s0";
          ips = ["192.168.86.50/24"];
          routers = ["192.168.86.5"];
          nameservers = ["192.168.86.26" "8.8.8.8"];
          routable = true;
        };
        "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "enp5s0";
          ips = ["192.168.86.50/24"];
          routers = ["192.168.86.5"];
          nameservers = ["192.168.86.26" "8.8.8.8"];
          routable = false;
        };
        # "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {...};
      };

      # NetworkManager profiles
      # Run "nix run github:Janik-Haag/nm2nix | nix run github:kamadorueda/alejandra"
      # in /etc/NetworkManager/system-connections/
      profiles = {
        "10-ether-2_5G" = mylib.networking.mkStaticNetworkManagerProfile {
          id = "Wired 2.5G";
          interface = "enp8s0";
          ip = "192.168.86.50/24";
          router = "192.168.86.5";
          nameserver = "192.168.86.26;8.8.8.8;";
          priority = 10; # Rather connect to 2.5G than to 1G
        };
        "10-ether-1G" = mylib.networking.mkStaticNetworkManagerProfile {
          id = "Wired 1G";
          interface = "enp5s0";
          ip = "192.168.86.50/24";
          router = "192.168.86.5";
          nameserver = "192.168.86.26;8.8.8.8;";
        };
      };

      allowedTCPPorts = [
        # 7777 # AvaTalk
        # 12777 # AvaTalk
        # 31431 # Parsec
        5173 # SvelteKit
        8090 # PocketBase
        4242 # Lan-Mouse
      ];

      allowedUDPPorts = [
        # 7777 # AvaTalk
        # 12777 # AvaTalk
        # 31431 # Parsec
        5173 # SvelteKit
        8090 # PocketBase
        4242 # Lan-Mouse
      ];
    };

    sops-nix.secrets.${username} = [
      "kagi-api-key"
      "google-pse-id"
      "google-pse-key"
      "makemkv-app-key"
    ];
  };

  sops.templates."makemkv-settings.conf" = {
    owner = config.users.users.${username}.name;
    content = ''
      app_Key = "${config.sops.placeholder.makemkv-app-key}"
      sdf_Stop = ""
    '';
  };

  sops.templates."open-webui-secrets.env".content = ''
    KAGI_SEARCH_API_KEY=${config.sops.placeholder.kagi-api-key}
    GOOGLE_PSE_ENGINE_ID=${config.sops.placeholder.google-pse-id}
    GOOGLE_PSE_API_KEY=${config.sops.placeholder.google-pse-key}
  '';

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
  };

  environment.systemPackages = with pkgs; [
    # TODO: Not found by docling
    tesseract # For services.docling-serve
  ];

  programs = {
    ausweisapp = {
      enable = true;
      openFirewall = true; # Directly set port in firewall
    };
  };

  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = ["/"];
    };

    # TODO: Docling doesn't find tesseract OCR engine... Probably use docker?
    docling-serve = {
      enable = false;
      stateDir = "/var/lib/docling-serve";

      host = "127.0.0.1";
      port = 11111;
      openFirewall = false;
    };

    # TODO: To AI module
    ollama = {
      enable = true;
      acceleration = "cuda";
      home = "/var/lib/ollama";

      loadModels = [
        "deepseek-r1:8b" # Default
        "deepseek-r1:14b"
      ];

      # https://github.com/ollama/ollama/blob/main/docs/faq.md#how-do-i-configure-ollama-server
      environmentVariables = {
        # Flash Attention is a feature of most modern models
        # that can significantly reduce memory usage as the context size grows.
        OLLAMA_FLASH_ATTENTION = "1";

        # The K/V context cache can be quantized to significantly
        # reduce memory usage when Flash Attention is enabled.
        OLLAMA_KV_CACHE_TYPE = "q8_0"; # f16, q8_0 q4_0

        # To improve Retrieval-Augmented Generation (RAG) performance, you should increase
        # the context length to 8192+ tokens in your Ollama model settings.
        OLLAMA_CONTEXT_LENGTH = "8192";
      };

      host = "127.0.0.1";
      port = 11434;
      openFirewall = false;
    };

    # TODO: To AI module
    # TODO: WebSearch + RAG issues
    open-webui = {
      enable = false;
      stateDir = "/var/lib/open-webui";

      # https://docs.openwebui.com/getting-started/env-configuration
      environment = {
        DEFAULT_MODELS = builtins.head config.services.ollama.loadModels;
        TASK_MODEL = builtins.head config.services.ollama.loadModels;

        ENABLE_OPENAI_API = "False";
        ENABLE_OLLAMA_API = "True";
        OLLAMA_BASE_URL = "http://${config.services.ollama.host}:${builtins.toString config.services.ollama.port}";

        ENABLE_EVALUATION_ARENA_MODELS = "False";
        ENABLE_COMMUNITY_SHARING = "False";

        CONTENT_EXTRACTION_ENGINE = "docling";
        DOCLING_SERVER_URL = "http://${config.services.docling-serve.host}:${builtins.toString config.services.docling-serve.port}";

        ENABLE_RAG_HYBRID_SEARCH = "False";
        ENABLE_RAG_LOCAL_WEB_FETCH = "True";

        ENABLE_WEB_SEARCH = "True";
        WEB_SEARCH_ENGINE = "google_pse";
        # GOOGLE_PSE_ENGINE_ID = ""; # Use environmentFile
        # GOOGLE_PSE_API_KEY = ""; # Use environmentFile
        # KAGI_SEARCH_API_KEY = ""; # Use environmentFile

        WEBUI_AUTH = "False";
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
      };

      environmentFile = config.sops.templates."open-webui-secrets.env".path;

      host = "127.0.0.1";
      port = 11435;
      openFirewall = false;
    };

    xserver = {
      # Configure keymap in X11
      xkb.layout = "us";
      xkb.variant = "altgr-intl";

      videoDrivers = ["nvidia"]; # NVIDIA
    };
  };

  # The current system was installed on 22.05, do not change.
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
