{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  username,
  hostname,
  ...
}: let
  inherit (config.homemodules) agentic;

  # ZotLit Template Workbench skill (https://github.com/aidenlx/zotlit).
  # The repository is ~92 MB, so only the skill directory is checked out.
  zotlit = pkgs.fetchgit {
    url = "https://github.com/aidenlx/zotlit";
    rev = "91ced87644a526ea18d2a3da274a369d944e62c0";
    sparseCheckout = ["skills/zotlit-template"];
    fetchSubmodules = false; # Submodules are unrelated to the skill
    hash = "sha256-48c1bv4IwFQUyyAsLserz37e3z02GsrV/qPcUHOivb0=";
  };
in {
  options.homemodules.agentic = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf agentic.enable {
    # opencode/claude/codex write their config, cache and state here
    homemodules.impermanence.directories = [
      ".cache/opencode"
      ".cache/uv" # uvx MCP servers
      ".config/ai.opencode.desktop"
      ".config/opencode"
      ".local/share/opencode"
      ".local/state/opencode"
      ".npm" # npx MCP servers
      ".opencode"
      ".opencode-mem"
    ];

    # API keys used by the MCP servers below
    homemodules.sops.secrets = [
      "context7-api-key"
      "obsidian-rest-api-key"
    ];

    # Shared MCP servers. Every agent tool (opencode, zed, ...) picks these up
    # through its "enableMcpIntegration" option.
    programs.mcp = {
      enable = true;

      servers = {
        context7 = {
          command = "npx";
          args = ["-y" "@upstash/context7-mcp"];
          env = {
            CONTEXT7_API_KEY.file = nixosConfig.sops.secrets.context7-api-key.path;
          };
        };
        # deepwiki = {
        #   # https://mcpservers.org/servers/devin/deepwiki
        #   url = "https://mcp.deepwiki.com/mcp";
        # };
        # github = {
        #   # https://mcpservers.org/servers/github-mcp-server
        #   url = "https://api.githubcopilot.com/mcp/";
        #   headers = {
        #     Authorization = "Bearer ${input:github_mcp_pat}";
        #   };
        # };
        nixos = {
          command = "uvx";
          args = ["mcp-nixos"];
        };
        obsidian = {
          command = "uvx";
          args = ["mcp-obsidian"];
          env = {
            OBSIDIAN_API_KEY.file = nixosConfig.sops.secrets.obsidian-rest-api-key.path;
            OBSIDIAN_HOST = "127.0.0.1";
            OBSIDIAN_PORT = "27124";
          };
        };
        svelte = {
          # claude mcp add -t stdio -s [scope] svelte -- npx -y @sveltejs/mcp
          command = "npx";
          args = ["-y" "@sveltejs/mcp"];
          type = "stdio";
        };
        shadcn = {
          # npx shadcn@latest mcp init --client claude
          command = "npx";
          args = ["-y" "shadcn@latest" "mcp"];
        };
        zotero = {
          command = "uvx";
          args = ["zotero-mcp-server"];
        };
      };
    };

    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      mutableSettings = false;
      extraPackages = agentic.extraPackages;

      # Writes opencode.json
      settings = {
        plugin = [
          # "@tarquinen/opencode-dcp@3.2.0" # auto compacting # NOTE: Doesn't work with v2.0
          "opencode-mem@2.33.0"
          "@slkiser/opencode-quota@5.0.3"
          # "opencode-lmstudio@0.3.1"
          # "opencode-claude-auth@latest" # https://github.com/griffinmartin/opencode-claude-auth
        ];

        attachment = {
          image = {
            auto_resize = true;
            max_width = 2000;
            max_height = 2000;
            max_base64_bytes = 5242880;
          };
        };
        autoupdate = false;
        compaction = {
          auto = true;
          prune = true;
          reserved = 10000;
        };
        default_agent = "plan";
        enabled_providers = [
          "opencode"
          "opencode-go"
          "anthropic"
          "lmstudio"
        ];
        formatter = {
          nixfmt = {
            disabled = true;
          };
          alejandra = {
            command = ["alejandra" "$FILE"];
            extensions = [".nix"];
          };
          perltidy = {
            command = ["perltidy" "$FILE"];
            extensions = [".pl"];
          };
        };
        lsp = {
          nixd = {
            command = ["nixd"];
            extensions = [".nix"];
            initialization = {
              preferences = {
                nixd = {
                  nixpkgs = {expr = "import <nixpkgs> {}";};
                  options = {
                    nixos = {expr = "(builtins.getFlake \"/home/${username}/NixFlake\").nixosConfigurations.${hostname}.options";};
                    home-manager = {expr = "(builtins.getFlake \"/home/${username}/NixFlake\").nixosConfigurations.\"${hostname}\".options.home-manager.users.type.getSubOptions []";};
                  };
                  diagnostic = {
                    suppress = ["sema-escaping-with" "var-bind-to-this" "escaping-this-with"];
                  };
                };
              };
            };
          };
          perlnavigator = {
            command = ["perlnavigator"];
            extensions = [".pl"];
            initialization = {
              preferences = {};
            };
          };
          # perlpls = {
          #   command = ["pls"];
          #   extensions = [".pl"];
          #   initialization = {
          #     preferences = {
          #       perl = {
          #         perlcritic = {enabled = false;};
          #         syntax = {enabled = true;};
          #       };
          #     };
          #   };
          # };
          r-language-server = {
            command = ["R" "--no-echo" "-e" "languageserver::run()"];
            extensions = [".r" ".rmd" ".quarto"];
          };
        };
        permission = {
          "*" = "ask";
          "bash" = {
            "*" = "ask";
            "awk *" = "ask"; # Can modify files
            "basename *" = "allow";
            "cmp *" = "allow";
            "cut *" = "allow";
            "df *" = "allow";
            "dirname *" = "allow";
            "du *" = "allow";
            "echo *" = "allow";
            "fd *" = "ask"; # Can execute commands
            "file *" = "allow";
            "find *" = "ask"; # Can execute commands
            "grep *" = "allow";
            "head *" = "allow";
            "ls *" = "allow";
            "nl *" = "allow";
            "od *" = "allow";
            "pwd *" = "allow";
            "readlink *" = "allow";
            "rg *" = "ask"; # Can execute commands
            "sed *" = "ask"; # Can modify files
            "sha256sum *" = "allow";
            "sha512sum *" = "allow";
            "sort *" = "ask"; # Can modify files
            "stat *" = "allow";
            "tail *" = "allow";
            "test *" = "allow";
            "tr *" = "allow";
            "uniq *" = "ask"; # Can modify files
            "wc *" = "allow";
            "which *" = "allow";
            "xargs *" = "ask"; # Can modify files

            "cat *.env" = "deny";
            "cat *.env.*" = "deny";
            "cat *.env.example" = "allow";
            "printenv *" = "deny";
            "env *" = "deny";

            "nix eval *" = "allow";
            "nix flake metadata *" = "allow";
            "nix flake show *" = "allow";
            "nix path-info *" = "allow";
            "nix why-depends *" = "allow";
            "nix derivation show *" = "allow";
            "nix store ping *" = "allow";
            "nix store diff-closures *" = "allow";

            "git branch *" = "ask";
            "git check-ignore *" = "allow";
            "git diff *" = "allow";
            "git log *" = "allow";
            "git ls-files *" = "allow";
            "git ls-tree *" = "allow";
            "git remote *" = "ask";
            "git rev-list *" = "allow";
            "git rev-parse *" = "allow";
            "git stash *" = "ask";
            "git status *" = "allow";
          };
          "external_directory" = {
            "/nix/store/**" = "allow";
            "/tmp" = "allow";
            "/tmp/*" = "allow";
          };
          "read" = {
            "*" = "allow";
            "*.env" = "deny";
            "*.env.*" = "deny";
            "*.env.example" = "allow";
          };
          "grep" = "allow";
          "glob" = "allow";
          "lsp" = "allow";
          "skill" = "allow";
          "task" = "ask";
          "todowrite" = "allow";
          "webfetch" = "allow";
          "websearch" = "allow";
          "question" = "allow";
        };
        share = "disabled";
        shell = "fish";
        snapshot = false;
        watcher = {
          ignore = ["node_modules/**" "dist/**" ".git/**" ".direnv/**"];
        };
      };

      # Writes cli.json
      cli = {
        theme.name = "system";
        diff_style = "auto";
        mouse = true;
        attention = {
          enabled = true;
          notifications = true;
          sound = true;
          volume = "0.3";
        };
      };

      agents = {};
      commands = {};
      context = '''';
      skills =
        {
          zotlit-template = "${zotlit}/skills/zotlit-template";
        }
        // agentic.skills;
      tools = {};
    };
  };
}
