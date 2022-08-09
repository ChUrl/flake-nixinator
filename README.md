# NixFlake/nixos

This folder contains all the system configurations.

- There is a common configuration used for all systems: ``NixFlake/nixos``
- Every system has its own special configuration: ``NixFlake/nixos/<hostname>``

When creating a NixOS configuration inside the ``NixFlake/flake.nix`` the common configuration is imported.
Because the hostname is propagated to the common configuration, it can import the host-specific config by itself.

# NixFlake/home

This folder contains all the home-manager configurations.

- There is a configuration for each user: ``NixFlake/home/<username>``
- There is a common configuration for all systems of this user: ``NixFlake/home/<username>/<hostname>``

When creating a NixOS configuration inside the ``NixFlake/flake.nix`` the common configuration is imported.
Because the hostname is propagated to the common configuration, it can import the host-specific config by itself.
