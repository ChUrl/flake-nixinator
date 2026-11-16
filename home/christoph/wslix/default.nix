# Host override for the WSL2 host.
# The non-graphical part of home/christoph/default.nix is used as-is (headless),
# so the terminal environment is the same as on the other headless hosts.
# On top of that, this host runs niri nested into WSLg (see system/wslix).
{
  lib,
  pkgs,
  ...
}: let
  rcarXosVersions = ["4.40.0"];
  rcarXosPackages = map (version: pkgs.rcar-xos.override {inherit version;}) rcarXosVersions;
  sdkRoot = p: "${p}/rcar-xos/v${p.version}";
in {
  config = {
    home.stateVersion = "26.11";

    # R-Car xOS SDK (SDK1+SDK3, Linux BSP, Poky). The archives must be in the
    # store first: nix-store --add-fixed sha512 <rcar-xos_*_v<version>_release.tar.gz>
    # Versions need an entry in derivations/rcar-xos/versions.nix, the last one
    # is the default SDKVersion in cmake-variants.yaml.
    home.packages = rcarXosPackages;

    # VS Code CMake Tools kits and variants for the installed SDK versions.
    home.file."cmake-kits.json".text = builtins.toJSON (map (p: {
        name = "Linux Poky ${p.pokyVersion} v${p.version}";
        toolchainFile = "${sdkRoot p}/cmake/toolchain_poky_${lib.replaceStrings ["."] ["_"] p.pokyVersion}.cmake";
      })
      rcarXosPackages);

    home.file."cmake-variants.yaml".source = (pkgs.formats.yaml {}).generate "cmake-variants.yaml" {
      SDKVersion = {
        default = "v${(lib.last rcarXosPackages).version}";
        choices = lib.listToAttrs (map (p: {
            name = "v${p.version}";
            value = {
              short = "v${p.version}";
              long = "v${p.version}";
              settings.rcar-xos_DIR = "${sdkRoot p}/cmake";
            };
          })
          rcarXosPackages);
      };
    };

    homemodules = {
      # Icon and cursor theme used by the niri GTK/Qt config, also only
      # installed on the non-headless hosts.
      color.installPackages = lib.mkForce true;

      # kitty is what the niri key bindings, walker and the menus spawn.
      # Terminals are otherwise only enabled on the non-headless hosts.
      kitty.enable = lib.mkForce true;

      neovim = {
        enable = lib.mkForce true;
        alias = lib.mkForce true;
        # home/homemodules/terminal defaults this to !headless.
        neovide = lib.mkForce true;
      };

      terminal.enable = lib.mkForce true;

      waybar = {
        enable = lib.mkForce true;
        monitors = ["winit"];
      };
    };

    # Enable the fontconfig setup of the user profile like on the other hosts
    # that come with a graphical session.
    fonts.fontconfig.enable = lib.mkForce true;

    programs.niri.settings = {
      # Nested inside WSLg there is exactly one output and it is called
      # "winit", so the DP-1/DP-2 layout of the desktop does not apply.
      # Note that niri swaps Mod to Alt in nested mode, because Super (Win)
      # stays with the Windows desktop.
      outputs = lib.mkForce {
        "winit" = {
          focus-at-startup = true;
        };
      };

      # The workspaces of the desktop are pinned to its two monitors; here niri
      # should just manage them dynamically.
      workspaces = lib.mkForce {};

      # The desktop also starts fcitx5 and nextcloud, which are not installed
      # on this host.
      spawn-at-startup = lib.mkForce [
        {argv = ["waypaper" "--restore"];}
        {argv = ["kitty" "--hold" "fastfetch"];}
      ];
    };

    # Unlike the other hosts, the ssh key is not provided by sops (this host has
    # no age key). Keep it at ~/.ssh/id_ed25519; programs.keychain and the git
    # commit signing from home/christoph/default.nix pick it up like everywhere
    # else. home.file.".ssh/id_ed25519{,.pub}" stay disabled on this host so
    # they don't replace it.
  };
}
