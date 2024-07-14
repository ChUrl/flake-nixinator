{
  description = "Java Environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.devshell.url = "github:numtide/devshell";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # For clion
        overlays = [devshell.overlays.default];
      };
    in {
      devShell = pkgs.devshell.mkShell {
        name = "Java Environment";

        packages = with pkgs; [
          jdk22
          jdt-language-server
          gradle
        ];

        commands = [];
      };
    });
}
