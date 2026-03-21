# NixOS Configuration

Modular NixOS configuration, using [Niri](https://github.com/niri-wm/niri) and [Waybar](https://github.com/Alexays/Waybar) for a light desktop.

![](FastFetch.png)

To install, run `nixos-rebuild` with the `--flake` parameter from the `NixFlake` directory: `nixos-rebuild switch --flake .#nixinator`.
Alternatively, use `nh os switch` or `nh os boot`.

## NixFlake/system

Contains all the system configurations.

- There is a common configuration used for all systems: `NixFlake/system/default.nix`
- Every system has its own special configuration: `NixFlake/system/<hostname>/default.nix`
- System modules are located in `NixFlake/system/systemmodules`
- Hosted services are located in `NixFlake/system/services`

When creating a NixOS configuration inside the `NixFlake/flake.nix` the common configuration is imported.
Because the hostname is propagated to the common configuration, it can import the host-specific config by itself.

## NixFlake/home

Contains all the home-manager configurations.

- There is a common configuration for each user: `NixFlake/home/<username>/default.nix`
- There is a configuration for a single system of this user: `NixFlake/home/<username>/<hostname>/default.nix`
- Home-Manager modules are located in `NixFlake/home/homemodules`

When creating a NixOS configuration inside the `NixFlake/flake.nix` the common configuration is imported.
Because the hostname is propagated to the common configuration, it can import the host-specific config by itself.

## NixFlake/derivations

Contains all the stuff I packaged.
Each derivation is loaded into `NixFlake/derivations/default.nix`.

## NixFlake/overlays

Contains all overlays, e.g. package version overrides.
The `NixFlake/overlays/default.nix` imports all overlays and all derivations.
It is then imported by the top-level `NixFlake/flake.nix`, to make everything available to the system/home configurations.
