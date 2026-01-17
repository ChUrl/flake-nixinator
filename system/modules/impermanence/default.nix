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

      # This doesn't make much sense to set generally, e.g. when
      # linking multiple files to ~/.config (they all have the same parent directory)
      # parentDirectory = {
      #   inherit mode;
      #   user = config.users.users.${user}.name;
      #   group = config.users.users.${user}.group;
      # };
    };

    mkRDir = mkDir "root";
    mkRFile = mkFile "root";
    mkUDir = mkDir "${username}";
    mkUFile = mkFile "${username}";
    # TODO: sth. like this, make options for configdirs/sharedirs/statedirs/homedirs
    #       populate options from respective modules, not here...
    # mkConfigDirs = dirs:
    #   dirs
    #   |> builtins.map (dir: ".config/${dir}")
    #   |> builtins.map mkUDir # NOTE: mkUDir has wrong arg order
  in
    lib.mkIf impermanence.enable {
      # TODO: Create options to allow host-specific impermanence setup
      #       inside the respective modules
      environment.persistence."/persist" = {
        hideMounts = false; # Sets x-gvfs-hide option

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

          (mkRDir "/var/cache/restic-backups-synology" m755)

          (mkRDir "/var/db/sudo" m711)

          (mkRDir "/var/lib/bluetooth" m755) # m700
          (mkRDir "/var/lib/btrfs" m755)
          (mkRDir "/var/lib/containers" m755)
          (mkRDir "/var/lib/flatpak" m755)
          (mkRDir "/var/lib/libvirt" m755)
          (mkRDir "/var/lib/NetworkManager" m755)
          (mkRDir "/var/lib/nixos" m755)
          (mkRDir "/var/lib/sbctl" m755)
          (mkRDir "/var/lib/systemd" m755)

          (mkRDir "/var/tmp" m777)
        ];

        users.${username} = {
          files = [
            # NOTE: Don't put files generated/linked by HM here (they're already managed)

            # TODO: Specifying files here (e.g. .config/QtProject.conf) doesn't seem to work
            #       They won't get mounted, also they can't be unmounted (because they're not mounted),
            #       which leads to /home not being unmounted correctly during shutdown...
          ];

          directories = [
            # Home directory
            (mkUDir "Downloads" m755)
            (mkUDir "Documents" m755)
            (mkUDir "GitRepos" m755)
            (mkUDir "NixFlake" m755)
            (mkUDir "Notes" m755)
            (mkUDir "Pictures" m755)
            (mkUDir "Projects" m755)
            (mkUDir "Public" m755)
            # (mkUDir "Unity" m755)
            (mkUDir "Videos" m755)

            # Secrets
            (mkUDir ".gnupg" m755) # m600
            (mkUDir ".secrets" m755) # m644
            (mkUDir ".ssh" m755) # m644

            # The shit some applications add to ~/ without asking
            # (mkUDir ".android" m755) # Unity
            # (mkUDir ".gradle" m755) # Unity
            # (mkUDir ".java" m755) # Unity/Rider
            (mkUDir ".MakeMKV" m755)
            (mkUDir ".mozilla/firefox" m755) # TODO: Remove this someday
            (mkUDir ".mozilla/native-messaging-hosts" m755)
            (mkUDir ".nix-package-search" m755)
            # (mkUDir ".nv" m755) # Unity
            (mkUDir ".ollama" m755)
            # (mkUDir ".plastic4" m755) # Unity
            (mkUDir ".var/app" m755)
            (mkUDir ".vim/undo" m755)
            (mkUDir ".zotero" m755)

            # Cache that's actually useful
            (mkUDir ".cache/fish/generated_completions" m755)
            (mkUDir ".cache/nix-index" m755)
            (mkUDir ".cache/nix-search-tv" m755)
            (mkUDir ".cache/nvim" m755)

            # Config
            # (mkUDir ".config/.android" m755) # Unity
            (mkUDir ".config/beets" m755)
            (mkUDir ".config/blender" m755)
            (mkUDir ".config/chromium" m755) # TODO: Remove this someday
            (mkUDir ".config/Ferdium" m755)
            (mkUDir ".config/fish/completions" m755)
            (mkUDir ".config/impermanence" m755)
            (mkUDir ".config/jellyfin-mpv-shim" m755)
            (mkUDir ".config/JetBrains" m755)
            (mkUDir ".config/kdeconnect" m755)
            (mkUDir ".config/keepassxc" m755)
            (mkUDir ".config/Msty" m755)
            (mkUDir ".config/Nextcloud" m755)
            (mkUDir ".config/niri/dms" m755)
            (mkUDir ".config/obsidian" m755)
            (mkUDir ".config/obs-studio" m755)
            (mkUDir ".config/Signal" m755)
            # (mkUDir ".config/singularitygroup-hotreload" m755) # Unity
            (mkUDir ".config/TeamSpeak" m755)
            (mkUDir ".config/tidal-hifi" m755)
            (mkUDir ".config/tidal_dl_ng" m755)
            # (mkUDir ".config/unity3d" m755) # Unity
            # (mkUDir ".config/unityhub" m755) # Unity
            (mkUDir ".config/vlc" m755)
            (mkUDir ".config/Zeal" m755)

            # Share
            (mkUDir ".local/share/containers" m755)
            (mkUDir ".local/share/direnv" m755)
            (mkUDir ".local/share/docker" m755)
            (mkUDir ".local/share/fish" m755)
            (mkUDir ".local/share/flatpak" m755)
            (mkUDir ".local/share/JetBrains" m755) # Unity
            (mkUDir ".local/share/hyprland" m755)
            (mkUDir ".local/share/keyrings" m755) # m700
            (mkUDir ".local/share/LRCGET" m755)
            (mkUDir ".local/share/mime" m755)
            (mkUDir ".local/share/net.lrclib.lrcget" m755)
            (mkUDir ".local/share/nix" m755)
            (mkUDir ".local/share/nvim" m755)
            (mkUDir ".local/share/qutebrowser" m755)
            (mkUDir ".local/share/systemd" m755)
            # (mkUDir ".local/share/unity3d" m755) # Unity
            (mkUDir ".local/share/zoxide" m755)

            # State
            (mkUDir ".local/state/astal/notifd" m755)
            (mkUDir ".local/state/home-manager/gc-roots" m755) # nix-flatpak stores its state there
            (mkUDir ".local/state/lazygit" m755)
            (mkUDir ".local/state/nix" m755)
            (mkUDir ".local/state/nvim" m755)
            (mkUDir ".local/state/wireplumber" m755)
          ];
        };
      };

      # Add some helper scripts to identify files that might need persisting
      environment.systemPackages = let
        base = {
          "root" = "/";
          "home" = "/home/${username}";
        };
        ignore = {
          "root" = "/home/${username}/.config/impermanence/fdignore-root";
          "home" = "/home/${username}/.config/impermanence/fdignore-home";
        };
        move = {
          "root" = "/persist/$(dirname {})";
          "home" = "/persist/home/${username}/$(dirname {})";
        };

        mkHeader = "Press CTRL-R to reload, CTRL-M to move, CTRL-I to ignore file";
        mkPreview = mode: "bat --color=always --theme=ansi --style=numbers --line-range=:100 ${base.${mode}}/{}";
        mkReload = mode: "sudo fd --one-file-system --type f --hidden --base-directory ${base.${mode}} --ignore-file ${ignore.${mode}}";
        mkIgnore = mode: "echo '{}' >> ${ignore.${mode}}";
        mkMove = mode: "sudo mkdir -p ${move.${mode}} && sudo mv {} ${move.${mode}}";

        mkScript = mode: ''
          sudo ${mkReload mode} | \
          sudo fzf \
            --header "${mkHeader}" \
            --preview "${mkPreview mode}" \
            --bind "ctrl-r:reload:(${mkReload mode})" \
            --bind "ctrl-i:execute:(${mkIgnore mode})" \
            --bind "ctrl-m:execute:(${mkMove mode})"
        '';

        newroot = pkgs.writeShellScriptBin "newroot" (mkScript "root");
        newhome = pkgs.writeShellScriptBin "newhome" (mkScript "home");
      in [
        newroot
        newhome
      ];

      # NOTE: This is REQUIRED for HM activation!
      #       Otherwise the home directory won't be writable!
      systemd.services."impermanence-fix-home-ownership" = let
        homeDir = "/home/${username}";
        homeUser =
          builtins.toString
          config.users.users.${username}.uid;
        homeGroup =
          builtins.toString
          config.users.groups.${config.users.users.${username}.group}.gid;
      in {
        description = "Fix impermanent home ownership";
        wantedBy = ["home-manager-${username}.service"];
        before = ["home-manager-${username}.service"];
        after = ["home.mount"];
        partOf = ["home.mount"];
        serviceConfig.Type = "oneshot";

        script = ''
          # Don't chown if NFS shares are already mounted.
          # This can happen outside of regular booting (e.g. nixos-rebuild switch),
          # so we don't return an error.
          # NOTE: Use || true as NixOS sets the damn -e, otherwise this unit fails on boot!
          nfs_mounts=$(grep ' nfs4 ' /proc/mounts || true)
          if [[ -n "$nfs_mounts" ]]; then
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
            exit 1
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
        in {
          description = "Clean impermanent btrfs subvolumes";
          wantedBy = ["initrd.target"];
          after = ["systemd-cryptsetup@crypted.service"];
          before = ["sysroot.mount"];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";

          # NOTE: If any single line of this script fails
          #       the entire system might be bricked.
          #       NixOS automatically sets "-e", so if unlucky,
          #       the subvolumes won'e exist for mounting...
          script = let
            mvSubvolToPersist = subvol: ''
              if [[ -e ${mountDir}/${subvol} ]]; then
                mkdir -p ${persistDir}/old_${subvol}s
                timestamp=$(date --date="@$(stat -c %Y ${mountDir}/${subvol})" "+%Y-%m-%-d_%H:%M:%S")
                mv ${mountDir}/${subvol} "${persistDir}/old_${subvol}s/$timestamp"

                # Make the backup mutable (in case it is not, e.g. /var/empty)
                # chattr -R -i -f "${persistDir}/old_${subvol}s/$timestamp"

                echo "Backed up previous ${subvol} subvolume to ${persistDir}/old_${subvol}s/$timestamp"
              fi
            '';

            mkNewSubvol = subvol: ''
              if [[ ! -e ${mountDir}/${subvol} ]]; then
                btrfs subvolume create ${mountDir}/${subvol}
                echo "Created new subvolume ${mountDir}/${subvol}"
              else
                echo "Failed to move ${mountDir}/${subvol} (${mountDir}/${subvol} still exists), not creating new subvolume..."
              fi
            '';

            # TODO: This fails and bricks the system
            deleteOldBackups = subvol: ''
              for old_${subvol} in $(find ${persistDir}/old_${subvol}s/ -maxdepth 1 -mtime +${backupDuration}); do
                delete_subvolume_recursively "$old_${subvol}"
              done
            '';
          in ''
            # This dir will be created in the initrd ramdisk
            mkdir -p ${mountDir}

            # We mount the root subvolume. Because we're using a flat btrfs layout,
            # "/" contains the subfolders (-volumes) home, log, nix, persist, root, swap, ...
            mount -o subvol=/ /dev/mapper/crypted ${mountDir}

            # Check if the persist dir exists so we can move stuff to it
            if [[ ! -e ${persistDir} ]]; then
              echo "${persistDir} doesn't exist, aborting..."
              umount ${mountDir}
              rmdir ${mountDir}
              exit 0
            fi

            # Move root subvolume to backup location
            ${mvSubvolToPersist "root"}

            # Move home subvolume to backup location
            ${mvSubvolToPersist "home"}

            # Create new root subvolume
            ${mkNewSubvol "root"}

            # Create new home subvolume
            ${mkNewSubvol "home"}

            # TODO: Did this removal of old backups always brick the system?
            # Delete a backed up subvolume
            # delete_subvolume_recursively() {
            #   IFS=$'\n'

            #   # https://github.com/nix-community/impermanence/issues/258#issuecomment-2733383737
            #   # If we accidentally end up with a file or directory under old_roots,
            #   # the code will enumerate all subvolumes under the main volume.
            #   # We don't want to remove everything under true main volume. Only
            #   # proceed if this path is a btrfs subvolume (inode=256).
            #   if [ $(stat -c %i "$1") -ne 256 ]; then return; fi

            #   for subvol in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            #     delete_subvolume_recursively "${persistDir}/$subvol"
            #   done

            #   btrfs subvolume delete "$1"
            #   echo "Deleted old subvolume $1"
            # }

            # Delete old root backups
            # $ {deleteOldBackups "root"}

            # Delete old home backups
            # $ {deleteOldBackups "home"}

            umount ${mountDir}
            rmdir ${mountDir}
          '';
        };
      };
    };
}
