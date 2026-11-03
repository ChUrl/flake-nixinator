{
  # Backed up by systemmodules/restic (DynamicUser state lives in /var/lib/private)
  systemmodules.restic.servicePaths = ["/var/lib/private/mailpit"];

  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.mailpit = {port = 8025;};

  # SMTP is published for the containers that send mail (ente), but the firewall
  # only allows it on the docker bridges, never on the LAN.
  networking.firewall.extraInputRules = ''
    iifname "br-*" tcp dport 1025 accept
  '';

  services.mailpit.instances.default = {
    database = "mailpit.db";
    max = 5000;

    # Web UI: only reachable from the host's Caddy
    listen = "127.0.0.1:8025";

    # SMTP: reachable from containers via 192.168.86.25:1025
    smtp = "0.0.0.0:1025";
  };
}
