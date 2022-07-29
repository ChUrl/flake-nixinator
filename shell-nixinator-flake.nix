{
  description = "BSEos flake for development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.devshell.url = "github:numtide/devshell";

  outputs = { self, nixpkgs, flake-utils, devshell }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # For clion
          overlays = [ devshell.overlay ];
        };

      in {
        devShell = pkgs.devshell.mkShell {
          name = "NixFlake";

          packages = with pkgs; [
            jetbrains.clion
          ];
          commands = [
            {
              name = "ide";
              help = "Run clion for project";
              command = "clion &>/dev/null ./ &";
            }
            {
              name = "rebuild";
              help = "Build the configuration and activate the system";
              command = "sudo nixos-rebuild switch --flake .#nixinator";
            }
            {
              name = "upgrade";
              help = "Upgrade the flake, rebuild the system and show diff";
              command = "nix flake update && sudo nixos-rebuild build --flake .#nixinator && nvd diff /run/current-system result";
            }
          ];
        };
      });
}
