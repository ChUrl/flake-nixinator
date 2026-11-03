# AGENTS.md

## Common Commands

```bash
# Enter the dev shell (provides helper utilities)
nix develop

# Preferred shorthand (nh must be enabled in config)
nh os switch   # rebuild and switch
nh os boot     # new boot entry without switching

# Direct nixos-rebuild (fallback)
sudo nixos-rebuild switch --flake .#nixinator
sudo nixos-rebuild switch --flake .#nixtop
sudo nixos-rebuild switch --flake .#servenix
sudo nixos-rebuild switch --flake .#thinknix
sudo darwin-rebuild switch --flake .#darwinix

# Validate flake without building
nix flake check

# Dev shell helpers (run inside `nix develop`)
list-system-packages   # show installed system packages
list-user-packages     # show installed user packages
store-optimise         # nix store --optimise
store-verify           # nix store --verify --repair
```

## MCP Tools

The **nixos** MCP server is available and should be used for any Nix-related lookups instead of `nix search` or manual web searches. It queries live APIs (search.nixos.org, NixHub, FlakeHub) and is more current than training data.

```
# Common intents
nix {"action":"info","query":"<pkg>","channel":"unstable"}      # package info
nix {"action":"search","query":"<term>","type":"options"}       # NixOS options
nix {"action":"search","source":"home-manager","query":"<term>"} # HM options
nix {"action":"cache","query":"<pkg>"}                          # binary cache status
nix_versions {"package":"<attr>","version":"<ver>"}             # commit that shipped a version
```

## Architecture

This is a multi-host NixOS/nix-darwin flake. Home-manager runs **as a NixOS module** — not standalone. A single `nixos-rebuild switch` rebuilds system and user config together. The HM config can access the system config via the `nixosConfig` special arg.

### Hosts

| Host | Type | Notes |
|------|------|-------|
| `nixinator` | Desktop (x86_64) | Primary machine; disko, lanzaboote, impermanence |
| `nixtop` | Laptop (x86_64) | Intel GPU, NetworkManager |
| `servenix` | Server (x86_64) | Headless; runs OCI container services |
| `thinknix` | Headless (x86_64) | Generic headless config |
| `darwinix` | macOS (aarch64) | Darwin-specific configuration |

### Config Layering (resolved in this order)

1. **Global defaults** — `system/default.nix` / `home/christoph/default.nix`
2. **Host overrides** — `system/<hostname>/default.nix` / `home/christoph/<hostname>/default.nix`
3. **Hardware** — `system/<hostname>/hardware-configuration.nix` (auto-generated, **do not hand-edit**)

The builder (`lib/nixos.nix`: `mkNixosConfigWithHomeManagerModule`) wires these together.

### Special Args

Injected into **all system and HM modules**:
`inputs` `system` `hostname` `mylib` `username` `publicKeys` `headless`

Use `headless` (boolean) to gate anything graphical. Use `mylib.<fn>` instead of reimplementing helpers.

### Module System

Three hierarchies, identical pattern:

| Scope | Path | Option prefix |
|-------|------|---------------|
| System | `system/systemmodules/<name>/` | `systemmodules.<name>.*` |
| Server services | `system/services/nixos/<name>/` | `systemmodules.<name>.*` |
| Home-manager | `home/homemodules/<name>/` | `homemodules.<name>.*` |

**System modules** — `system/systemmodules/<name>/`
- `options.nix` — declares `systemmodules.<name>.*` options
- `default.nix` — imports `./options.nix`, implements `lib.mkIf <name>.enable { ... }`

These are OS-level modules shared by all Linux hosts (boot, network, ssh, sops,
restic, docker runtime, …). Imported once via `system/systemmodules/default.nix`.

