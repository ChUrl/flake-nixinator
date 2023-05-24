# NixOS Configuration

This is my modular NixOS configuration, using Hyprland for a lightweight desktop.

To install remove everything from ``/etc/nixos`` and symlink the ``flake.nix`` to ``/etc/nixos/flake.nix``.

## NixFlake/system

This folder contains all the system configurations.

- There is a common configuration used for all systems: ``NixFlake/system/default.nix``
- Every system has its own special configuration: ``NixFlake/system/<hostname>/default.nix``
- System modules are located in ``NixFlake/system/modules``

When creating a NixOS configuration inside the ``NixFlake/flake.nix`` the common configuration is imported.
Because the hostname is propagated to the common configuration, it can import the host-specific config by itself.

## NixFlake/home

This folder contains all the home-manager configurations.

- There is a common configuration for each user: ``NixFlake/home/<username>/default.nix``
- There is a configuration for a single system of this user: ``NixFlake/home/<username>/<hostname>/default.nix``
- Home-Manager modules are located in ``NixFlake/home/modules``

When creating a NixOS configuration inside the ``NixFlake/flake.nix`` the common configuration is imported.
Because the hostname is propagated to the common configuration, it can import the host-specific config by itself.

## NixFlake/derivations

This folder contains all the stuff I packaged.
Each derivation is loaded into ``NixFlake/derivations/default.nix``.

## NixFlake/overlays

This folder contains (not at the moment) all overlays.
The ``NixFlake/overlays/default.nix`` imports all of the overlays and all of the derivations.
It is then imported by the toplevel ``NixFlake/flake.nix``, to make everything available to the system/home configurations.

## NixFlake/docs

This folder contains automatically generated static documentation sites for my Home-Manager modules.
