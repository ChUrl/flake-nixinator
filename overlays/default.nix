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

    rmpc = prev.rmpc.overrideAttrs (finalAttrs: prevAttrs: {
      version = "0.10.0";
      src = prev.fetchFromGitHub {
        owner = "mierak";
        repo = "rmpc";
        rev = "v0.10.0";
        hash = "sha256-NU8T26oPhm8L7wdO4p65cpNa0pax7/oqHGs98QDoEc0=";
      };
      cargoHash = "sha256-d2/4q2s/11HNE18D8d8Y2yWidhT+XsUS4J9ahnxToI0=";
      cargoDeps = prev.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname src version;
        hash = finalAttrs.cargoHash;
      };
    });
  };
in
  # Composes a list of overlays and returns a single overlay function that combines them.
  nixpkgs.lib.composeManyExtensions [additions modifications]
