{
  description = "Python Environment";

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

      python-with-packages = pkgs.python311.withPackages (p:
        with p; [
          # Basic
          rich
          # python-dotenv

          # Math
          # numpy
          # matplotlib
          # sympy

          # Web
          # flask
          # flask-sqlalchemy
          # sqlalchemy

          # Discord
          # discordpy
          # pynacl # discordpy voice support

          # Scraping
          # beautifulsoup4
          # requests
        ]);
    in {
      devShell = pkgs.devshell.mkShell {
        name = "Python Environment";

        packages = with pkgs; [
          python-with-packages
        ];

        # Use $1 for positional args
        commands = [
          # {
          #   name = "";
          #   help = "";
          #   command = "";
          # }
        ];
      };
    });
}
