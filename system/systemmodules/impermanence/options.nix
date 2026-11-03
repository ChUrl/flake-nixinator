{
  lib,
  mylib,
  config,
  username,
  ...
}: let
  user = config.users.users.${username};

  # Either a bare path ({directory = path;} plus the defaults below) or
  # {directory = "..."; mode = "..."; user = "..."; group = "...";}.
  mkDirectoryOption = {
    defaultMode,
    defaultUser,
    defaultGroup,
    description,
  }:
    lib.mkOption {
      type = lib.types.listOf (lib.types.coercedTo
        lib.types.str
        (directory: {inherit directory;})
        (lib.types.submodule {
          options = {
            directory = lib.mkOption {
              type = lib.types.str;
              description = "Path of the directory to bind mount from /persist.";
            };

            # NOTE: user/group/mode only have an effect if the directory is
            #       created by impermanence.
            mode = lib.mkOption {
              type = lib.types.str;
              default = defaultMode;
            };

            user = lib.mkOption {
              type = lib.types.str;
              default = defaultUser;
            };

            group = lib.mkOption {
              type = lib.types.str;
              default = defaultGroup;
            };
          };
        }));
      default = [];
      description = description;
      example = ''
        ["/var/lib/docker"]
      '';
    };
in {
  enable = lib.mkEnableOption "Enable opt-in state using impermanence.";

  generationRetentionDays = lib.mkOption {
    type = lib.types.ints.positive;
    default = 7;
    description = ''
      How long retired generations of the ephemeral subvolumes (root, home)
      are kept. Pruning runs from a systemd timer during normal operation,
      not from the initrd.
    '';
  };

  directories = mkDirectoryOption {
    defaultMode = "u=rwx,g=rx,o=rx";
    defaultUser = "root";
    defaultGroup = "root";
    description = ''
      System directories to persist, declared by the module that owns them.
      Paths that are needed by the impermanence setup itself stay in the
      impermanence module.
    '';
  };

  userDirectories = mkDirectoryOption {
    defaultMode = "u=rwx,g=rx,o=rx";
    defaultUser = user.name;
    defaultGroup = user.group;
    description = ''
      Directories below the user's home to persist, declared by the system
      module that owns them. Directories owned by a home-manager module are
      declared in homemodules.impermanence instead.
    '';
  };
}
