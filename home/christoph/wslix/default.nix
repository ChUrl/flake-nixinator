# Host override for the WSL2 host.
# The non-graphical part of home/christoph/default.nix is used as-is (headless),
# so the terminal environment is the same as on the other headless hosts.
# On top of that, this host runs niri nested into WSLg (see system/wslix).
{
  lib,
  nixosConfig,
  pkgs,
  ...
}: let
  rcarXosVersions = ["4.39.0" "4.40.0"];
  rcarXosPackages = map (version: pkgs.rcar-xos.override {inherit version;}) rcarXosVersions;
  sdkRoot = p: "${p}/rcar-xos/v${p.version}";
in {
  config = {
    home.stateVersion = "26.11";

    # R-Car xOS SDK (SDK1+SDK3, Linux BSP, Poky). The archives must be in the
    # store first: nix-store --add-fixed sha512 <rcar-xos_*_v<version>_release.tar.gz>
    # Versions need an entry in derivations/rcar-xos/versions.nix, the last one
    # is the default SDKVersion in cmake-variants.yaml.
    # rcar-xos-fetch downloads new versions and prints their versions.nix entries.
    home.packages =
      rcarXosPackages
      ++ [
        (pkgs.rcar-xos-fetch.override {
          tokenFile = nixosConfig.sops.secrets."artifactory-token".path;
        })
      ];

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

    # Claude Code CLI with the MCP servers of this host (the shared ones live
    # in homemodules/agentic, which is only enabled on nixinator).
    #
    # The organization's managed settings only allow MCP servers by URL
    # (allowManagedMcpServersOnly, *.renesas.com is on the list), so command
    # based servers - including the wrapper programs.mcp generates for secret
    # files - are blocked. Hence a native http server it is. The token must not
    # end up in the store: the header references ${ADMS61_AUTH}, which Claude
    # Code expands, and the wrapper exports that from the sops secret.
    programs.claude-code = {
      enable = true;

      package = pkgs.symlinkJoin {
        name = "claude-code-adms61";
        inherit (pkgs.claude-code) version meta;
        paths = [pkgs.claude-code];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/claude \
            --run 'export ADMS61_AUTH="$(cat ${nixosConfig.sops.secrets."adms61-mcp-token".path} 2>/dev/null)"'
        '';
      };

      mcpServers.adms61 = {
        type = "http";
        url = "http://boardlab.adwin.renesas.com/mcp";
        headers.Authorization = "\${ADMS61_AUTH}";
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

    # Merged into the global ssh config of homemodules/ssh.
    programs.ssh.settings = {
      "*" = {
        ServerAliveInterval = lib.mkForce 60;
        StrictHostKeyChecking = "no";
      };

      "hwaci_pc_christoph" = {
        HostName = "hsba6.adwin.renesas.com";
        Port = 10035;
        User = "christoph";
      };

      "hwaci_pc_hwaci" = {
        HostName = "hsba6.adwin.renesas.com";
        Port = 10035;
        User = "hwaci";
      };
    };

    # Unlike the other hosts, the ssh key is not provided by sops (this host has
    # no age key). Keep it at ~/.ssh/id_ed25519; programs.keychain and the git
    # commit signing from home/christoph/default.nix pick it up like everywhere
    # else. home.file.".ssh/id_ed25519{,.pub}" stay disabled on this host so
    # they don't replace it.
  };
}
