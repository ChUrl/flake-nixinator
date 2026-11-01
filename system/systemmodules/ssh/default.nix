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
        }
        // lib.optionalAttrs (ssh.allowedUsers != []) {
          AllowUsers = ssh.allowedUsers;
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
    };
  };
}
