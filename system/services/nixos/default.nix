{...}: {
  # Server-side service modules: things that run on the servers, as opposed to
  # the host configuration in system/systemmodules (boot, network, ssh, …).
  #
  # They keep the `systemmodules.*` option namespace so the host config stays
  # uniform and nothing collides with nixpkgs' `services.*`.
  imports = [
    ./authelia
    ./caddy
    ./monitoring
  ];
}