**Server services** — `system/services/nixos/<name>/`
- same two files, same `systemmodules.<name>.*` namespace (avoids colliding with
  nixpkgs' `services.*`)
- for things that run *on the servers*: `caddy`, `authelia`, and the services
  migrated away from Docker later
- imported via `system/services/nixos/default.nix`, which the NixOS builder adds
  to every host (Darwin does not get them)

**Home-manager modules** — `home/homemodules/<name>/`
- `options.nix` — declares `homemodules.<name>.*` options
- `default.nix` — same pattern under `homemodules.*`

When adding a new module, copy from `0_template/` in the matching hierarchy. Modules under `1_deprecated/` are kept for reference only — not imported anywhere.

HM modules are placed in `home-manager.sharedModules` (not `users.<user>.imports`) — this enables proper nixd completions.

### Custom Library (`lib/`)

Always available as `mylib`. Key files:
- `nixos.nix` — host config builders, `mkNixosConfigWithHomeManagerModule`, `mkDarwinConfigWithHomeManagerModule`
- `modules.nix` — `mkBoolOption`, `mkElse`, `attrName`, `attrValue`, `contains`
- `networking.nix` — `mkSystemdNetwork`, `mkStaticSystemdNetwork`
- `generators.nix` — `toLuaObject`, `toLuaKeymap` (used by Neovim module)
- `containers.nix` — OCI container helpers for services
- `color.nix` — theming

Always use `mylib.<fn>` (available as a special arg) rather than reimplementing these utilities.

### Services

Everything that runs on the servers lives under `system/services/`:

| Path | Content |
|------|---------|
| `system/services/docker/<name>.nix` | OCI container definitions (podman/docker). Each file defines one or more containers. Use the template `system/services/docker/0_TEMPLATE.nix`. |
| `system/services/nixos/<name>/` | Native NixOS service modules (see *Module System*). |

Containers are enabled per host in `system/<hostname>/default.nix`; most run on
`servenix`, a few on `thinknix`. Retired definitions live in
`system/services/docker/1_deprecated/`.

### Secrets

Managed via **sops-nix**. Age keys stored in `flake.nix` under `publicKeys.christoph`. Encrypted `.yaml`/`.json` files live alongside the module that uses them, referenced as `sops.secrets.<name>`.

Secrets are declared **where they are used**, not in a per-host list:

| Consumer | Declaration |
|----------|-------------|
| System module / service (template, env file, `.path`) | `sops.secrets."<name>" = {};` in that module (root-owned, which is enough since activation, systemd and the docker daemon read them as root) |
| Needs a different owner (e.g. `authelia`) | add `owner`/`group`/`mode` to the declaration |
| Home-manager module (the user session reads the file) | `homemodules.sops.secrets = ["<name>"];` — HM modules can't set system options, so `system/systemmodules/sops-nix` folds these in and chowns them to the user |
| Needed before users exist (e.g. `user-password`) | `systemmodules.sops-nix.bootSecrets = ["<name>"];` (sets `neededForUsers`, no owner) |

### Impermanence

`systemmodules.impermanence` binds `/persist` into the ephemeral root/home
subvolumes. Only nixinator enables it, but every module declares its own paths
so nothing is lost silently:

| Consumer | Declaration |
|----------|-------------|
| System module / service (`/var/lib/...`, `/etc/...`) | `systemmodules.impermanence.directories = ["/var/lib/docker"];` — bare strings are `0755 root:root`, or use `{ directory = "..."; mode = "u=rwx,g=,o="; }` |
| System module owning something in `$HOME` (e.g. `mime`) | `systemmodules.impermanence.userDirectories = [".local/share/mime"];` |
| Home-manager module | `homemodules.impermanence.directories = [".config/zed"];` — relative to `$HOME`, `0755` and owned by the user |
| App installed by `homemodules/packages` | add the state dirs to its `homemodules.impermanence.directories` list there |
| App installed only on one host (flatpak, Steam, `home/<host>` packages) | `homemodules.impermanence.directories` in `home/<user>/<host>/default.nix` |
| Needed by impermanence/nix/systemd itself | stays in `system/systemmodules/impermanence/default.nix` |

Changing a persisted path is data-loss sensitive: verify with
`nix eval .#nixosConfigurations.nixinator.config.environment.persistence --apply 'p: p."/persist".directories'`
(and `.users.christoph.directories`) that the set is unchanged.

### Overlays and Custom Derivations

- `overlays/default.nix` — package overrides (e.g., patched JetBrains CLion version)
- `derivations/default.nix` — custom packages: `monolisa`, `msty`, `unityhub`, `tidal-dl-ng`, `tiddl`
- `derivations/1_deprecated/` — kept for reference, not imported

### Sub-projects

`config/flake.nix` is a separate, reusable development-project template — **not part of the main NixOS flake**. It uses `flake-utils` for multi-system shells.

## Constraints

- No CI, no tests, no linting — this is a configuration repo
- `nix flake check` is the only validation available
- `documentation.enable = false` by default (slow); toggle it if you need man pages
- Hardware config files are auto-generated — never edit them by hand
