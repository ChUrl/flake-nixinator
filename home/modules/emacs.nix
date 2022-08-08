# https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules

# This is a function with arguments
{ config, lib, pkgs, ... }:

# We add stuff from lib to our namespace (mkOption...)
with lib;

let
  # This is the current state of the option that this module defines
  # We use it to determine if the config should be changed below
  cfg = config.modules.emacs;
in {
  imports = [ ];

  # Options is a vector of options this module defines
  # This module defines only the "emacs" option and suboptions "enable" and "doom"
  options.modules.emacs = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the GNU Emacs editor";
    };

    doom = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Use the Doom Emacs framework";
      };

      autoSync = mkOption {
        type = types.bool;
        default = false;
        description = "Sync Doom Emacs on nixos-rebuild";
      };

      autoUpgrade = mkOption {
        type = types.bool;
        default = false;
        description = "Automatically upgrade Doom Emacs on nixos-rebuild";
      };
    };
  };

  # Config is the merged set of all module configurations
  # Here we define what happens to the config if the module is active (but only if the module is active)
  # Since this module is for HomeManager, config is not the system config
  # Attribute sets like config can be defined multiple times (every module defines a different config), on
  # building the config they are merged
  # Because config depends on itself recursively (through cfg) we use mkIf instead of the normal if...then...else,
  # as it delays the evaluation (the if is moved inside the assignments inside the set)
  # mkIf can only be used in the config section (like mkMerge, mkForce and co)
  config = mkIf cfg.enable {

    # What home packages should be enabled
    home.packages = with pkgs; [
      ((emacsPackagesFor emacsPgtkNativeComp).emacsWithPackages
        (epkgs: [ epkgs.vterm ]))

      # binutils # conflicts with gcc
      zstd
      (ripgrep.override { withPCRE2 = true; })
      fd
      # libgccjit
      sqlite
      inkscape
      graphviz
      gnuplot
      pandoc
      nixfmt
      shellcheck
      maim
      # TODO: Use LaTeX module instead
      texlive.combined.scheme-medium
      emacs-all-the-icons-fonts
      bashInteractive # For keychain

      # Treemacs needs python + syntax coloring in org/latex needs pygments
      (python310.withPackages (ppkgs:
        [
          ppkgs.pygments
        ])) # withPackages expects a function that gets all the packages as argument and returns a list with the packages we want
    ];

    home.sessionPath = mkIf cfg.doom.enable [ "${config.home.homeDirectory}/.emacs.d/bin" ];

    # Note: Don't do it this way as the config becomes immutable
    # We tell HomeManager where the config files belong
    # home.file.".config/doom" = {
    #   # With onChange you even could rebuild doom emacs when rebuilding HomeManager but I don't want this to become too slow
    #   recursive = true; # is a directory
    #   source = ../../config/doom;
    # };

    home.activation = mkMerge [

      # The parantheses around mkIf are needed for precedence in this case
      (mkIf cfg.doom.enable {

        # If doom is enabled we want to clone the framework
        # The activation script is being run when home-manager rebuilds
        # Because we write to the filesystem, this script has to be run after HomeManager's writeBoundary
        installDoomEmacs = hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d "${config.home.homeDirectory}/.emacs.d" ]; then
            git clone --depth=1 --single-branch "https://github.com/doomemacs/doomemacs" "${config.home.homeDirectory}/.emacs.d"
          fi
        '';

        # With this approach we keep the config mutable as it is not copied and linked from store
        linkDoomConfig = hm.dag.entryAfter [ "writeBoundary" "installDoomEmacs" ] ''
          if [ ! -L "${config.home.homeDirectory}/.config/doom" ]; then
            ln -sf ${config.home.homeDirectory}/NixFlake/config/doom ${config.home.homeDirectory}/.config/doom
          fi
        '';
      })

      (mkIf (cfg.doom.enable && cfg.doom.autoSync) {

        syncDoomEmacs = hm.dag.entryAfter [ "writeBoundary" "linkDoomConfig" ] ''
          ${config.home.homeDirectory}/.emacs.d/bin/doom sync
        '';
      })

      (mkIf (cfg.doom.enable && cfg.doom.autoUpgrade) {

        upgradeDoomEmacs = hm.dag.entryAfter [ "writeBoundary" "linkDoomConfig" ] ''
          ${config.home.homeDirectory}/.emacs.d/bin/doom upgrade -!
        '';
      })
    ];
  };
}
