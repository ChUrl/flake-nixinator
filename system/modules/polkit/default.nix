{
  config,
  lib,
  mylib,
  username,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.polkit;
in {
  options.modules.polkit = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    security.polkit.enable = true;

    security.polkit.extraConfig = let
      # Stuff that should always get a rule
      always-predicates = [];

      mkServicePredicate = service: "action.lookup(\"unit\") == \"${service}\"";
      predicates = lib.pipe (cfg.allowed-system-services ++ always-predicates) [
        (builtins.map mkServicePredicate)
        (builtins.concatStringsSep " ||\n")
      ];
    in ''
      polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" && subject.user == "${username}" && (
              ${predicates}
          )) {
              return polkit.Result.YES;
          }
      });
    '';
  };
}
