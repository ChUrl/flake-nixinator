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

Two parallel hierarchies, identical pattern:

| Scope | Path | Option prefix |
|-------|------|---------------|
| System | `system/systemmodules/<name>/` | `systemmodules.<name>.*` |
| Home-manager | `home/homemodules/<name>/` | `homemodules.<name>.*` |

**System modules** — `system/systemmodules/<name>/`
- `options.nix` — declares `systemmodules.<name>.*` options
- `default.nix` — imports `./options.nix`, implements `lib.mkIf <name>.enable { ... }`

**Home-manager modules** — `home/homemodules/<name>/`
- `options.nix` — declares `homemodules.<name>.*` options
- `default.nix` — same pattern under `homemodules.*`

When adding a new module, copy from `0_template/` in either hierarchy. Modules under `1_deprecated/` are kept for reference only — not imported anywhere.

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

Server services are OCI containers (podman/docker) defined in `system/services/`. Each file defines one or more containers. These are only enabled on `servenix`. Use the template at `system/services/0_TEMPLATE.nix`.

### Secrets

Managed via **sops-nix**. Age keys stored in `flake.nix` under `publicKeys.christoph`. Encrypted `.yaml`/`.json` files live alongside the module that uses them, referenced as `sops.secrets.<name>`.

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
