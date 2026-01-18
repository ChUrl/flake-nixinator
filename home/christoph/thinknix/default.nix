{
  pkgs,
  nixosConfig,
  config,
  lib,
  username,
  ...
}: {
  config = {
    home.packages = with pkgs; [
      docker-compose
    ];

    home.stateVersion = "23.05";
  };
}
