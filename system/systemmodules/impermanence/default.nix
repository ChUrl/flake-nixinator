{
  config,
  lib,
  mylib,
  username,
  pkgs,
  ...
}: let
  inherit (config.systemmodules) impermanence;

  # Paths owned by a home-manager module: HM modules can't set system options,
  # so they declare them in homemodules.impermanence and are folded in here.
  hmConfig = config.home-manager.users.${username} or {};
  hmPersistDirectories = hmConfig.homemodules.impermanence.directories or [];
in {
  options.systemmodules.impermanence = import ./options.nix {
    inherit lib mylib config username;
  };

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

    hmDirectories = builtins.map (directory: mkUDir directory m755) hmPersistDirectories;
  in
    lib.mkIf impermanence.enable {
      environment.persistence."/persist" = {
        hideMounts = false; # Sets x-gvfs-hide option

        files = [
          (mkRFile "/etc/adjtime" m644)
          (mkRFile "/etc/machine-id" m444)
        ];

        # Paths used by modules are declared in the respective module, see
        # systemmodules.impermanence.directories.
        directories =
          [
            # impermanence / host state without a module
            (mkRDir "/usr/systemd-placeholder" m755) # https://github.com/nix-community/impermanence/issues/253
            (mkRDir "/var/db/sudo" m711)
            (mkRDir "/var/lib/bluetooth" m755) # Created by the hardware config
            (mkRDir "/var/lib/nixos" m755)
            (mkRDir "/var/lib/systemd" m755)
            (mkRDir "/var/tmp" m777)
          ]
          ++ impermanence.directories;

        users.${username} = {
          files = [
            # NOTE: Don't put files generated/linked by HM here (they're already managed)

            # TODO: Specifying files here (e.g. .config/QtProject.conf) doesn't seem to work
            #       They won't get mounted, also they can't be unmounted (because they're not mounted),
            #       which leads to /home not being unmounted correctly during shutdown...
          ];

          # TODO: I need something that lists stale folders in /persist (folders that are no longer mounted into the system)
          directories =
            [
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

              # State of nix and systemd in the home directory. Everything
              # else is declared by the module that owns it, see
              # homemodules.impermanence and systemmodules.impermanence.
              (mkUDir ".config/impermanence" m755) # fdignore files for newroot/newhome
              (mkUDir ".local/share/nix" m755)
              (mkUDir ".local/share/systemd" m755)
              (mkUDir ".local/state/nix" m755)
            ]
            ++ hmDirectories
            ++ impermanence.userDirectories;
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

      # TODO: Is this fixed with filesystems."/home".neededForBoot = true?
      # NOTE: This is REQUIRED for HM activation!
      #       Otherwise the home directory won't be writable!
      #       The home subvolume is recreated on every boot, so it belongs
      #       to root. The directory itself needs the ownership fix, everything
      #       below it is a bind mount whose ownership comes from /persist.
      #       NOT recursive, so chown -R doesn't walk through every bind
      #       mount in /persist and into the network mounts.
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
          if [[ -d ${homeDir} ]]; then
            chown ${homeUser}:${homeGroup} ${homeDir}
            echo "Set ownership for ${homeDir} to ${homeUser}:${homeGroup}"
          else
            echo "ERROR: Home ${homeDir} does not exist!"
            exit 1
          fi
        '';
      };

      # Because we have a LUKS encrypted drive we retire the previous root and
      # home subvolumes from the initrd. Nothing is deleted here.
      boot.initrd.systemd.services.impermanence-btrfs-cleanup = let
        mountDir = "/btrfs_tmp";
        btrfsDevice = "/dev/mapper/crypted";
        cryptsetupUnit = "systemd-cryptsetup@crypted.service";

        # Retire one ephemeral subvolume and create a fresh one in its place.
        recordGeneration = subvol: ''
          if [[ -e ${mountDir}/${subvol} ]]; then
            mkdir -p ${mountDir}/old_${subvol}s

            timestamp=$(date -u --date="@$(stat -c %Y ${mountDir}/${subvol})" +%Y-%m-%dT%H:%M:%SZ)
            target="${mountDir}/old_${subvol}s/$timestamp"
            # A generation that was never written to can share a timestamp with
            # the next one, so make the name unique instead of failing.
            n=1
            while [[ -e $target ]]; do
              target="${mountDir}/old_${subvol}s/$timestamp.$n"
              n=$((n + 1))
            done

            mv ${mountDir}/${subvol} "$target"
            # Best effort: never fail the boot over a cosmetic attribute.
            btrfs property set -ts "$target" ro true \
              || echo "WARNING: could not mark $target read-only"
            echo "Archived previous ${subvol} subvolume as $target"
          fi

          btrfs subvolume create ${mountDir}/${subvol}
          echo "Created new ${subvol} subvolume"
        '';
      in {
        description = "Retire ephemeral btrfs subvolumes (impermanence)";
        wantedBy = ["initrd.target"];
        requires = [cryptsetupUnit];
        after = [cryptsetupUnit "local-fs-pre.target"];
        before = ["sysroot.mount"];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          # Creating a subvolume on a multi-TB filesystem can take longer than
          # the default 90s.
          TimeoutStartSec = "10min";
        };

        script = ''
          mkdir -p ${mountDir}
          mount -o subvol=/ ${btrfsDevice} ${mountDir}
          trap 'umount -l ${mountDir} || true' EXIT

          if [[ ! -e ${mountDir}/persist ]]; then
            echo "${mountDir}/persist doesn't exist, aborting..."
            exit 0
          fi

          ${recordGeneration "root"}
          ${recordGeneration "home"}
        '';
      };

      # Pruning the old subvolumes happens later in boot. Deleting a retired
      # home/root subvolume can take a while, and a failure here shouldn't
      # cause a boot failure.
      systemd.services."impermanence-prune-generations" = {
        description = "Prune retired impermanence btrfs subvolumes";
        unitConfig.RequiresMountsFor = ["/btrfs"];
        path = [pkgs.btrfs-progs pkgs.coreutils];
        serviceConfig = {
          Type = "oneshot";
          Nice = 19;
          IOSchedulingClass = "idle";
        };

        script = let
          retention = toString impermanence.generationRetentionDays;
        in ''
          retention_days=${retention}
          cutoff=$(( $(date +%s) - retention_days * 86400 ))

          # /btrfs is the current location. The /persist paths are where older
          # generations were archived before this layout existed - drop them
          # from this list once they are empty.
          for dir in /btrfs/old_roots /btrfs/old_homes \
                     /persist/old_roots /persist/old_homes; do
            [[ -d $dir ]] || continue

            for entry in "$dir"/*; do
              [[ -e $entry ]] || continue

              # Only touch entries we created ourselves (timestamped names).
              # New names are 2026-10-31T12:34:56Z[.N], older ones (archived
              # under /persist) are 2026-10-9_12:34:56.
              name=$(basename "$entry")
              stamp=''${name%%.*}
              stamp=''${stamp//_/ }
              created=$(date -d "$stamp" +%s 2>/dev/null) || continue
              (( created < cutoff )) || continue

              # Never recurse into anything that is not a subvolume, see
              # https://github.com/nix-community/impermanence/issues/258
              if [[ $(stat -c %i "$entry") -ne 256 ]]; then
                echo "WARNING: $entry is not a btrfs subvolume, skipping"
                continue
              fi

              echo "Deleting $entry"
              btrfs subvolume delete --recursive "$entry"
            done
          done
        '';
      };

      systemd.timers."impermanence-prune-generations" = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };
    };
}
