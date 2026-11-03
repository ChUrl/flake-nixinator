{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.systemmodules) ssh;
in {
  options.systemmodules.ssh = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf ssh.enable {
    # OpenSSH host keys and fail2ban's ban database
    systemmodules.impermanence.directories =
      ["/etc/ssh"]
      ++ lib.optionals ssh.fail2ban ["/var/lib/fail2ban"];

    services.openssh = {
      enable = true;
      ports = [ssh.port];

      # Adds ssh.port to networking.firewall.allowedTCPPorts
      openFirewall = true;

      settings =
        {
          # Key-only authentication
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";

          UseDns = false;
          MaxAuthTries = 3;
          MaxSessions = 4;
          AllowAgentForwarding = false;
          X11Forwarding = false;

          # Bots sit in pre-auth until the default 120s run out, which both
          # wastes sessions and counts towards PerSourcePenalties
          # ("exceeded LoginGraceTime").
          LoginGraceTime = 20;
        }
        // lib.optionalAttrs (ssh.allowedUsers != []) {
          AllowUsers = ssh.allowedUsers;
        }
        // lib.optionalAttrs (ssh.trustedSources != []) {
          # Don't penalise hosts that proxy SSH for other clients
          PerSourcePenaltyExemptList = lib.concatStringsSep " " ssh.trustedSources;
        };
    };

    # services.fail2ban sets services.openssh.settings.LogLevel to
    # "VERBOSE" (mkDefault) and sets up the sshd jail (including
    # services.openssh.ports)
    services.fail2ban = lib.mkIf ssh.fail2ban {
      enable = true;

      maxretry = 3;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        maxtime = "48h";
      };

      # NOTE: 127.0.0.1 is always added by the module
      ignoreIP = ssh.trustedSources;
    };

    # fail2ban creates its nftables table once, at start. The nftables
    # ruleset begins with `flush ruleset`, so every reload (i.e. every
    # `nixos-rebuild switch` that touches the firewall) deletes that table and
    # bans are silently no longer enforced. Restart fail2ban whenever the
    # firewall unit changes, and reload it when the firewall is only reloaded.
    systemd.services.fail2ban = lib.mkIf ssh.fail2ban {
      after = ["nftables.service"];
      restartTriggers =
        lib.optional config.networking.nftables.enable
        config.systemd.units."nftables.service".unit;
    };

    systemd.services.nftables = lib.mkIf (ssh.fail2ban && config.networking.nftables.enable) {
      serviceConfig.ExecReload = lib.mkAfter [
        "${config.systemd.package}/bin/systemctl --no-block try-restart fail2ban.service"
      ];
    };
  };
}
