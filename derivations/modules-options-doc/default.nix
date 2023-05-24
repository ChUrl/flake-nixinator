{
  stdenv,
  lib,
  pkgs,
  mylib,
  ...
}: let
  # create a module that only contains the options, type can be home or system
  toModule = type: name: {options.modules.${name} = import ../../${type}/modules/${name}/options.nix {inherit lib mylib;};};

  # evaluate a single module
  evalModule = type: name: (lib.evalModules {modules = [(toModule type name)];});

  # generate a single module doc
  optionsDoc = type: name: pkgs.nixosOptionsDoc {options = (evalModule type name).options;};

  # copy the markdown for a single generated optionsDoc
  optionsMD = type: name:
    stdenv.mkDerivation {
      src = ./.;
      name = "options-doc-${name}";
      buildPhase = ''
        mkdir $out
        cat ${(optionsDoc type name).optionsCommonMark} >> $out/${name}.md
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
    home-modules: system-modules:
      pkgs.symlinkJoin {
        name = "modules-options-doc-md";
        paths = (map (optionsMD "home") home-modules) ++ (map (optionsMD "system") system-modules) ++ [index];
      };

  # generate the actual package (calls all of the above)
  home-modules = [
    "audio"
    "chromium"
    "emacs"
    "email"
    "firefox"
    "fish"
    "flatpak"
    "gaming"
    "helix"
    "hyprland"
    "kitty"
    "misc"
    "neovim"
    "nextcloud"
    "nnn"
    "ranger"
    "vscode"
  ];
  system-modules = [
    "containers"
    "systemd-networkd"
  ];
  docs = allOptionsMDs home-modules system-modules;
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

    # TODO: Use a file, this is stupid
    # TODO: Fix the navigation sections
    # TODO: Customize features
    # TODO: Remove or fix ToC
    # symlink our generated docs into the correct folder before generating
    buildPhase = ''
      # configure mkdocs
      echo "site_name: Chriphost NixOS Options" >> ./mkdocs.yml
      echo "use_directory_urls: false" >> ./mkdocs.yml
      echo "theme:" >> ./mkdocs.yml
      echo "  name: material" >> ./mkdocs.yml
      echo "  features:" >> ./mkdocs.yml
      echo "    - navigation.sections" >> ./mkdocs.yml
      echo "nav:" >> ./mkdocs.yml
      echo "  - System:"
      echo -e "      - ${builtins.concatStringsSep ".md\n      - " system-modules}.md" >> ./mkdocs.yml
      echo "  - Home:"
      echo -e "      - ${builtins.concatStringsSep ".md\n      - " home-modules}.md" >> ./mkdocs.yml

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
