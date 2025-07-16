{
  config,
  lib,
  mylib,
  username,
  ...
}: let
  inherit (config.modules) impermanence;
in {
  options.modules.impermanence = import ./options.nix {inherit lib mylib;};

  config = let
    # NOTE: Setting user/group/mode only has an effect if the
    #       directory is created by impermanence!
    m777 = "u=rwx,g=rwx,o=rwx";
    m755 = "u=rwx,g=rx,o=rx";
    m711 = "u=rwx,g=x,o=x";
    m700 = "u=rwx,g=,o=";
    m644 = "u=rw,g=r,o=r";
    m600 = "u=rw,g=,o=";
    m444 = "u=r,g=r,o=r";

    mkDir = user: directory: mode: {
      inherit directory mode;
      user = config.users.users.${user}.name;
      group = config.users.users.${user}.group;
    };

    mkFile = user: file: mode: {
      inherit file;
      parentDirectory = {
        inherit mode;
        user = config.users.users.${user}.name;
        group = config.users.users.${user}.group;
      };
    };
  in
    lib.mkIf impermanence.enable {
      environment.persistence."/persist" = let
        mkRDir = mkDir "root";
        mkRFile = mkFile "root";
        mkUDir = mkDir "${username}";
        mkUFile = mkFile "${username}";
      in {
        hideMounts = true; # Sets x-gvfs-hide option

        files = [
          (mkRFile "/etc/adjtime" m644)
          (mkRFile "/etc/machine-id" m444)
        ];

        directories = [
          (mkRDir "/etc/NetworkManager" m755)
          (mkRDir "/etc/secureboot" m755)
          (mkRDir "/etc/ssh" m755)

          # https://github.com/nix-community/impermanence/issues/253
          (mkRDir "/usr/systemd-placeholder" m755)

          (mkRDir "/var/db/sudo" m711)

          (mkRDir "/var/lib/bluetooth" m755) # m700
          (mkRDir "/var/lib/containers" m755)
          (mkRDir "/var/lib/flatpak" m755)
          (mkRDir "/var/lib/NetworkManager" m755)
          (mkRDir "/var/lib/libvirt" m755)
          (mkRDir "/var/lib/nixos" m755)
          (mkRDir "/var/lib/systemd" m755)

          (mkRDir "/var/tmp" m777)
        ];

        users.${username} = {
          files = [
            # (mkUFile ".ssh/known_hosts" m755) # m644
            #
            # (mkUFile ".secrets/spotify_client_id" m755) # m644
            # (mkUFile ".secrets/spotify_client_secret" m755) # m644
            # (mkUFile ".secrets/youtube_music_cookies" m755) # m644
            # (mkUFile ".secrets/age/age.key" m755) # m600
          ];

          directories = [
            (mkUDir "Downloads" m755)
            (mkUDir "Documents" m755)
            (mkUDir "GitRepos" m755)
            (mkUDir "NixFlake" m755)
            (mkUDir "Notes" m755)
            (mkUDir "Pictures" m755)
            (mkUDir "Projects" m755)
            (mkUDir "Public" m755)
            (mkUDir "Unity" m755)
            (mkUDir "Videos" m755)

            (mkUDir ".gnupg" m755) # m600
            (mkUDir ".secrets" m755) # m644
            (mkUDir ".ssh" m755) # m644

            (mkUDir ".mozilla/firefox" m755) # TODO: Remove this someday
            (mkUDir ".mozilla/native-messaging-hosts" m755)
            (mkUDir ".nix-package-search" m755)
            (mkUDir ".ollama" m755)
            (mkUDir ".var/app" m755)
            (mkUDir ".vim/undo" m755)

            (mkUDir ".cache/fish/generated_completions" m755)
            (mkUDir ".cache/nix-index" m755)
            (mkUDir ".cache/nvim" m755)

            (mkUDir ".config/beets" m755)
            (mkUDir ".config/chromium" m755) # TODO: Remove this someday
            (mkUDir ".config/Ferdium" m755)
            (mkUDir ".config/fish/completions" m755)
            (mkUDir ".config/kdeconnect" m755)
            (mkUDir ".config/keepassxc" m755)
            (mkUDir ".config/Msty" m755)
            (mkUDir ".config/Nextcloud" m755)

            (mkUDir ".local/share/direnv" m755)
            (mkUDir ".local/share/flatpak" m755)
            (mkUDir ".local/share/keyrings" m755) # m700
            (mkUDir ".local/share/nix" m755)
            (mkUDir ".local/share/nvim/sessions" m755)
            (mkUDir ".local/share/zoxide" m755)

            (mkUDir ".local/state/astal/notifd" m755)
            (mkUDir ".local/state/nvim" m755)
          ];
        };
      };
    };
}
