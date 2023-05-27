{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.polkit;
in {
  options.modules.polkit = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    security.polkit.enable = true;

    # TODO: Don't hardcode subject.user == "christoph"
    security.polkit.extraConfig = let
      # Stuff that is non-negotiable
      always-predicates = [
        # TODO: Those should be set by the VPN/networkd module
        "wg0-de-115.service"
        "wg0-lu-16.service"
      ];

      mkServicePredicate = service: "action.lookup(\"unit\") == \"${service}\"";
      predicates = lib.pipe (cfg.allowed-system-services ++ always-predicates) [
        (builtins.map mkServicePredicate)
        (builtins.concatStringsSep " ||\n")
      ];
    in ''
      polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" && subject.user == "christoph" && (
              ${predicates}
          )) {
              return polkit.Result.YES;
          }
      });
    '';
  };
}
