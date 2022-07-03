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

    useDoom = mkOption {
      type = types.bool;
      default = false;
      description = "Use the Doom Emacs framework";
    };
  };

  # Config is the merged set of all module configurations
  # Here we define what happens to the config if the module is active (but only if the module is active)
  # Since this module is for HomeManager, config is not the system config
  config = mkIf cfg.enable {
    # What home packages should be enabled
    home.packages = with pkgs; [
      # NOTE: I have problems with emacsPgtkNativeComp/emacsPgtk and also emacs28NativeComp GUI
      ((emacsPackagesFor emacsPgtkNativeComp).emacsWithPackages
        (epkgs: [ epkgs.vterm ]))

      binutils
      zstd
      (ripgrep.override { withPCRE2 = true; })
      fd
      # libgccjit
      sqlite
      # TODO: I probably need python too
      python310Packages.pygments
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
    ];

    # Do this in packages
    # programs.emacs = {
    #   package = pkgs.emacsPgtkNativeComp;
    #   enable = true;
    # };

    home.sessionPath = [ "/home/${config.home.username}/.emacs.d/bin" ];

    # We tell HomeManager where the config files belong
    # home.file.".config/doom" = {
    #   # With onChange you even could rebuild doom emacs when rebuilding HomeManager but I don't want this to become too slow
    #   recursive = true; # is a directory
    #   source = ../../config/doom;
    # };

    # If doom is enabled we want to clone the framework
    # The activation script is being run when home-manager rebuilds
    home.activation = mkIf cfg.useDoom {
      # Because we write to the filesystem, this script has to be run after HomeManager's writeBoundary
      installDoomEmacs = hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "${config.home.homeDirectory}/.emacs.d" ]; then
          git clone --depth=1 --single-branch "https://github.com/doomemacs/doomemacs" "${config.home.homeDirectory}/.emacs.d"
        fi
      '';

      # With this approach we keep the config mutable as it is not copied and linked from store
      linkDoomConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -L "${config.home.homeDirectory}/.config/doom" ]; then
          ln -sf ${config.home.homeDirectory}/NixFlake/config/doom ${config.home.homeDirectory}/.config/doom
        fi
      '';
    };
  };
}
