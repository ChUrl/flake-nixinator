{
  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.kiwix = {port = 8081;};

  # The 123G ZIM library stays on the SSD. kiwix-serve runs with
  # ProtectHome = true and a DynamicUser, so the directory is bind-mounted
  # read-only outside of /home.
  fileSystems."/srv/kiwix" = {
    device = "/home/christoph/ssd/kiwix";
    fsType = "none";
    options = [
      "bind"
      "ro"
      "x-systemd.requires-mounts-for=/home/christoph/ssd"
    ];
  };

  services.kiwix-serve = {
    enable = true;

    address = "127.0.0.1";
    port = 8081;

    # NOTE: These must stay quoted strings. A Nix path literal (no quotes)
    #       would copy the ZIM files into the nix store.
    library = {
      wikipedia = "/srv/kiwix/wikipedia_en_all_nopic_2025-12.zim";
      stackoverflow = "/srv/kiwix/stackoverflow.com_en_all_2023-11.zim";
      archlinux = "/srv/kiwix/archlinux_en_all_maxi_2025-09.zim";
    };
  };
}
