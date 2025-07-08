{
  pkgs,
  nixosConfig,
  config,
  lib,
  ...
}: {
  imports = [
    ../../modules
  ];

  config = {
    home.packages = with pkgs; [
      docker-compose
    ];

    home.stateVersion = "23.05";
  };
}
