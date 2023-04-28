{
  stdenv,
  lib,
  pkgs,
  mylib,
  ...
}: let
  # create a module that only contains the options
  toModule = name: {options.modules.${name} = (import ../../home/modules/${name}/options.nix {inherit lib mylib;});};

  # evaluate a single module
  evalModule = name: (lib.evalModules {modules = [(toModule name)];});

  # generate a single module doc
  optionsDoc = name: pkgs.nixosOptionsDoc {options = (evalModule name).options;};

  # copy the markdown for a single generated optionsDoc
  optionsMD = name: stdenv.mkDerivation {
    src = ./.;
    name = "options-doc-${name}";
    buildPhase = ''
      mkdir $out
      cat ${(optionsDoc name).optionsCommonMark} >> $out/${name}.md
    '';
  };

  # copy the markdown for all generated optionsDocs
  allOptionsMDs = let 
    index = stdenv.mkDerivation {
      src = ./.;
      name = "modules-options-index-md";
      buildPhase = ''
        mkdir $out
        echo "# Chriphost NixOS Modules Options" >> $out/index.md
      '';
    };
  in 
  names: pkgs.symlinkJoin {
    name = "modules-options-doc-md";
    paths = (map optionsMD names) ++ [index];
  };

  # generate the actual package (calls all of the above)
  modules = [
    "audio"
    "emacs"
    "email"
    "firefox"
    "fish"
    "flatpak"
    "gaming"
    "gnome"
    "hyprland"
    "kitty"
    "misc"
    "neovim"
    "nextcloud"
    "nzbget"
    "plasma"
    "ranger"
  ];
  docs = allOptionsMDs modules;
in
  stdenv.mkDerivation {
    src = ./.;
    name = "modules-options-doc";

    # depend on our options doc derivation
    buildInput = [docs];

    # mkdocs dependencies
    nativeBuildInputs = with pkgs; [
      mkdocs
      python310Packages.mkdocs-material
      python310Packages.pygments
    ];

    # symlink our generated docs into the correct folder before generating
    buildPhase = ''
      # configure mkdocs
      echo "site_name: Chriphost NixOS Options" >> ./mkdocs.yml
      echo "use_directory_urls: false" >> ./mkdocs.yml
      echo "theme:" >> ./mkdocs.yml
      echo "  name: material" >> ./mkdocs.yml
      echo "nav:" >> ./mkdocs.yml
      echo -e "  - ${builtins.concatStringsSep ".md\n  - " modules}.md" >> ./mkdocs.yml

      # mkdir ./docs
      ln -s ${docs} "./docs"

      # generate the site
      mkdocs build
    '';

    # copy the resulting output to the derivation's $out directory
    installPhase = ''
      mv site $out
    '';
  }
