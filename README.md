# NixOS Configuration

To install remove everything from ``/etc/nixos`` and symlink the ``flake.nix`` to ``/etc/nixos/flake.nix``.
Because I am dumb many obvious things are explained here and in comments inside the configuration.
This is very WIP and some parts are pretty dumb as I am still learning the NixOS ecosystem.

I heavily borrowed from:
- [hlissner](https://github.com/hlissner/dotfiles)
- [misterio77](https://github.com/Misterio77/nix-config)

# ./system

This folder contains all the system configurations.

- There is a common configuration used for all systems: ``NixFlake/nixos``
- Every system has its own special configuration: ``NixFlake/nixos/<hostname>``

When creating a NixOS configuration inside the ``NixFlake/flake.nix`` the common configuration is imported.
Because the hostname is propagated to the common configuration, it can import the host-specific config by itself.

# ./home

This folder contains all the home-manager configurations.

- There is a configuration for each user: ``NixFlake/home/<username>``
- There is a common configuration for all systems of this user: ``NixFlake/home/<username>/<hostname>``

When creating a NixOS configuration inside the ``NixFlake/flake.nix`` the common configuration is imported.
Because the hostname is propagated to the common configuration, it can import the host-specific config by itself.

# Notes

- I didn't organize the modules in folders with a ``default.nix`` for every module as this reduces readability
- Modules are split into system modules and home modules
- The ``NixFlake/overlays/default.nix`` imports all the derivations
- ``NixFlake/config`` contains all the dotfiles that are symlinked by HomeManager