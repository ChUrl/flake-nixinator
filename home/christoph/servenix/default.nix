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

    programs = {
      btop.package = pkgs.btop-cuda;
    };

    home.stateVersion = "23.05";
  };
}
