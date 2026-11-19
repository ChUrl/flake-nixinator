# Host override for the WSL2 host of the work machine.
# Everything shared with wslix lives in home/christoph/wsl; this host adds the
# Toolchains, the Claude Code MCP setup and the
# ssh hosts (it does not reach the private infrastructure).
{
  lib,
  nixosConfig,
  pkgs,
  ...
}: let
  # The last one is the default SDKVersion in cmake-variants.yaml.
  rcarXosPackages = with pkgs; [rcar-xos_v4_39_0 rcar-xos_v4_40_0];
  sdkRoot = p: "${p}/rcar-xos/v${p.version}";
in {
  imports = [../wsl];

  config = {
    # SDKs and toolchains. Nix downloads the archives
    # from Artifactory (netrc in system/wslren). Versions need an entry in
    # derivations/rcar-xos/versions.nix, rcar-xos-fetch lists the versions on
    # Artifactory and prints those entries.
    home.packages =
      rcarXosPackages
      ++ [
        # Needs the installer in the store, see derivations/qnx-software-center
        pkgs.qnx-software-center
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

    # This host only reaches the work machines, so the shared ssh hosts of
    # homemodules/ssh (nixinator, servenix, thinknix, ...) are dropped.
    homemodules.ssh.sharedHosts = lib.mkForce false;

    # Merged into the global ssh config of homemodules/ssh.
    programs.ssh.settings = {
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
  };
}
