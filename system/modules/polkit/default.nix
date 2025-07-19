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

    # NOTE: Polkit stuff:
    #       - subject.active: The subject is part of the currently active session
    #       - subject.local: The subject is spawned from a local seat/session
    #       - subject.user == ${username}: Only unlock stuff for the user defined by this config
    security.polkit.extraConfig = let
      # Services that should always get a rule
      always-services = [];

      mkServicePredicate = service: "action.lookup(\"unit\") == \"${service}\"";
      servicePredicates =
        (cfg.allowedSystemServices ++ always-services)
        |> builtins.map mkServicePredicate
        |> builtins.concatStringsSep " ||\n";

      # Actions that should always be allowed
      always-actions = [];

      mkActionPredicate = action: "action.id == \"${action}\"";
      actionPredicates =
        (cfg.allowedActions ++ always-actions)
        |> builtins.map mkActionPredicate
        |> builtins.concatStringsSep " ||\n";
    in
      lib.concatStrings [
        ''
          // NixOS PolKit Rules Start
        ''

        # Only add this ruleset if (len servicePredicates) > 0
        (lib.optionalString (builtins.lessThan 0 (builtins.length cfg.allowedSystemServices)) ''
          polkit.addRule(function(action, subject) {
            if (
              action.id == "org.freedesktop.systemd1.manage-units" &&
              subject.user == "${username}" &&
              subject.local &&
              subject.active &&
              (${servicePredicates})
            ) {
              return polkit.Result.YES;
            }
          });
        '')

        # Only add this ruleset if (len actionPredicates) > 0
        (lib.optionalString (builtins.lessThan 0 (builtins.length cfg.allowedActions)) ''
          polkit.addRule(function(action, subject) {
            if (
              subject.user == "${username}" &&
              subject.local &&
              subject.active &&
              (${actionPredicates})
            ) {
              return polkit.Result.YES;
            }
          });
        '')

        ''
          // NixOS PolKit Rules End
        ''
      ];
  };
}
