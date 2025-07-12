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
    modules = {
      btop.cuda = true;
    };

    home.packages = with pkgs; [
      docker-compose
    ];

    home.stateVersion = "23.05";
  };
}
