{pkgs}:
pkgs.devshell.mkShell {
  name = "NixFlake Shell";

  packages = with pkgs; [
    # jetbrains.clion
  ];

  commands = [
    # Utility
    # {
    #   name = "util-ide";
    #   help = "Launch clion in this folder";
    #   command = "clion ./ &>/dev/null &";
    # }
    {
      name = "util-watch-flatpak";
      help = "Show running flatpak operations";
      command = "watch -n 0.5 -d procs flatpak";
    }
    {
      name = "util-watch-doom";
      help = "Show running doom operations";
      command = "watch -n 0.5 -d procs doom";
    }
    {
      name = "util-pkgs-sys";
      help = "List currently installed system packages";
      command = "bat /etc/current-system-packages";
    }
    {
      name = "util-pkgs-usr";
      help = "List currently installed user packages";
      command = "bat ~/.local/share/current-user-packages";
    }
    {
      name = "util-diff-system";
      help = "Compare current system to ./result";
      command = "nvd diff /run/current-system result";
    }
    {
      name = "util-data-dirs";
      help = "List XDG_DATA_DIRS in a readable format";
      command = ''echo $XDG_DATA_DIRS | sed "s/:/\n/g" | sort -u'';
    }

    # Flake
    {
      name = "flake-update";
      help = "Update the flake";
      command = "nix flake update";
    }
    {
      name = "flake-check";
      help = "Validate the flake";
      command = "nix flake check";
    }
    {
      name = "flake-trace";
      help = "Validate the flake with stack trace";
      command = "nix flake check --show-trace";
    }

    # Nix Store
    {
      name = "store-gc";
      help = "Run NixOS garbage collector";
      command = "nix-store --gc && sudo nix-collect-garbage -d && flatpak uninstall --unused";
    }
    {
      name = "store-optimise";
      help = "Run NixOS store optimization (slow)";
      command = "nix-store --optimise -vv";
    }
    {
      name = "store-verify";
      help = "Run NixOS store verification with repair (slow)";
      command = "nix-store --verify --check-contents";
    }

    # Rebuild
    {
      name = "rebuild-switch-nixinator";
      help = "Rebuild and activate the nixinator config";
      command = "sudo nixos-rebuild switch --flake .#nixinator";
    }
    {
      name = "rebuild-build-nixinator";
      help = "Rebuild the nixinator config (to diff systems)";
      command = "sudo nixos-rebuild build --flake .#nixinator";
    }
    {
      name = "rebuild-boot-nixinator";
      help = "Rebuild and activate config on next boot";
      command = "sudo nixos-rebuild boot --flake .#nixinator";
    }
    {
      name = "rebuild-switch-nixtop";
      help = "Rebuild and activate the nixtop config";
      command = "sudo nixos-rebuild switch --flake .#nixtop";
    }
    {
      name = "rebuild-build-nixtop";
      help = "Rebuild and diff the nixtop config (to diff systems)";
      command = "sudo nixos-rebuild build --flake .#nixtop";
    }
    {
      name = "rebuild-boot-nixtop";
      help = "Rebuild and activate config on next boot";
      command = "sudo nixos-rebuild boot --flake .#nixtop";
    }
    {
      name = "rebuild-switch-servenix";
      help = "Rebuild and activate the servenix config";
      command = "sudo nixos-rebuild switch --flake .#servenix";
    }
    {
      name = "rebuild-build-servenix";
      help = "Rebuild and diff the servenix config (to diff systems)";
      command = "sudo nixos-rebuild build --flake .#servenix";
    }
    {
      name = "rebuild-boot-servenix";
      help = "Rebuild and activate config on next boot";
      command = "sudo nixos-rebuild boot --flake .#servenix";
    }

    # Help text (this is pretty stupid)
    {
      name = "help-store-path";
      help = "Display the location of a binary in the nix store";
      command = "echo 'readlink -f (which <arg>)'";
    }
    {
      name = "help-libraries";
      help = "Display the wanted dynamic libraries by a binary";
      command = "echo 'ldd (readlink -f (which <arg>))'";
    }
    {
      name = "help-closure";
      help = "Display the closure of a package";
      command = "echo 'nix path-info --recursive --size --closure-size --human-readable (readlink -f (which <arg>))'";
    }
  ];
}
