# Changed from https://github.com/nix-community/home-manager/blob/master/modules/services/nextcloud-client.nix
# I use this instead of the HM module as the autostart wasn't working there

# TODO: Check the HM module again if anything changed, as this has also stopped working
#       Nextcloud immediately crashes on start, autostart isn't working either...

{ config, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.nextcloud;
in {
  options.modules.nextcloud = {
    enable = mkEnableOpt "Nextcloud Client";
    autostart = mkBoolOpt false "Autostart the Nextcloud client (systemd)";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.services.nextcloud-client.enable;
        message = "Can't enable both HM nextcloud and my nextcloud module!";
      }
    ];
    
    # I want to have nextcloud-client in the path when the module is enabled
    home.packages = with pkgs; [ nextcloud-client ];

    # TODO: Disable only for plasma
    # systemd.user.services = (mkIf cfg.autostart) {
    #   autostart-nextcloud-client = {
    #     Unit = {
    #       Description = "Nextcloud Client";
    #       PartOf = [ "graphical-session.target" ];

    #       # was graphical-session-pre.target originally in HM
    #       After = [ "graphical-session.target" "network-online.target" ];
    #     };

    #     Service = {
    #       Environment = "PATH=${config.home.profileDirectory}/bin";
    #       ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud --background";
    #     };

    #     Install.WantedBy = [ "graphical-session.target" ];
    #   };
    # };
  };
}
