{
  description = "C/C++ Environment with Libraries";

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

      # NOTE: Usual 64 bit compilers that don't collide
      bintools = pkgs.wrapBintoolsWith {
        bintools = pkgs.bintools.bintools;
        libc = pkgs.glibc;
      };
      gcc12 = pkgs.hiPrio (pkgs.wrapCCWith {
        cc = pkgs.gcc12.cc;
        libc = pkgs.glibc;
        bintools = bintools;
      });
      clang15 = pkgs.wrapCCWith {
        cc = pkgs.clang_15.cc;
        libc = pkgs.glibc;
        bintools = bintools;
      };

      # NOTE: Multilib compilers that don't collide
      bintools_multi = pkgs.wrapBintoolsWith {
        bintools = pkgs.bintools.bintools; # Get the unwrapped bintools from the wrapper
        libc = pkgs.glibc_multi;
      };
      gcc12_multi = pkgs.hiPrio (pkgs.wrapCCWith {
        cc = pkgs.gcc12.cc; # Get the unwrapped gcc from the wrapper
        libc = pkgs.glibc_multi;
        bintools = bintools_multi;
      });
      clang15_multi = pkgs.wrapCCWith {
        cc = pkgs.clang_15.cc;
        libc = pkgs.glibc_multi;
        bintools = bintools_multi;
      };
    in {
      # NOTE: We cannot use devshell, as it doesn't propagate library paths (yet?)
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Compilers
          bintools
          gcc12
          clang15
          # bintools_multi
          # gcc12_multi
          # clang14_multi

          # Native buildinputs
          gnumake
          cmake
          # nasm

          # Development
          # bear # To generate compilation database
          gdb
          cling # To try out my bullshit implementations
          # doxygen # Generate docs + graphs

          # Libraries
          # boost181
          # raylib
          # sfml
        ];
      };
    });
}
