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
      agenix.secrets.${username} = [
        "heidi-discord-token"
        "kopia-password"
        "kopia-server-username"
        "kopia-server-password"
      ];
    };

    home.packages = with pkgs; [
      docker-compose
    ];

    home.stateVersion = "23.05";
  };
}
