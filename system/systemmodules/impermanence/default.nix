{
  config,
  lib,
  mylib,
  username,
  pkgs,
  ...
}: let
  inherit (config.systemmodules) impermanence;
in {
  options.systemmodules.impermanence = import ./options.nix {inherit lib mylib;};

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
          (mkRDir "/root/.ssh" m700) # Restic's ssh key

          # https://github.com/nix-community/impermanence/issues/253
          (mkRDir "/usr/systemd-placeholder" m755)

          # TODO: Why does this use the mandb user?
          # (mkDir "mandb" "/var/cache/man" m755)

          (mkRDir "/var/cache/restic-backups-synology" m700) # Resitc's cache
          (mkRDir "/var/db/sudo" m711)
          (mkRDir "/var/lib/auto-cryptenroll" m755) # Lanzaboote
          (mkRDir "/var/lib/bluetooth" m755) # m700
          (mkRDir "/var/lib/btrfs" m755)
          (mkRDir "/var/lib/containers" m755)
          (mkRDir "/var/lib/docker" m755)
          (mkRDir "/var/lib/flatpak" m755)
          (mkRDir "/var/lib/libvirt" m755)
          (mkRDir "/var/lib/NetworkManager" m755)
          (mkRDir "/var/lib/nixos" m755)
          (mkRDir "/var/lib/sbctl" m755) # Lanzaboote
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

          # TODO: I need something that lists stale folders in /persist (folders that are no longer mounted into the system)
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
            (mkUDir ".claude" m755)
            (mkUDir ".codex" m755)
            # (mkUDir ".comfy" m755)
            (mkUDir ".docker" m755)
            # (mkUDir ".gradle" m755) # Unity
            (mkUDir ".java" m755) # JetBrains
            (mkUDir ".keychain" m755)
            (mkUDir ".lmstudio" m755)
            (mkUDir ".MakeMKV" m755)
            (mkUDir ".mozilla/firefox" m755) # TODO: Remove this someday
            (mkUDir ".mozilla/native-messaging-hosts" m755)
            (mkUDir ".nix-package-search" m755)
            (mkUDir ".npm" m755) # Contains mcp servers :/
            # (mkUDir ".nv" m755) # Unity
            # (mkUDir ".ollama" m755)
            (mkUDir ".opencode" m755)
            (mkUDir ".opencode-mem" m755)
            # (mkUDir ".plastic4" m755) # Unity
            (mkUDir ".tableplus" m755)
            (mkUDir ".tiddl" m755)
            (mkUDir ".var/app" m755)
            (mkUDir ".vim/undo" m755)
            (mkUDir ".vscode" m755)
            (mkUDir ".zotero" m755)

            # Cache that's actually useful
            (mkUDir ".cache/claude-cli-nodejs" m755)
            (mkUDir ".cache/elephant" m755)
            (mkUDir ".cache/fish/generated_completions" m755)
            (mkUDir ".cache/nix" m755)
            (mkUDir ".cache/nix-index" m755)
            (mkUDir ".cache/nix-search-tv" m755)
            (mkUDir ".cache/nvim" m755)
            (mkUDir ".cache/JetBrains" m755)
            (mkUDir ".cache/keepassxc" m755)
            (mkUDir ".cache/opencode" m755)
            (mkUDir ".cache/uv" m755)

            # Config
            # (mkUDir ".config/.android" m755) # Unity
            (mkUDir ".config/ai.opencode.desktop" m755)
            # (mkUDir ".config/beekeeper-studio" m755)
            (mkUDir ".config/beets" m755)
            (mkUDir ".config/blender" m755)
            (mkUDir ".config/chromium" m755)
            (mkUDir ".config/Claude" m755) # Claude desktop
            (mkUDir ".config/Code" m755)
            (mkUDir ".config/Codex" m755)
            (mkUDir ".config/Cryptomator" m755)
            (mkUDir ".config/Ferdium" m755)
            (mkUDir ".config/feishin" m755)
            (mkUDir ".config/fish/completions" m755)
            (mkUDir ".config/ghidra" m755)
            (mkUDir ".config/impermanence" m755)
            (mkUDir ".config/jellyfin-mpv-shim" m755)
            # (mkUDir ".config/jellyfin-tui" m755) # Configured using nix
            (mkUDir ".config/JetBrains" m755)
            (mkUDir ".config/kdeconnect" m755)
            (mkUDir ".config/keepassxc" m755)
            (mkUDir ".config/LM Studio" m755)
            (mkUDir ".config/Msty" m755)
            (mkUDir ".config/Nextcloud" m755)
            # (mkUDir ".config/niri/dms" m755)
            (mkUDir ".config/obsidian" m755)
            (mkUDir ".config/obs-studio" m755)
            (mkUDir ".config/opencode" m755)
            (mkUDir ".config/RimStack" m755)
            (mkUDir ".config/Signal" m755)
            # (mkUDir ".config/singularitygroup-hotreload" m755) # Unity
            (mkUDir ".config/TeamSpeak" m755)
            (mkUDir ".config/tidal-hifi" m755)
            (mkUDir ".config/tidal_dl_ng" m755)
            # (mkUDir ".config/unity3d" m755) # Unity
            # (mkUDir ".config/unityhub" m755) # Unity
            (mkUDir ".config/Vector 35" m755)
            (mkUDir ".config/vlc" m755)
            (mkUDir ".config/Zeal" m755)
            (mkUDir ".config/zed" m755)

            # Share
            (mkUDir ".local/share/Anki2" m755)
            # (mkUDir ".local/share/containers" m755) # Rootless docker
            (mkUDir ".local/share/direnv" m755)
            (mkUDir ".local/share/docker" m755)
            (mkUDir ".local/share/fish" m755)
            (mkUDir ".local/share/flatpak" m755)
            (mkUDir ".local/share/hyprland" m755)
            (mkUDir ".local/share/hytale-launcher" m755)
            (mkUDir ".local/share/Hytale" m755)
            (mkUDir ".local/share/io.github.CyberTimon.RapidRAW" m755)
            (mkUDir ".local/share/IsolatedStorage" m755) # JetBrains license data
            (mkUDir ".local/share/jellyfin-desktop" m755)
            (mkUDir ".local/share/jellyfin-tui" m755)
            (mkUDir ".local/share/JetBrains" m755) # Unity
            (mkUDir ".local/share/keyrings" m755) # m700
            (mkUDir ".local/share/LRCGET" m755)
            (mkUDir ".local/share/mime" m755)
            (mkUDir ".local/share/net.lrclib.lrcget" m755)
            (mkUDir ".local/share/Nextcloud" m755)
            (mkUDir ".local/share/nix" m755)
            (mkUDir ".local/share/nvim" m755)
            (mkUDir ".local/share/opencode" m755)
            (mkUDir ".local/share/org.localsend.localsend_app" m755)
            (mkUDir ".local/share/qutebrowser" m755)
            (mkUDir ".local/share/Rack2" m755)
            (mkUDir ".local/share/RimStack" m755)
            (mkUDir ".local/share/systemd" m755)
            # (mkUDir ".local/share/unity3d" m755) # Unity
            (mkUDir ".local/share/xemu-lgb" m755)
            (mkUDir ".local/share/zathura" m755)
            (mkUDir ".local/share/zed" m755)
            (mkUDir ".local/share/zoxide" m755)

            # State
            (mkUDir ".local/state/astal/notifd" m755)
            (mkUDir ".local/state/home-manager/gc-roots" m755) # nix-flatpak stores its state there
            (mkUDir ".local/state/lazygit" m755)
            (mkUDir ".local/state/nix" m755)
            (mkUDir ".local/state/nvim" m755)
            (mkUDir ".local/state/opencode" m755)
            (mkUDir ".local/state/waypaper" m755)
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
