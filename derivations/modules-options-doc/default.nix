{
  stdenv,
  lib,
  pkgs,
  ...
}: let
  # evaluate our options
  eval = lib.evalModules {
    modules = [
      ../../home/modules/audio/options.nix
      ../../home/modules/emacs/options.nix
      ../../home/modules/email/options.nix
      ../../home/modules/firefox/options.nix
      ../../home/modules/fish/options.nix
      ../../home/modules/flatpak/options.nix
      ../../home/modules/gaming/options.nix
      ../../home/modules/gnome/options.nix
      ../../home/modules/hyprland/options.nix
      ../../home/modules/kitty/options.nix
      ../../home/modules/misc/options.nix
      ../../home/modules/neovim/options.nix
      ../../home/modules/nextcloud/options.nix
      ../../home/modules/plasma/options.nix
      ../../home/modules/ranger/options.nix
    ];
  };

  # generate our docs
  optionsDoc = pkgs.nixosOptionsDoc {
    inherit (eval) options;
  };

  # create a derivation for capturing the markdown output
  optionsDocMD = pkgs.runCommand "options-doc.md" {} ''
    cat ${optionsDoc.optionsCommonMark} >> $out
  '';
in
  stdenv.mkDerivation {
    src = ./.;
    name = "modules-options-doc";

    # depend on our options doc derivation
    buildInput = [optionsDocMD];

    # mkdocs dependencies
    nativeBuildInputs = with pkgs; [
      mkdocs
      python310Packages.mkdocs-material
      python310Packages.pygments
    ];

    # symlink our generated docs into the correct folder before generating
    buildPhase = ''
      ln -s ${optionsDocMD} "./docs/nixos-options.md"
      # generate the site
      mkdocs build
    '';

    # copy the resulting output to the derivation's $out directory
    installPhase = ''
      mv site $out
    '';
  }
