{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) ssh color;
in {
  options.homemodules.ssh = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = true;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
        "nixinator" = {
          port = 5432;
          user = "christoph";
          hostname = "vps.chriphost.de";
        };
        "servenix" = {
          user = "christoph";
          hostname = "local.chriphost.de";
        };
        "thinknix" = {
          user = "christoph";
          hostname = "think.chriphost.de";
        };
        "vps" = {
          user = "root";
          hostname = "vps.chriphost.de";
        };
        "mars" = {
          user = "smchurla";
          hostname = "mars.cs.tu-dortmund.de";
          serverAliveInterval = 60;
          localForwards = [
            {
              # Resultbrowser
              bind.port = 22941;
              host.address = "127.0.0.1";
              host.port = 22941;
            }
            {
              # Mysql
              bind.port = 3306;
              host.address = "127.0.0.1";
              host.port = 3306;
            }
          ];
        };
      };
    };
  };
}
