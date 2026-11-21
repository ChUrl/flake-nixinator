{
  config,
  lib,
  pkgs,
  mylib,
  ...
}: let
  cfg = config.systemmodules.pulsesecure;
in {
  options.systemmodules.pulsesecure = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.pulsesecure];

    # Lets root own net.psecure.pulse on the system bus.
    services.dbus.packages = [pkgs.pulsesecure];

    # The client creates a TUN device for the tunnel.
    boot.kernelModules = ["tun"];

    # Neither the binaries nor their plugin configuration (access.ini) can be
    # redirected: everything is hardcoded to /opt/pulsesecure. The daemon also
    # wants write access there (it locks lib/dsOpenSSL/libcrypto.so while
    # validating it), which a read-only store path cannot provide. Keep a
    # writable copy in /var/cache and point /opt at it.
    system.activationScripts.pulsesecure = ''
      ${pkgs.coreutils}/bin/install -d -m 0755 /opt /var/cache/pulsesecure
      if [ "$(${pkgs.coreutils}/bin/cat /var/cache/pulsesecure/source 2>/dev/null)" != "${pkgs.pulsesecure}" ]; then
        ${pkgs.coreutils}/bin/rm -rf /var/cache/pulsesecure/opt
        ${pkgs.coreutils}/bin/cp -a ${pkgs.pulsesecure}/opt /var/cache/pulsesecure/opt
        ${pkgs.coreutils}/bin/chmod -R u+w /var/cache/pulsesecure/opt
        ${pkgs.coreutils}/bin/printf '%s\n' "${pkgs.pulsesecure}" \
          > /var/cache/pulsesecure/source
      fi
      ${pkgs.coreutils}/bin/ln -sfn /var/cache/pulsesecure/opt/pulsesecure /opt/pulsesecure
    '';

    # dsTMService writes its split-DNS resolver settings here. /etc is read-only
    # on NixOS, so point the path at the (persistent) state directory instead.
    environment.etc."pulse-resolv.conf".source = "/var/lib/pulsesecure/pulse-resolv.conf";

    systemd.services.pulsesecure = {
      description = "Ivanti Secure Access Service";
      documentation = ["https://www.ivanti.com/products/secure-access-client"];

      after = ["network.target"];
      wants = ["network.target"];
      wantedBy = ["multi-user.target"];

      path = with pkgs; [
        coreutils
        iproute2
        iptables
        nss.tools
        openssl
        procps
        util-linux
      ];

      serviceConfig = {
        Type = "forking";
        Restart = "always";
        RestartSec = 1;

        # Created at service start, i.e. after the impermanence bind mounts.
        # tmpfiles runs too early for these: its directories would be hidden by
        # the /var/lib/pulsesecure and /var/log/pulsesecure mounts.
        StateDirectory = "pulsesecure/pulse";
        StateDirectoryMode = "0700";
        LogsDirectory = "pulsesecure/logging";
        LogsDirectoryMode = "0755";

        ExecStartPre = [
          # A SIGKILLed instance leaves these behind; wait on them and the
          # next start silently hangs before it even opens its log.
          "${pkgs.coreutils}/bin/rm -f /run/dsAccessService.pid /dev/shm/pulsesecure_debuglog.shm /dev/shm/PulseSecure_transient.shm"
          # The deb's postinst sets these default ACLs so the unprivileged UI
          # can read what the daemon writes to the connection store.
          "${pkgs.acl}/bin/setfacl -d -m g::r,o::r /var/lib/pulsesecure/pulse"
        ];

        ExecStart = "${pkgs.pulsesecure}/opt/pulsesecure/bin/startup.sh start";
        ExecStop = "${pkgs.pulsesecure}/opt/pulsesecure/bin/startup.sh stop";

        # The tunnel service calls /sbin/ip and (for the NC protocol)
        # /sbin/ip[6]tables by absolute path.
        BindReadOnlyPaths = [
          "${pkgs.iproute2}/bin/ip:/sbin/ip"
          "${pkgs.iptables}/bin/iptables:/sbin/iptables"
          "${pkgs.iptables}/bin/iptables-restore:/sbin/iptables-restore"
          "${pkgs.iptables}/bin/ip6tables:/sbin/ip6tables"
          "${pkgs.iptables}/bin/ip6tables-restore:/sbin/ip6tables-restore"
        ];
      };
    };

    systemmodules.impermanence.directories = [
      # Connection store and certificates
      "/var/lib/pulsesecure"
      # Client logs
      "/var/log/pulsesecure"
    ];

    systemmodules.restic.servicePaths = ["/var/lib/pulsesecure"];
  };
}
