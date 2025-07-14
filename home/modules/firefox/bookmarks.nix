let
  bookmark = name: url: {
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
          (bookmark "Package Search" "https://search.nixos.org/packages")
          (bookmark "Option Search" "https://search.nixos.org/options?")
          (bookmark "Function Search" "https://noogle.dev/")
          (bookmark "HM Option Search" "https://mipmip.github.io/home-manager-option-search/")
          (bookmark "NUR Package Sarch" "https://nur.nix-community.org/")
          (bookmark "Nix Package Versions" "https://lazamar.co.uk/nix-versions/")
          (bookmark "Nixpkgs Progress Tracker" "https://nixpk.gs/pr-tracker.html")
          (bookmark "NixOS Wiki" "https://wiki.nixos.org/wiki/NixOS_Wiki")
          (bookmark "Nix Manual" "https://nix.dev/manual/nix/stable/")
          (bookmark "Nixpkgs Manual" "https://nixos.org/manual/nixpkgs/unstable/")
          (bookmark "NixOS Manual" "https://nixos.org/manual/nixos/unstable/")
          (bookmark "Nixpkgs Issues" "https://github.com/NixOS/nixpkgs/issues")
        ];
      }
      (bookmark "Searchix" "https://searchix.ovh/")
      (bookmark "Latest" "https://discourse.nixos.org/latest")
      "separator"

      # HomeLab

      {
        name = "Lab";
        bookmarks = [
          (bookmark "LAN Smart Switch" "http://192.168.86.2/")
          (bookmark "WiFi Access Point" "http://192.168.86.3/")
          (bookmark "OPNsense" "https://192.168.86.5/")
          (bookmark "PVE Direct" "https://192.168.86.4:8006/#v1:0:18:4:::::::")
          (bookmark "PVF Direct" "https://192.168.86.13:8006/#v1:0:18:4:::::::")
          (bookmark "Local NGINX" "https://nginx.local.chriphost.de/")
          (bookmark "Think NGINX" "https://nginx.think.chriphost.de/")
          (bookmark "VPS NGINX" "http://vps.chriphost.de:51810/")
          (bookmark "Portainer" "https://portainer.think.chriphost.de/")
        ];
      }
      (bookmark "Cloud" "https://nextcloud.local.chriphost.de/apps/files/files")
      (bookmark "Immich" "https://immich.local.chriphost.de/photos")
      (bookmark "Jelly" "https://jellyfin.local.chriphost.de/web/#/home.html")
      (bookmark "HASS" "https://hass.think.chriphost.de/lovelace")
      (bookmark "Docs" "https://paperless.local.chriphost.de/documents?sort=created&reverse=1&page=1")
      (bookmark "Gitea" "https://gitea.local.chriphost.de/christoph")
      (bookmark "Chat" "http://localhost:11435/")
      "separator"

      # Coding

      {
        name = "Coding";
        bookmarks = [
          (bookmark "C++Ref" "https://en.cppreference.com/w/")
          (bookmark "Rust" "https://doc.rust-lang.org/stable/book/ch03-00-common-programming-concepts.html")
          (bookmark "RustOS" "https://os.phil-opp.com/")
          (bookmark "Interpreters" "https://craftinginterpreters.com/contents.html")
        ];
      }
      (bookmark "GH" "https://github.com/churl")
      (bookmark "GL" "https://gitlab.com/churl")
      (bookmark "SO" "https://stackoverflow.com/users/saves/17337508/all")
      (bookmark "RegEx" "https://regex101.com/")
      (bookmark "Shell" "https://explainshell.com/")
      (bookmark "CDecl" "https://cdecl.org/")
      (bookmark "ECR" "https://gallery.ecr.aws/")
      "separator"

      # Stuff

      (bookmark "Spiegel" "https://www.spiegel.de/")
      (bookmark "Heise" "https://www.heise.de/")
      (bookmark "HN" "https://news.ycombinator.com/news")
      (bookmark "Reddit" "https://www.reddit.com/user/FightingMushroom/saved/")
      (bookmark "F10" "https://f10.local.chriphost.de/race/Everyone")
      (bookmark "F11" "https://f11.local.chriphost.de/racepicks")
      (bookmark "F11PB" "https://f11pb.local.chriphost.de/_/#/collections?collection=pbc_1736455494&filter=&sort=-%40rowid")
      (bookmark "ISBNDB" "https://isbndb.com/")
      (bookmark "Music" "https://bandcamp.com/chriphost")
      (bookmark "Albums" "https://www.albumoftheyear.org/user/chriphost/list/307966/2025/")
    ];
  }
]
