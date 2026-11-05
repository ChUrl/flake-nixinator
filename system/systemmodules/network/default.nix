# TODO: Setup Wireless (IWD/Networkd?)
{
  config,
  lib,
  mylib,
  ...
}:
with lib;
with mylib.networking;
with mylib.modules; let
  cfg = config.systemmodules.network;

  # Collect every host socket that a service on this machine binds.
  # The ports are read from where the services declare them (container
  # port mappings, vhost upstreams, nginx listeners, service options) instead
  # of declaring them a second time.

  normalizeAddress = address: let
    a = removePrefix "[" (removeSuffix "]" address);
  in
    if a == "" || a == "*" || a == "0.0.0.0" || a == "::"
    then "*"
    else a;

  mkSocket = owner: address: port: protocol: {
    inherit owner protocol;
    address = normalizeAddress address;
    port = toInt (toString port);
  };

  sameSocket = a: b:
    a.port
    == b.port
    && a.protocol == b.protocol
    && (a.address == b.address || a.address == "*" || b.address == "*");

  # Supports `--flag=value` and `--flag value`.
  getFlag = flag: args: let
    eq = filter (arg: hasPrefix "${flag}=" arg) args;
    idx = findFirst (i: elemAt args i == flag) null (genList (i: i) (length args));
  in
    if eq != []
    then removePrefix "${flag}=" (head eq)
    else if idx != null && idx + 1 < length args
    then elemAt args (idx + 1)
    else null;

  parseAddressPort = owner: spec: let
    m = match "(.+):([0-9]+)" spec;
  in
    optional (m != null) (mkSocket owner (elemAt m 0) (elemAt m 1) "tcp");

  expandPorts = spec: let
    range = match "([0-9]+)-([0-9]+)" spec;
  in
    if range != null
    then genList (i: toInt (elemAt range 0) + i) (toInt (elemAt range 1) - toInt (elemAt range 0) + 1)
    else optional (match "[0-9]+" spec != null) (toInt spec);

  # `[[ip:]hostPort:]containerPort[/proto]`; without a host port Docker picks a
  # random one, so there is nothing to check.
  parseContainerPort = owner: spec: let
    parts = splitString "/" spec;
    protocol =
      if length parts > 1
      then elemAt parts 1
      else "tcp";
    segs = splitString ":" (head parts);
  in
    if length segs < 3
    then []
    else
      map (port: mkSocket owner (concatStringsSep ":" (take (length segs - 2) segs)) port protocol)
      (expandPorts (elemAt segs (length segs - 2)));

  containers = config.virtualisation.oci-containers.containers;

  publishedSockets = concatLists (mapAttrsToList (name: container:
    concatMap (parseContainerPort "virtualisation.oci-containers.containers.${name}") (container.ports or []))
  containers);

  # Host-network containers bind the host directly; their port is in the flags
  # they already pass (e.g. cadvisor's `--port=8083 --listen_ip=127.0.0.1`).
  hostNetworkSockets = concatLists (mapAttrsToList (name: container: let
    owner = "virtualisation.oci-containers.containers.${name}";
    args = container.cmd or [];
    port = getFlag "--port" args;
    listen = getFlag "--listen_ip" args;
  in
    if any (opt: opt == "--net=host") (container.extraOptions or []) && port != null
    then [
      (mkSocket owner (
          if listen != null
          then listen
          else "*"
        )
        port "tcp")
    ]
    else [])
  containers);

  nginxSockets = optionals config.services.nginx.enable (concatLists (mapAttrsToList (name: vhost:
    map (listen: mkSocket "services.nginx.virtualHosts.${name}" listen.addr listen.port "tcp") vhost.listen)
  config.services.nginx.virtualHosts));

  caddySockets = optionals config.systemmodules.caddy.enable (let
    caddy = config.systemmodules.caddy;
  in
    optional (caddy.httpPort != null) (mkSocket "systemmodules.caddy" "*" caddy.httpPort "tcp")
    ++ optional (caddy.httpsPort != null) (mkSocket "systemmodules.caddy" "*" caddy.httpsPort "tcp")
    ++ [(mkSocket "systemmodules.caddy (admin)" "127.0.0.1" 2019 "tcp")]);

  # Ports that only exist as an option on the service that binds them.
  exporterNames = [
    "blackbox"
    "fail2ban"
    "node"
    "nvidia-gpu"
    "postgres"
    "process"
    "pve"
    "smokeping"
    "snmp"
    "systemd"
    "wireguard"
  ];

  alloyListen = let
    flag = getFlag "--server.http.listen-addr" (config.services.alloy.extraFlags or []);
  in
    if flag != null
    then flag
    else "127.0.0.1:12345";

  harvestedSockets =
    optionals config.services.postgresql.enable [
      (mkSocket "services.postgresql"
        (
          if config.services.postgresql.enableTCPIP
          then "*"
          else "127.0.0.1"
        )
        (config.services.postgresql.settings.port or 5432) "tcp")
    ]
    ++ optionals config.services.prometheus.enable [
      (mkSocket "services.prometheus" config.services.prometheus.listenAddress config.services.prometheus.port "tcp")
    ]
    ++ optionals config.services.prometheus.alertmanager.enable [
      (mkSocket "services.prometheus.alertmanager" config.services.prometheus.alertmanager.listenAddress config.services.prometheus.alertmanager.port "tcp")
      # HA cluster listener, hardcoded by the nixpkgs module
      (mkSocket "services.prometheus.alertmanager (cluster)" "*" 9094 "tcp")
    ]
    ++ concatLists (map (name: let
      exporter = config.services.prometheus.exporters.${name};
    in
      optional (exporter.enable or false) (mkSocket "services.prometheus.exporters.${name}" (exporter.listenAddress or "127.0.0.1") (exporter.port or 0) "tcp"))
    exporterNames)
    ++ optional config.services.grafana.enable (mkSocket "services.grafana"
      ((config.services.grafana.settings.server or {}).http_addr or "0.0.0.0")
      ((config.services.grafana.settings.server or {}).http_port or 3000) "tcp")
    ++ optionals config.services.loki.enable [
      (mkSocket "services.loki"
        ((config.services.loki.configuration.server or {}).http_listen_address or "0.0.0.0")
        ((config.services.loki.configuration.server or {}).http_listen_port or 3100) "tcp")
      (mkSocket "services.loki (grpc)"
        ((config.services.loki.configuration.server or {}).grpc_listen_address or "0.0.0.0")
        ((config.services.loki.configuration.server or {}).grpc_listen_port or 9096) "tcp")
    ]
    ++ optional config.services.gatus.enable (mkSocket "services.gatus"
      ((config.services.gatus.settings.web or {}).address or "0.0.0.0")
      ((config.services.gatus.settings.web or {}).port or 8080) "tcp")
    ++ optionals config.services.alloy.enable (parseAddressPort "services.alloy" alloyListen)
    ++ optionals (config.services.immich.enable && config.services.immich.machine-learning.enable) [
      (mkSocket "services.immich.machine-learning" "127.0.0.1"
        ((config.services.immich.machine-learning.environment or {}).IMMICH_PORT or "3003") "tcp")
    ]
    ++ concatLists (mapAttrsToList (name: instance:
      concatMap (parseAddressPort "services.mailpit.instances.${name}")
      (filter (spec: spec != null) [(instance.listen or null) (instance.smtp or null)]))
    config.services.mailpit.instances)
    ++ optionals config.services.openssh.enable (let
      addresses =
        if config.services.openssh.listenAddresses == []
        then ["*"]
        else config.services.openssh.listenAddresses;
    in
      concatMap (address: map (port: mkSocket "services.openssh" address port "tcp") config.services.openssh.ports) addresses)
    ++ optionals (config.services.gitea.enable && ((config.services.gitea.settings.server or {}).START_SSH_SERVER or false)) [
      (mkSocket "services.gitea (SSH)" "*" ((config.services.gitea.settings.server or {}).SSH_PORT or 22) "tcp")
    ];

  extraSockets = mapAttrsToList (name: extra:
    mkSocket "systemmodules.network.extraPorts.${name}" extra.address extra.port extra.protocol)
  cfg.extraPorts;

  # A vhost port is the port of the service behind it. It only counts when no
  # other source already claims that socket, otherwise every vhost would be
  # reported twice (once next to its container/nginx/service).
  backends = publishedSockets ++ nginxSockets ++ harvestedSockets ++ extraSockets;

  vhostSockets = optionals config.systemmodules.caddy.enable (mapAttrsToList (name: vhost:
    mkSocket "systemmodules.caddy.vhosts.${name}" "127.0.0.1" vhost.port "tcp")
  config.systemmodules.caddy.vhosts);

  sockets =
    filter (socket: socket.port > 0)
    (publishedSockets
      ++ hostNetworkSockets
      ++ nginxSockets
      ++ caddySockets
      ++ harvestedSockets
      ++ extraSockets
      ++ filter (vhost: !(any (backend: sameSocket backend vhost) backends)) vhostSockets);

  indices = genList (i: i) (length sockets);

  collisions = concatMap (i: let
    a = elemAt sockets i;
  in
    map (j: {
      inherit a;
      b = elemAt sockets j;
    })
    (filter (j: j > i && a.owner != (elemAt sockets j).owner && sameSocket a (elemAt sockets j)) indices))
  indices;

  collisionLines = mapAttrsToList (_: pairs: let
    first = (head pairs).a;
    owners = unique (concatMap (pair: [pair.a.owner pair.b.owner]) pairs);
  in "  ${toString first.port}/${first.protocol}: ${concatStringsSep ", " owners}")
  (groupBy (pair: "${pair.a.protocol}/${toString pair.a.port}") collisions);
