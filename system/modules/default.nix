{
  inputs,
  config,
  nixosConfig,
  lib,
  pkgs,
  mylib,
  ...
}: {
  imports = [
    ./containers
    ./polkit
    ./systemd-networkd
  ];
}
