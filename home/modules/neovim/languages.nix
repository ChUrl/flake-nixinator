{
  lib,
  mylib,
  pkgs,
  ...
}: [
  {
    name = "conform";
    pkg = pkgs.vimPlugins.conform-nvim;
    config = ''
      function(_, opts)
        require("conform").setup(opts)
      end
    '';
    opts = {
      formatters_by_ft = {
        c = ["clang-format"];
        h = ["clang-format"];
        cpp = ["clang-format"];
        hpp = ["clang-format"];
        css = [["prettierd" "prettier"]];
        html = [["prettierd" "prettier"]];
        java = ["google-java-format"];
        javascript = [["prettierd" "prettier"]];
        lua = ["stylua"];
        markdown = [["prettierd" "prettier"]];
        nix = ["alejandra"];
        python = ["black"];
        rust = ["rustfmt"];
      };
    };
  }

  {
    name = "lint";
    pkg = pkgs.vimPlugins.nvim-lint;
    lazy = false;
    config = ''
      function(_, opts)
        local lint = require("lint")

        for k, v in pairs(opts) do
          lint[k] = v
        end
      end
    '';
    opts = {
      linters_by_ft = {
        c = ["clang-tidy"];
        h = ["clang-tidy"];
        cpp = ["clang-tidy"];
        hpp = ["clang-tidy"];
        clojure = ["clj-kondo"];
        java = ["checkstyle"];
        javascript = ["eslint_d"];
        lua = ["luacheck"];
        markdown = ["vale"];
        nix = ["statix"];
        python = ["flake8"];
        rust = ["clippy"];
        text = ["vale"];
      };
    };
  }

  {
    name = "lspconfig";
    pkg = pkgs.vimPlugins.nvim-lspconfig;
    lazy = false;
    config = let
      servers = mylib.generators.toLuaObject [
        {name = "clangd";}
        {name = "clojure_lsp";}
        {name = "cmake";}
        {name = "lua-ls";}
        {name = "nil_ls";}
        {name = "pyright";}
        {name = "rust_analyzer";}
        {name = "texlab";}

        {
          name = "hls";
          cmd = [
            "haskell-language-server-wrapper"
            "--lsp"
          ];
        }
      ];
    in ''
      function(_, opts)
        local __lspOnAttach = function(client, bufnr) end

        local __lspCapabilities = function()
          capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
          return capabilities
        end

        local __setup = {
          on_attach = __lspOnAttach,
          capabilities = __lspCapabilities(),
        }

        for i, server in ipairs(${servers}) do
          if type(server) == "string" then
            require("lspconfig")[server].setup(__setup)
          else
            local options = server.extraOptions

            if options == nil then
              options = __setup
            else
              options = vim.tbl_extend("keep", options, __setup)
            end

            require("lspconfig")[server.name].setup(options)
          end
        end
      end
    '';
  }

  {
    name = "treesitter";
    pkg = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
    lazy = false;
    config = ''
      function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
      end
    '';
    opts = {
      highlight.enable = true;
      indent.enable = true;

      # TODO: Doesn't work
      incremental_selection = {
        enable = true;
        keymaps = {
          "init_selection" = "gnn";
          "node_decremental" = "grm";
          "node_incremental" = "grn";
          "scope_incremental" = "grc";
        };
      };
    };
  }
]
