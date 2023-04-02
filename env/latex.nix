{
  description = "LaTeX Environment";

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
        config.allowUnfree = true;
        overlays = [devshell.overlays.default];
      };

      # TODO: Custom LaTeX "distribution"? With curated packages?
    in {
      devShell = pkgs.devshell.mkShell {
        name = "LaTeX Environment";

        packages = with pkgs; [
          texlab
        ];
      };
    });
}
