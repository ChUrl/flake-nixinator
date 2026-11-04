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
        "opnsense" = {
          User = "christoph";
          HostName = "192.168.86.5";
        };
        "pve" = {
          User = "root";
          HostName = "192.168.86.4";
        };
        "pvf" = {
          User = "root";
          HostName = "192.168.86.13";
        };
        "synology" = {
          User = "christoph";
          HostName = "192.168.86.15";
        };
        "nixinator" = {
          # We don't connect from nixinator to itself, only from the outside:
          # jump through the VPS, because fail2ban is running there.
          # If we'd tunnel the ssh port (haproxy like before), fail2ban would
          # not work because nixinator only sees 10.10.10.1
          User = "christoph";
          HostName = "192.168.86.50";
          Port = 5432;
          ProxyJump = "hetzner";
        };
        "servenix" = {
          User = "christoph";
          HostName = "servenix.chriphost.gay";
        };
        "thinknix" = {
          User = "christoph";
          HostName = "thinknix.chriphost.gay";
        };
        # "ionos" = {
        #   # Old VPS (Fuck IONOS)
        #   User = "root";
        #   HostName = "212.227.233.241";
        # };
        "truenas" = {
          User = "truenas_admin";
          HostName = "192.168.86.20";
        };
        "hetzner" = {
          # New VPS (Hetzner)
          User = "christoph";
          HostName = "vps.chriphost.gay";
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
