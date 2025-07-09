{
  pkgs,
  nixosConfig,
  config,
  lib,
  username,
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
