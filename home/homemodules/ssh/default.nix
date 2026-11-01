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

      settings = {
        "*" = {
          ForwardAgent = false;
          AddKeysToAgent =
            if pkgs.stdenv.hostPlatform.isLinux
            then "no"
            else "yes"; # Don't have keychain on darwin
          Compression = true;
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
        };
        "nixinator" = {
          # We don't connect from nixinator to nixinator, only from the outside,
          # so the VPS ip is used as HostName
          Port = 5432;
          User = "christoph";
          HostName = "vps.chriphost.de";
        };
        "servenix" = {
          User = "christoph";
          HostName = "servenix.chriphost.de";
        };
        "thinknix" = {
          User = "christoph";
          HostName = "thinknix.chriphost.de";
        };
        "vps" = {
          User = "root";
          HostName = "vps.chriphost.de";

          # VPS Nginx Proxy Manager admin UI. The VPS binds it to
          # 127.0.0.1:51810, so tunnel it.
          LocalForward = [
            {
              bind.port = 51810;
              host.address = "127.0.0.1";
              host.port = 51810;
            }
          ];
        };
        "mars" = {
          User = "smchurla";
          HostName = "mars.cs.tu-dortmund.de";
          ServerAliveInterval = 60;
          LocalForward = [
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
