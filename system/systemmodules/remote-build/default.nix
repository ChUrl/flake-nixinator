{
  config,
  lib,
  mylib,
  ...
}: let
  cfg = config.systemmodules.remote-build;
in {
  options.systemmodules.remote-build = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf cfg.enable {
    sops.secrets."nix-builder-key" = {};

    # The builder is addressed through an alias so the non-standard sshd port
    # and the key are defined in one place (the nix daemon uses this file).
    programs.ssh = {
      extraConfig = ''
        Host ${cfg.builderAlias}
          HostName ${cfg.builderHost}
          Port ${toString cfg.builderPort}
          User ${cfg.sshUser}
          IdentityFile ${config.sops.secrets."nix-builder-key".path}
          HostKeyAlias ${cfg.builderAlias}
          IdentitiesOnly yes
          BatchMode yes
      '';

      # nixinator: ssh-keyscan -t ed25519 -p 5432 192.168.86.50
      knownHosts.${cfg.builderAlias}.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDW4Nh5aMri1hzoxOwvmEpR5L5UfG3GatL4Cl1tW15uW";
    };

    nix = {
      distributedBuilds = true;

      buildMachines = [
        {
          hostName = cfg.builderAlias;
          sshUser = cfg.sshUser;
          sshKey = config.sops.secrets."nix-builder-key".path;

          # "ssh" (not ssh-ng) so the key on the builder can be restricted to
          # `nix-store --serve --write` in authorized_keys.
          protocol = "ssh";

          system = "x86_64-linux";

          inherit
            (cfg)
            maxJobs
            speedFactor
            supportedFeatures
            ;
        }
      ];

      settings = {
        # Let the builder fetch from the upstream caches itself
        builders-use-substitutes = true;

        # Local cache first, then the public ones
        substituters = lib.mkBefore [cfg.cacheUrl];
        trusted-public-keys = [cfg.cachePublicKey];
      };
    };
  };
}
