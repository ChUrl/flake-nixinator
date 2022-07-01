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
  imports = [];

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
    home.packages = [
      binutils
      zstd
      (ripgrep.override { withPCRE2 = true; })
      fd
      # libgccjit
      sqlite
      python310Packages.pygments
      inkscape
      graphviz
      gnuplot
      pandoc
      nixfmt
      shellcheck
      maim
    ];

    programs.emacs = {
      package = pkgs.emacsPgtkNativeComp;
      enable = true;
    };

    home.sessionPath = [
      "/home/${config.home.username}/.emacs.d/bin"
    ];

    # TODO:
    # fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];

    # If doom is enabled we want to clone the framework
    system.userActivationScripts = mkIf cfg.useDoom {
      installDoomEmacs = ''
        if [ ! -d "${config.home.homeDirectory}/.emacs.d" ]; then
           git clone --depth=1 --single-branch "https://github.com/doomemacs/doomemacs" "${config.home.homeDirectory}/.emacs.d"
        fi
      '';
    };
  };
}
