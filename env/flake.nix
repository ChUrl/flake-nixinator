{
  description = "";

  inputs = {
    nixpkgs.url = "nixpkgs"; # Use nixpkgs from system registry
    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    inputs,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.rust-overlay.overlays.default
        ];
      };

      python = pkgs.python313.withPackages (p:
        with p; [
          pyside6
          ffmpeg-python
          matplotlib
          numpy
        ]);

      rust = pkgs.rust-bin.stable.latest.default.override {
        extensions = ["rust-src"]; # Include the Rust stdlib source (for IntelliJ)
      };

      # 64 bit C/C++ compilers that don't collide (use the same libc)
      bintools = pkgs.wrapBintoolsWith {
        bintools = pkgs.bintools.bintools; # Unwrapped bintools
        libc = pkgs.glibc;
      };
      gcc = pkgs.hiPrio (pkgs.wrapCCWith {
        cc = pkgs.gcc15.cc; # Unwrapped gcc
        libc = pkgs.glibc;
        bintools = bintools;
      });
      clang = pkgs.wrapCCWith {
        cc = pkgs.clang_20.cc; # Unwrapped clang
        libc = pkgs.glibc;
        bintools = bintools;
      };

      # Multilib C/C++ compilers that don't collide (use the same libc)
      bintools_multilib = pkgs.wrapBintoolsWith {
        bintools = pkgs.bintools.bintools; # Unwrapped bintools
        libc = pkgs.glibc_multi;
      };
      gcc_multilib = pkgs.hiPrio (pkgs.wrapCCWith {
        cc = pkgs.gcc15.cc; # Unwrapped gcc
        libc = pkgs.glibc_multi;
        bintools = bintools_multilib;
      });
      clang_multilib = pkgs.wrapCCWith {
        cc = pkgs.clang_20.cc; # Unwrapped clang
        libc = pkgs.glibc_multi;
        bintools = bintools_multilib;
      };
    in {
      # TODO: Add default packages for different languages
      # TODO: check nixpkgs docs for buildPythonApplication
      # packages.default = pkgs.buildPythonApplication {
      #   pname = "pyside6_image_viewer";
      #   version = "0.1.0";
      # };

      devShell = pkgs.mkShell {
        name = "Development Environment";

        # Comments on buildInputs, nativeBuildInputs, buildPackages:
        # https://discourse.nixos.org/t/use-buildinputs-or-nativebuildinputs-for-nix-shell/8464
        # For our "nix develop" shell, buildInputs can be used for everything.

        # Stuff that's linked against.
        # Architecture will be the host platform.
        # Packages will be added to $PATH unless "strictDeps = true;".
        buildInputs = with pkgs; [
          # Languages:
          # python
          # rust
          # bintools
          # gcc
          # clang
          # bintools_multilib
          # gcc_multilib
          # clang_multilib

          # C/C++:
          # gdb
          # valgrind
          # gnumake
          # cmake
          # boost
          # sfml

          # Qt:
          # qt6.qtbase
          # qt6.full
          # qt6.wrapQtAppsHook # For the shellHook
        ];

        # Stuff ran at build-time (e.g. cmake, autoPatchelfHook).
        # Architecture will be the build platform (relevant for e.g. cross-compilation).
        # Packages will be added to $PATH.
        nativeBuildInputs = with pkgs; [
        ];

        # Rust stdlib source:
        # RUST_SRC_PATH = "${rust}/lib/rustlib/src/rust/library";

        # Dynamic libraries example:
        # LD_LIBRARY_PATH = builtins.concatStringsSep ":" [
        #   # Rust Bevy GUI app
        #   "${pkgs.xorg.libX11}/lib"
        #   "${pkgs.xorg.libXcursor}/lib"
        #   "${pkgs.xorg.libXrandr}/lib"
        #   "${pkgs.xorg.libXi}/lib"
        #   "${pkgs.libGL}/lib"
        # ];

        # Dynamic libraries from buildinputs:
        # LD_LIBRARY_PATH = nixpkgs.lib.makeLibraryPath buildInputs;

        # Setup the shell when entering the "nix develop" environment
        shellHook = builtins.concatStringsSep "\n" [
          # Qt: Set the environment variables that Qt apps expect
          # ''
          #   fishdir=$(mktemp -d)
          #   makeWrapper "$(type -p fish)" "$fishdir/fish" "''${qtWrapperArgs[@]}"
          #   exec "$fishdir/fish"
          # ''

          # Add shell abbreviations specific to this build environment
          # ''
          #   abbr -a build-release-windows "CARGO_FEATURE_PURE=1 cargo xwin build --release --target x86_64-pc-windows-msvc"
          # ''
        ];
      };
    });
}
