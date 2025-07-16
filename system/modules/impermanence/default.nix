{
  config,
  lib,
  mylib,
  username,
  pkgs,
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
          (mkRDir "/var/lib/libvirt" m755)
          (mkRDir "/var/lib/NetworkManager" m755)
          (mkRDir "/var/lib/nixos" m755)
          (mkRDir "/var/lib/private/ollama" m755)
          (mkRDir "/var/lib/systemd" m755)

          (mkRDir "/var/tmp" m777)
        ];

        users.${username} = {
          files = [
            (mkUFile ".local/share/fish/fish_history" m755)
            (mkUFile ".local/share/hyprland/lastVersion" m755)

            (mkUFile ".local/state/lazygit/state.yml" m755)
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
            (mkUDir ".zotero" m755)

            (mkUDir ".cache/fish/generated_completions" m755)
            (mkUDir ".cache/nix-index" m755)
            (mkUDir ".cache/nix-search-tv" m755)
            (mkUDir ".cache/nvim" m755)

            (mkUDir ".config/beets" m755)
            (mkUDir ".config/chromium" m755) # TODO: Remove this someday
            (mkUDir ".config/Ferdium" m755)
            (mkUDir ".config/fish/completions" m755)
            (mkUDir ".config/kdeconnect" m755)
            (mkUDir ".config/keepassxc" m755)
            (mkUDir ".config/Msty" m755)
            (mkUDir ".config/Nextcloud" m755)
            (mkUDir ".config/Zeal" m755)

            (mkUDir ".local/share/direnv" m755)
            (mkUDir ".local/share/docker" m755)
            (mkUDir ".local/share/flatpak" m755)
            (mkUDir ".local/share/keyrings" m755) # m700
            (mkUDir ".local/share/nix" m755)
            (mkUDir ".local/share/nvim" m755)
            (mkUDir ".local/share/systemd" m755)
            (mkUDir ".local/share/zoxide" m755)

            (mkUDir ".local/state/astal/notifd" m755)
            (mkUDir ".local/state/nix" m755)
            (mkUDir ".local/state/nvim" m755)
            (mkUDir ".local/state/wireplumber" m755)
          ];
        };
      };

      # NOTE: This is REQUIRED for HM activation! Otherwise the home directory won't be writable!
      systemd.services."impermanence-fix-home-ownership" = let
        homeDir = "/home/${username}";
        homeUser = builtins.toString config.users.users.${username}.uid;
        homeGroup = builtins.toString config.users.groups.${config.users.users.${username}.group}.gid;
      in {
        description = "Fix impermanent home ownership";
        wantedBy = ["home-manager-${username}.service"]; # Required for HM activation
        before = ["home-manager-${username}.service"];
        after = ["home.mount"];
        partOf = ["home.mount"];
        serviceConfig.Type = "oneshot";

        script = ''
          # Don't chown if NFS shares are already mounted.
          # This can happen outside of regular booting (e.g. nixos-rebuild switch),
          # so we don't return an error.
          nfs_mounts=$(grep ' nfs4 ' /proc/mounts)
          if [ -n "$nfs_mounts" ]; then
            echo "NFS shares are mounted into the home directory, aborting:"
            echo "$nfs_mounts"
            exit 0
          else
            echo "No NFS shares are mounted into the home directory, continuing..."
          fi

          if [[ -d ${homeDir} ]]; then
            chown -R ${homeUser}:${homeGroup} ${homeDir}
            echo "Set ownership for ${homeDir} to ${homeUser}:${homeGroup}"
          else
            echo "ERROR: Home ${homeDir} does not exist!"
          fi
        '';
      };

      # Because we have a LUKS encrypted drive
      # we use a systemd service to cleanup the volumes
      boot.initrd.systemd = {
        enable = true;

        services.impermanence-btrfs-cleanup = let
          backupDuration = "7"; # Days
          mountDir = "/btrfs_tmp";
          persistDir = "${mountDir}/persist";

          homeUser = builtins.toString config.users.users.${username}.uid;
          homeGroup = builtins.toString config.users.groups.${config.users.users.${username}.group}.gid;
        in {
          description = "Clean impermanent btrfs subvolumes";
          wantedBy = ["initrd.target"];
          after = ["dev-mapper-crypted.device"];
          before = ["sysroot.mount"];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          # path = ["/bin" config.system.build.extraUtils pkgs.coreutils-full];

          script = ''
                   mkdir -p ${mountDir}
                   mount -o subvol=/ /dev/mapper/crypted ${mountDir}

                   # Backup old root subvolume
                   if [[ -e ${mountDir}/root ]]; then
                       mkdir -p ${persistDir}/old_roots
                       timestamp=$(date --date="@$(stat -c %Y ${mountDir}/root)" "+%Y-%m-%-d_%H:%M:%S")
                       mv ${mountDir}/root "${persistDir}/old_roots/$timestamp"

                       echo "Backed up previous root subvolume to ${persistDir}/old_roots/$timestamp"
                   fi

                   # Backup old home subvolume
                   if [[ -e ${mountDir}/home ]]; then
                       mkdir -p ${persistDir}/old_homes
                       timestamp=$(date --date="@$(stat -c %Y ${mountDir}/home)" "+%Y-%m-%-d_%H:%M:%S")
                       mv ${mountDir}/home "${persistDir}/old_homes/$timestamp"

                       echo "Backed up previous home subvolume to ${persistDir}/old_homes/$timestamp"
                   fi

                   # Delete a backed up subvolume
                   delete_subvolume_recursively() {
                       IFS=$'\n'

                       # https://github.com/nix-community/impermanence/issues/258#issuecomment-2733383737
                       # If we accidentally end up with a file or directory under old_roots,
                       # the code will enumerate all subvolumes under the main volume.
                       # We don't want to remove everything under true main volume. Only
                       # proceed if this path is a btrfs subvolume (inode=256).
                       if [ $(stat -c %i "$1") -ne 256 ]; then return; fi

                       for subvol in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                           delete_subvolume_recursively "${persistDir}/$subvol"
                       done

                       btrfs subvolume delete "$1"
                       echo "Deleted old subvolume $1"
                   }

                   # Delete old roots
                   for old_root in $(find ${persistDir}/old_roots/ -maxdepth 1 -mtime +${backupDuration}); do
                       delete_subvolume_recursively "$old_root"
                   done

                   # Delete old homes
                   for old_home in $(find ${persistDir}/old_homes/ -maxdepth 1 -mtime +${backupDuration}); do
                       delete_subvolume_recursively "$old_home"
                   done

                   # Create new root + home subvolumes
                   btrfs subvolume create ${mountDir}/root
                   btrfs subvolume create ${mountDir}/home
                   echo "Created new subvolumes ${mountDir}/root and ${mountDir}/home"

                   if [[ -d ${mountDir}/home/${username} ]]; then
                     chown -R ${homeUser}:${homeGroup} ${mountDir}/home/${username}
                     echo "Set permissions for ${mountDir}/home/${username} to ${homeUser}:${homeGroup}"
            fi

                   if [[ -d ${persistDir}/home/${username} ]]; then
                     chown -R ${homeUser}:${homeGroup} ${persistDir}/home/${username}
                     echo "Set permissions for ${persistDir}/home/${username} to ${homeUser}:${homeGroup}"
            fi

                   umount ${mountDir}
                   rmdir ${mountDir}
          '';
        };
      };
    };
}
