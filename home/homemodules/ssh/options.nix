{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable ssh";

  sharedHosts = mylib.modules.mkBoolOption true ''
    Add the hosts of the private infrastructure (nixinator, servenix,
    thinknix, the VPS, mars/syslab, ...) to the ssh config.
    Hosts that only reach a different set of machines disable this and define
    their own hosts, e.g. wslren with the hwaci hosts.
  '';
}
