{ pkgs }:

pkgs.devshell.mkShell {
  name = "NixFlake Shell";

  packages = with pkgs; [
    jetbrains.clion
  ];

  commands = [
    # Utility
    {
      name = "ide";
      help = "Launch clion in this folder";
      command = "clion ./ &>/dev/null &";
    }
    {
      name = "watch-flatpak";
      help = "Show running flatpak operations";
      command = "watch -n 0.5 -d procs flatpak";
    }
    {
      name = "pkgs-sys";
      help = "List currently installed system packages";
      command = "bat /etc/current-system-packages";
    }
    {
      name = "pkgs-usr";
      help = "List currently installed user packages";
      command = "bat ~/.local/share/current-user-packages";
    }
    {
      name = "diff-system";
      help = "Compare current system to ./result";
      command = "nvd diff /run/current-system result";
    }

    # Flake
    {
      name = "update";
      help = "Update the flake";
      command = "nix flake update";
    }
    {
      name = "check";
      help = "Validate the flake";
      command = "nix flake check";
    }

    # Nix Store
    {
      name = "gc";
      help = "Run NixOS garbage collector";
      command = "nix-store --gc";
    }
    {
      name = "optimise";
      help = "Run NixOS store optimization (slow)";
      command = "nix-store --optimise -vv";
    }
    {
      name = "verify";
      help = "Run NixOS store verification with repair (slow)";
      command = "nix-store --verify --check-contents";
    }

    # Rebuild
    {
      name = "switch-nixinator";
      help = "Rebuild and activate the nixinator config";
      command = "sudo nixos-rebuild switch --flake .#nixinator";
    }
    {
      name = "build-nixinator";
      help = "Rebuild and diff the nixinator config";
      command = "sudo nixos-rebuild build --flake .#nixinator";
    }
    {
      name = "switch-nixtop";
      help = "Rebuild and activate the nixtop config";
      command = "sudo nixos-rebuild switch --flake .#nixtop";
    }
    {
      name = "build-nixtop";
      help = "Rebuild and diff the nixtop config";
      command = "sudo nixos-rebuild build --flake .#nixtop";
    }
  ];
}
