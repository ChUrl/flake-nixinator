{
  description = "Rust development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  outputs = { self, nixpkgs, flake-utils, devshell, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # For clion
          overlays = [
            devshell.overlay
            rust-overlay.overlays.default
          ];
        };

        # Includes cargo, rustc, rustfmt
        rust-stable = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ]; # Include the rust stdlib source for intellij
        };
      in {
        devShell = pkgs.devshell.mkShell {
          name = "Rust development shell";

          packages = with pkgs; [
            rust-stable
            rust-analyzer

            jetbrains.clion
          ];

          env = [
            # Allow for intellij to find the stdlib
            # {
            #   name = "RUST_SRC_PATH";
            #   value = "${rust-stable}/lib/rustlib/src/rust/library";
            # }

            # Use this if the rust binary needs additional libraries
            # {
            #   name = "LD_LIBRARY_PATH";
            #   value = "${pkgs.xorg.libX11}/lib:${pkgs.xorg.libXcursor}/lib:${pkgs.xorg.libXrandr}/lib:${pkgs.xorg.libXi}/lib:${pkgs.libGL}/lib";
            # }
          ];

          commands = [
            {
              name = "ide";
              help = "Run clion for project";
              command = "clion &>/dev/null ./ &";
            }
          ];
        };
      });
}
