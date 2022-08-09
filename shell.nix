{ pkgs }:

pkgs.devshell.mkShell {
  name = "NixFlake Shell";

  packages = with pkgs; [
    jetbrains.clion
  ];

  commands = [
    {
      name = "ide";
      help = "Launch clion in this folder";
      command = "clion ./ &>/dev/null &";
    }
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
      name = "switch-nixinator";
      help = "Rebuild and activate the nixinator config";
      command = "sudo nixos-rebuild switch --flake .#nixinator";
    }
    {
      name = "build-nixinator";
      help = "Rebuild and diff the nixinator config";
      command = "sudo nixos-rebuild build --flake .#nixinator | nvd diff /run/current-system result";
    }
    {
      name = "switch-nixtop";
      help = "Rebuild and activate the nixtop config";
      command = "sudo nixos-rebuild switch --flake .#nixtop";
    }
    {
      name = "build-nixtop";
      help = "Rebuild and diff the nixtop config";
      command = "sudo nixos-rebuild build --flake .#nixtop | nvd diff /run/current-system result";
    }
  ];
}
