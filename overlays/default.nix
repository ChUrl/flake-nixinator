{
  inputs,
  nixpkgs,
  pkgs-stable,
  ...
}: let
  # Taken from https://github.com/Misterio77/nix-config/blob/main/overlay/default.nix
  # By specifying this we can just add our derivation to derivations/default.nix and it will land here
  additions = final: prev:
    import ../derivations {
      inherit inputs;
      pkgs = final;
    };

  modifications = final: prev: {
    # Only kept as an example, has nothing to do with current dconf-editor-wrapped derivation
    # dconf-editor-wrapped = import ./dconf-editor.nix { inherit final prev; };
    # Use dconf-editor.nix: { final, prev }: final.<package>.overrideAttrs (oldAttrs: { ... }) or sth similar

    # Overriding specific packages from a different nixpkgs (e.g. a pull request)
    # can be done like this. Note that this creates an additional nixpkgs instance.
    # https://github.com/NixOS/nixpkgs/issues/418451
    # unityhub_3_13 =
    #   (import inputs.unityhub-pinned {
    #     config.allowUnfree = true;
    #     localSystem = {inherit (prev) system;};
    #   }).unityhub;

    # Remove this after jetbrains.jdk builds again (nixpkgs issue 425328)
    # jetbrains.rider = pkgs-stable.jetbrains.rider;

    jetbrains =
      prev.jetbrains
      // {
        clion = prev.jetbrains.clion.overrideAttrs (oldAttrs: rec {
          version = "2026.1-EAP";

          src = prev.fetchurl {
            url = "https://download-cdn.jetbrains.com/cpp/CLion-261.21849.6.tar.gz";
            hash = "sha256-h6tnemVnV1YEsvIndwrq2sMsRZYuvTWMU5oqj/hkjdY=";
          };

          # autoPatchelfIgnoreMissingDeps = [
          #   "libcrypto.so.1.1"
          #   "libssl.so.1.1"
          # ];

          postFixup = ''
            # Patch python3.12 shared libs that the upstream glob (python3.8) misses
            find $out -path '*/python3.*/lib-dynload/*.so' -exec patchelf \
              --replace-needed libssl.so.1.1 libssl.so \
              --replace-needed libcrypto.so.1.1 libcrypto.so \
              --replace-needed libcrypt.so.1 libcrypt.so \
              {} +

            ${oldAttrs.postFixup or ""}
          '';
        });
      };

    # Now in Nixpkgs
    # neovide = prev.neovide.overrideAttrs (finalAttrs: prevAttrs: {
    #   version = "0.15.1";
    #   src = prev.fetchFromGitHub {
    #     owner = "neovide";
    #     repo = "neovide";
    #     tag = finalAttrs.version;
    #     hash = "sha256-2iV3g6tcCkMF7sFG/GZDz3czPZNIDi6YLfrVzYO9jYI=";
    #   };
    #   cargoHash = "sha256-YlHAcUCRk6ROg5yXIumHfsiR/2TrsSzbuXz/IQK7sEo=";
    #   cargoDeps = prev.rustPlatform.fetchCargoVendor {
    #     inherit (finalAttrs) pname src version;
    #     hash = finalAttrs.cargoHash;
    #   };
    # });

    # Now in Nixpkgs
    # rmpc = prev.rmpc.overrideAttrs (finalAttrs: prevAttrs: {
    #   version = "0.10.0";
    #   src = prev.fetchFromGitHub {
    #     owner = "mierak";
    #     repo = "rmpc";
    #     rev = "v0.10.0";
    #     hash = "sha256-NU8T26oPhm8L7wdO4p65cpNa0pax7/oqHGs98QDoEc0=";
    #   };
    #   cargoHash = "sha256-d2/4q2s/11HNE18D8d8Y2yWidhT+XsUS4J9ahnxToI0=";
    #   cargoDeps = prev.rustPlatform.fetchCargoVendor {
    #     inherit (finalAttrs) pname src version;
    #     hash = finalAttrs.cargoHash;
    #   };
    # });
  };
in
  # Composes a list of overlays and returns a single overlay function that combines them.
  nixpkgs.lib.composeManyExtensions [additions modifications]
