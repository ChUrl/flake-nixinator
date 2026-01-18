{
  pkgs,
  nixosConfig,
  config,
  lib,
  username,
  ...
}: {
  config = {
    homemodules = {
      btop.cuda = true;
    };

    home.packages = with pkgs; [
      docker-compose
    ];

    home.stateVersion = "23.05";
  };
}