in {
  options.systemmodules.network = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    # NetworkManager keeps its connection profiles and state here
    systemmodules.impermanence.directories = lib.optionals cfg.useNetworkManager [
      "/etc/NetworkManager"
      "/var/lib/NetworkManager"
    ];

    services.resolved = {
      enable = true;

      # llmnr = "false";
      # extraConfig = ''
      #   DNSStubListener=no
      # '';

      settings.Resolve = {
        DNS = config.networking.nameservers;
        DNSOverTLS = false;
        DNSSEC = false;
        Domains = config.networking.search;
        LLMNR = false;
        DNSStubListener = false;
      };
    };

    # Use the programs.nm-applet instead
    # environment.systemPackages = with pkgs;
    #   builtins.concatLists [
    #     []
    #     (lib.optionals cfg.useNetworkManager [networkmanagerapplet]) # This is started by hyprland if enabled
    #   ];

    programs.nm-applet.enable = cfg.useNetworkManager;

    # Main Networks
    systemd.network = {
      enable = !cfg.useNetworkManager;
      wait-online.timeout = 10;

      # Don't wait for all networks to be configured, as e.g. wg0 will only be upon manual activation
      wait-online.anyInterface = true;

      # TODO: Apparently anyInterface doesn't work?
      # wait-online.ignoredInterfaces = [
      #   "wg0"
      #   "wlp7s0"
      #   "enp5s0"
      # ];

      # networks = cfg.networks;
      inherit (cfg) networks;
    };

    systemmodules.polkit.allowedActions = mkIf cfg.useNetworkManager [
      # List NM permissions by running "nmcli general permissions"
      "org.freedesktop.NetworkManager.settings.modify.system"
    ];

    # General Networking Settings
    networking = {
      # Gets inherited from flake in nixos mylib and passed through the module option
      hostName = cfg.hostname; # Define your hostname.
      enableIPv6 = true;

      # Disable a lot of stuff not needed for systemd-networkd
      networkmanager = {
        enable = cfg.useNetworkManager;
        ensureProfiles.profiles = cfg.profiles;

        insertNameservers = [
          "192.168.86.26"
          # "8.8.8.8"
        ];

        wifi = {
          backend = "iwd";
        };
      };

      useDHCP = false; # Default: true, don't use with networkd
      dhcpcd.enable = false; # Don't use with networkd
      useNetworkd = false; # Only use this if the configuration can't be written in systemd.network completely. It translates some of the networking... options to systemd
      # resolvconf.enable = true;

      wireless = {
        enable = false; # Enables wireless support via wpa_supplicant.
        iwd.enable = true; # Use iwd instead of wpa_supplicant
      };

      # Open Ports
      nftables.enable = true;
      firewall = {
        enable = true;
        # networking.firewall.checkReversePath = "loose";

        inherit (cfg) allowedTCPPorts allowedUDPPorts;
      };
    };

    # We need this (sadly), otherwise the nfs mounts don't work
    systemd.services.NetworkManager-wait-online.enable = true;

    # Ports are declared once (container mapping, vhost, nginx listen or the
    # service's own option); two owners on the same socket is always a bug.
    assertions = optionals cfg.checkPortCollisions [
      {
        assertion = collisions == [];
        message = ''
          Multiple services bind the same socket on ${cfg.hostname}:
          ${concatStringsSep "\n" collisionLines}

          `systemmodules.network.extraPorts` exists for listeners whose port is
          not part of any other declaration.
        '';
      }
    ];
  };
}
