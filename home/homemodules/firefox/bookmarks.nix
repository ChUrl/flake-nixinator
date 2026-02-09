let
  mkBm = name: url: {
    name = name;
    url = url;
  };
in [
  {
    toolbar = true;
    bookmarks = [
      # NixOS

      {
        name = "NixOS";
        bookmarks = [
          (mkBm "Package Search" "https://search.nixos.org/packages")
          (mkBm "Option Search" "https://search.nixos.org/options?")
          (mkBm "Function Search" "https://noogle.dev/")
          (mkBm "HM Search" "https://mipmip.github.io/home-manager-option-search/")
          (mkBm "NUR Search" "https://nur.nix-community.org/")
          (mkBm "Nixpkgs Version Search" "https://lazamar.co.uk/nix-versions/")
          (mkBm "Nixpkgs PR Tracker" "https://nixpk.gs/pr-tracker.html")
          "separator"
          (mkBm "NixOS Wiki" "https://wiki.nixos.org/wiki/NixOS_Wiki")
          (mkBm "Nixpkgs Issues" "https://github.com/NixOS/nixpkgs/issues")
          (mkBm "Nixpkgs Manual" "https://nixos.org/manual/nixpkgs/unstable/")
          (mkBm "NixOS Manual" "https://nixos.org/manual/nixos/unstable/")
          (mkBm "Nix Manual" "https://nix.dev/manual/nix/stable/")
        ];
      }
      (mkBm "Searchix" "https://searchix.ovh/")
      (mkBm "Latest" "https://discourse.nixos.org/latest")
      "separator"

      # HomeLab

      {
        name = "Lab";
        bookmarks = [
          (mkBm "LAN Smart Switch" "http://192.168.86.2/")
          (mkBm "WiFi Access Point" "http://192.168.86.3/")
          (mkBm "OPNsense" "https://192.168.86.5/")
          (mkBm "Synology DS223j" "https://synology.think.chriphost.de/")
          (mkBm "PVE Direct" "https://192.168.86.4:8006/#v1:0:18:4:::::::")
          (mkBm "PVF Direct" "https://192.168.86.13:8006/#v1:0:18:4:::::::")
          (mkBm "Portainer" "https://portainer.think.chriphost.de/")
          "separator"
          (mkBm "Local NGINX" "https://nginx.local.chriphost.de/")
          (mkBm "Think NGINX" "https://nginx.think.chriphost.de/")
          (mkBm "VPS NGINX" "http://vps.chriphost.de:51810/")
          (mkBm "WUD ServeNix" "https://update.local.chriphost.de/")
          (mkBm "WUD ThinkNix" "https://update.think.chriphost.de/")
        ];
      }
      (mkBm "Cloud" "https://nextcloud.local.chriphost.de/apps/files/files")
      (mkBm "Immich" "https://immich.local.chriphost.de/photos")
      (mkBm "Jelly" "https://jellyfin.local.chriphost.de/web/#/home.html")
      (mkBm "HASS" "https://hass.think.chriphost.de/lovelace")
      (mkBm "Docs" "https://paperless.local.chriphost.de/documents?sort=created&reverse=1&page=1")
      (mkBm "Gitea" "https://gitea.local.chriphost.de/christoph")
      # (mkBm "Chat" "http://localhost:11435/") # Local WebUI
      "separator"

      # Coding

      {
        name = "Coding";
        bookmarks = [
          (mkBm "C++Ref" "https://en.cppreference.com/w/")
          (mkBm "Rust" "https://doc.rust-lang.org/stable/book/ch03-00-common-programming-concepts.html")
          (mkBm "RustOS" "https://os.phil-opp.com/")
          (mkBm "Interpreters" "https://craftinginterpreters.com/contents.html")
          (mkBm "Godbolt" "https://godbolt.org")
        ];
      }
      {
        name = "\"AI\"";
        bookmarks = [
          (mkBm "Mistral Chat" "https://chat.mistral.ai/chat")
          (mkBm "DeepSeek Chat" "https://chat.deepseek.com/")
          (mkBm "Claude Chat" "https://claude.ai/new")
          (mkBm "ChatGPT" "https://chatgpt.com/")
          (mkBm "DeepWiki" "https://deepwiki.com/")
          "separator"
          (mkBm "Mistral API" "https://console.mistral.ai/usage")
          (mkBm "DeepSeek API" "https://platform.deepseek.com/usage")
          (mkBm "Claude API" "https://console.anthropic.com/usage")
          (mkBm "OpenRouter API" "https://openrouter.ai/activity")
        ];
      }
      (mkBm "GH" "https://github.com/churl")
      (mkBm "GL" "https://gitlab.com/churl")
      (mkBm "SO" "https://stackoverflow.com/users/saves/17337508/all")
      (mkBm "RegEx" "https://regex101.com/")
      (mkBm "Shell" "https://explainshell.com/")
      (mkBm "CDecl" "https://cdecl.org/")
      (mkBm "ECR" "https://gallery.ecr.aws/")
      (mkBm "Chmod" "https://chmod-calculator.com/")
      "separator"

      # Stuff

      (mkBm "Spiegel" "https://www.spiegel.de/")
      (mkBm "Heise" "https://www.heise.de/")
      (mkBm "HN" "https://news.ycombinator.com/news")
      (mkBm "Reddit" "https://www.reddit.com/user/FightingMushroom/saved/")
      (mkBm "F10" "https://f10.local.chriphost.de/race/Everyone")
      (mkBm "F11" "https://f11.local.chriphost.de/racepicks")
      (mkBm "F11PB" "https://f11pb.local.chriphost.de/_/#/collections?collection=pbc_1736455494&filter=&sort=-%40rowid")
      (mkBm "ISBNDB" "https://isbndb.com/")
      (mkBm "Music" "https://bandcamp.com/chriphost")
      (mkBm "Albums" "https://www.albumoftheyear.org/user/chriphost/list/307966/2025/")
    ];
  }
]
