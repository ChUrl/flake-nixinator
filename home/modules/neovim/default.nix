{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.neovim;
in {
  options.modules.neovim = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    home = {
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      packages = with pkgs;
        builtins.concatLists [
          (optionals cfg.neovide [neovide])

          [
            (pkgs.ripgrep.override {withPCRE2 = true;})

            # Dependencies
            lua51Packages.lua-curl # For rest
            lua51Packages.xml2lua # For rest
            lua51Packages.mimetypes # For rest
            lua51Packages.jsregexp # For tree-sitter

            # Language servers
            clang-tools_18
            clojure-lsp
            cmake-language-server
            haskell-language-server
            lua-language-server
            nil
            pyright
            rust-analyzer
            texlab

            # Linters
            checkstyle # java
            clippy # rust
            clj-kondo # clojure
            eslint_d # javascript
            python311Packages.flake8
            lua51Packages.luacheck
            vale # text
            statix # nix

            # Formatters
            alejandra # nix
            python311Packages.black
            google-java-format
            html-tidy
            jq # json
            prettierd # html/css/js
            rustfmt
            stylua
          ]
        ];

      file.".config/neovide/config.toml".source = ./neovide_config.ini;
      file.".config/vale/.vale.ini".source = ./vale_config.ini;
    };

    # TODO: Read the LazyVim config for further ideas
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      enableMan = false;
      luaLoader.enable = true; # NOTE: Experimental
      viAlias = cfg.alias;
      vimAlias = cfg.alias;

      globals = {
        mapleader = " ";
        mallocalleader = " ";
      };

      opts = import ./vim_opts.nix {inherit lib mylib;};
      extraConfigLuaPost = builtins.readFile ./extraConfigLuaPost.lua;
      extraConfigLua = builtins.readFile ./extraConfigLua.lua;

      # extraLuaPackages = with pkgs.lua51Packages; [];

      # extraPython3Packages = p: [
      #   # For CHADtree
      #   p.pyyaml
      #   p.pynvim-pp
      #   p.std2
      # ];

      autoCmd = [
        {
          event = ["BufWritePost"];
          callback.__raw = ''
            function()
              if not vim.g.disable_autolint then
                require("lint").try_lint()
              end
            end
          '';
        }
        {
          event = ["TextYankPost"];
          callback.__raw = "function() vim.highlight.on_yank() end";
        }
        {
          # Resize splits when entire window is resized by wm
          event = ["VimResized"];
          callback.__raw = ''
            function()
              local current_tab = vim.fn.tabpagenr()
              vim.cmd("tabdo wincmd =")
              vim.cmd("tabnext " .. current_tab)
            end
          '';
        }
        {
          event = "FileType";
          pattern = ["json" "jsonc" "json5"]; # Disable conceal for these filetypes
          callback.__raw = "function() vim.opt_local.conceallevel = 0 end";
        }
      ];

      # TODO: Incremental selection
      keymaps = import ./keybinds.nix {inherit lib mylib;};

      plugins.lazy = {
        enable = true;

        plugins = let
          autopairs = {
            name = "autopairs";
            pkg = pkgs.vimPlugins.nvim-autopairs;
            lazy = true;
            event = ["InsertEnter"];
            config = ''
              function(_, opts)
                require("nvim-autopairs").setup(opts)
              end
            '';
            opts = {
              check_ts = true;
            };
          };

          bbye = {
            name = "bbye";
            pkg = pkgs.vimPlugins.vim-bbye;
            lazy = true;
            cmd = ["Bdelete" "Bwipeout"];
          };

          better-escape = {
            name = "better-escape";
            pkg = pkgs.vimPlugins.better-escape-nvim;
            lazy = true;
            event = ["InsertEnter"];
            config = ''
              function(_, opts)
                require("better_escape").setup(opts)
              end
            '';
            opts = {
              mapping = ["jk"];
              timeout = 200; # In ms
            };
          };

          catppuccin = {
            name = "catppuccin";
            pkg = pkgs.vimPlugins.catppuccin-nvim;
            lazy = false;
            priority = 1000;
            config = ''
              function(_, opts)
                require("catppuccin").setup(opts)

                vim.cmd([[
                  let $BAT_THEME = "catppuccin"
                  colorscheme catppuccin
                ]])
              end
            '';
            opts = {
              flavour = "mocha"; # latte, frappe, macchiato, mocha
              background = {
                light = "latte";
                dark = "mocha";
              };
            };
          };

          # chadtree = {
          #   name = "chadtree";
          #   pkg = pkgs.vimPlugins.chadtree;
          #   lazy = false;
          #   config = ''
          #     function(_, opts)
          #       vim.api.nvim_set_var("chadtree_settings", opts)
          #     end
          #   '';
          #   opts = {
          #     # theme.text_colour_set = "nerdtree_syntax_dark";
          #     theme.text_colour_set = "nord";
          #     xdg = true;
          #   };
          # };

          # NOTE: In LazyVim require("clang_extensions").setup(opts) is called where opts is the server definition from lspconfig...
          clangd-extensions = {
            name = "clangd-extensions";
            pkg = pkgs.vimPlugins.clangd_extensions-nvim;
            lazy = true;
            config = ''
              function(_, opts)
                require("clangd_extensions").setup(opts)
              end
            '';
            opts = {
              inlay_hints = {
                inline = false;
              };
            };
          };

          _cmp-async-path = {
            name = "cmp-async-path";
            pkg = pkgs.vimPlugins.cmp-async-path;
            lazy = true;
          };

          _cmp-buffer = {
            name = "cmp-buffer";
            pkg = pkgs.vimPlugins.cmp-buffer;
            lazy = true;
            enabled = false; # Spams the completion window
          };

          _cmp-cmdline = {
            name = "cmp-cmdline";
            pkg = pkgs.vimPlugins.cmp-cmdline;
            lazy = true;
            enabled = false; # Using nui as : completion backend, not cmp
          };

          _cmp-emoji = {
            name = "cmp-emoji";
            pkg = pkgs.vimPlugins.cmp-emoji;
            lazy = true;
          };

          _cmp-nvim-lsp = {
            name = "cmp-nvim-lsp";
            pkg = pkgs.vimPlugins.cmp-nvim-lsp;
            lazy = true;
          };

          _cmp-nvim-lsp-signature-help = {
            name = "cmp-nvim-lsp-signature-help";
            pkg = pkgs.vimPlugins.cmp-nvim-lsp-signature-help;
            lazy = true;
          };

          _cmp-luasnip = {
            name = "cmp-luasnip";
            pkg = pkgs.vimPlugins.cmp_luasnip;
            lazy = true;
          };

          # TODO: Check additional completion backends
          cmp = {
            name = "cmp";
            pkg = pkgs.vimPlugins.nvim-cmp;
            lazy = true;
            event = ["InsertEnter"];
            dependencies = [
              _cmp-async-path
              _cmp-buffer
              _cmp-cmdline
              _cmp-emoji
              _cmp-nvim-lsp
              _cmp-nvim-lsp-signature-help
              _cmp-luasnip
            ];
            config = ''
              function(_, opts)
                require("cmp").setup(opts)
              end
            '';
            opts.__raw = let
              sources = mylib.generators.toLuaObject [
                {name = "async_path";}
                # {name = "buffer";}
                # {name = "cmdline";}
                {name = "emoji";}
                {name = "nvim_lsp";}
                {name = "nvim_lsp_signature_help";}
                {name = "luasnip";}
              ];

              mapping = mylib.generators.toLuaObject {
                "<Down>".__raw = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })";
                "<Up>".__raw = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })";
                "<C-e>".__raw = "cmp.mapping.abort()";
                "<Esc>".__raw = "cmp.mapping.abort()";
                "<C-Up>".__raw = "cmp.mapping.scroll_docs(-4)";
                "<C-Down>".__raw = "cmp.mapping.scroll_docs(4)";
                "<C-Space>".__raw = "cmp.mapping.complete({})";
                "<CR>".__raw = "cmp.mapping.confirm({ select = true })";
                "<Tab>".__raw = ''
                  cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif require("luasnip").expand_or_jumpable() then
                      require("luasnip").expand_or_jump()
                    elseif has_words_before() then
                      cmp.complete()
                    else
                      fallback() -- This will call the intellitab <Tab> binding
                    end
                  end, { "i", "s" })
                '';
                "<S-Tab>".__raw = ''
                  cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                      luasnip.jump(-1)
                    else
                      fallback()
                    end
                  end, { "i", "s" })
                '';
              };
            in ''
              function()
                local cmp = require("cmp")
                local luasnip = require("luasnip")

                local has_words_before = function()
                  unpack = unpack or table.unpack
                  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
                end

                return {
                  sources = cmp.config.sources(${sources}),

                  snippet = {
                    expand = function(args)
                      require("luasnip").lsp_expand(args.body)
                    end,
                  },

                  window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                    -- completion.border = "rounded",
                    -- documentation.border = "rounded",
                  },

                  mapping = cmp.mapping.preset.insert(${mapping}),
                }
              end
            '';
          };

          # TODO: Only colorize html/css/scss/sass/etc.
          colorizer = {
            name = "colorizer";
            pkg = pkgs.vimPlugins.nvim-colorizer-lua;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            config = ''
              function(_, opts)
                require("colorizer").setup(opts)
              end
            '';
            opts = {
              filtetypes = null;
              user_default_options = null;
              buftypes = null;
            };
          };

          _ts-context-commentstring = {
            name = "ts-context-commentstring";
            pkg = pkgs.vimPlugins.nvim-ts-context-commentstring;
            lazy = true;
            config = ''
              function(_, opts)
                -- Skip compatibility checks
                vim.g.skip_ts_context_commentstring_module = true

                require("ts_context_commentstring").setup(opts);
              end
            '';
          };

          comment = {
            name = "comment";
            pkg = pkgs.vimPlugins.comment-nvim;
            lazy = false;
            # keys = ["<C-c>" "<C-b>"]; # NOTE: This list only works in normal mode
            dependencies = [
              _ts-context-commentstring
            ];
            config = ''
              function(_, opts)
                require("Comment").setup(opts)
              end
            '';
            opts = {
              pre_hook = {__raw = "function() require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook() end";};

              mappings.basic = true; # Apparently required for opleader/toggler config
              mappings.extra = false;
              opleader.line = "<C-c>";
              toggler.line = "<C-c>";
              opleader.block = "<C-b>";
              toggler.block = "<C-b>";
            };
          };

          conform = {
            name = "conform";
            pkg = pkgs.vimPlugins.conform-nvim;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
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

              format_on_save.__raw = ''
                function(bufnr)
                  -- Disable with a global or buffer-local variable
                  if vim.g.disable_autoformat then
                    return
                  end
                  return { timeout_ms = 500, lsp_fallback = true }
                end
              '';
            };
          };

          _persisted = {
            name = "persisted";
            pkg = pkgs.vimPlugins.persisted-nvim;
            dependencies = [telescope];
            lazy = true;
            config = ''
              function(_, opts)
                require("persisted").setup(opts)

                require("telescope").load_extension("persisted")
              end
            '';
            opts = {
              silent = false;
              use_git_branch = false;
              autosave = true;
              autoload = false;
              follow_cwd = true;
              ignored_dirs = [
                "/"
                "~/"
                "~/Projects/"
              ];
            };
          };

          # _project = {
          #   name = "project";
          #   pkg = pkgs.vimPlugins.project-nvim;
          #   dependencies = [telescope];
          #   lazy = true;
          #   config = ''
          #     function(_, opts)
          #       require("project_nvim").setup(opts)
          #     end
          #   '';
          #   opts = {
          #     manual_mode = false;
          #
          #     detection_methods = [
          #       "lsp"
          #       "pattern"
          #     ];
          #
          #     # exclude_dirs = [];
          #
          #     patterns = [
          #       ".git"
          #       "Makefile"
          #       "CMakeLists.txt"
          #       "flake.nix"
          #     ];
          #   };
          # };

          dashboard = {
            name = "dashboard";
            pkg = pkgs.vimPlugins.dashboard-nvim;
            dependencies = [
              _web-devicons
              # _persistence
              _persisted
              # _project
            ];
            lazy = false;
            config = ''
              function(_, opts)
                require("dashboard").setup(opts)
              end
            '';
            opts = {
              theme = "doom";
              disable_move = true;
              shortcut_type = "number";

              config = {
                center = [
                  # {
                  #   action = "Telescope projects";
                  #   desc = " Open Project";
                  #   icon = " ";
                  #   key = "p";
                  # }
                  {
                    action = "Telescope persisted";
                    desc = " Restore Session";
                    icon = " ";
                    key = "s";
                  }
                  {
                    action = "Telescope find_files";
                    desc = " Find File";
                    icon = " ";
                    key = "f";
                  }
                  {
                    action = "Telescope oldfiles";
                    desc = " Recent Files";
                    icon = " ";
                    key = "r";
                  }
                  {
                    action = "ene | startinsert";
                    desc = " New File";
                    icon = " ";
                    key = "n";
                  }
                  {
                    action = "Telescope live_grep";
                    desc = " Find Text";
                    icon = " ";
                    key = "g";
                  }
                  {
                    action = "Lazy";
                    desc = " Lazy";
                    icon = "󰒲 ";
                    key = "l";
                  }
                  {
                    action = "quitall";
                    desc = " Quit";
                    icon = " ";
                    key = "q";
                  }
                ];

                footer.__raw = ''
                  function()
                    local stats = require("lazy").stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
                  end,
                '';
              };
            };
          };

          diffview = {
            name = "diffview";
            pkg = pkgs.vimPlugins.diffview-nvim;
            lazy = true;
            cmd = ["DiffviewOpen"];
          };

          flash = {
            name = "flash";
            pkg = pkgs.vimPlugins.flash-nvim;
            lazy = true;
            keys = ["s" "S" "f" "F" "t" "T"];
            config = ''
              function(_, opts)
                require("flash").setup(opts)
              end
            '';
          };

          gitmessenger = {
            name = "gitmessenger";
            pkg = pkgs.vimPlugins.git-messenger-vim;
            lazy = true;
            cmd = ["GitMessenger"];
            config = ''
              function(_, opts)
                for k, v in pairs(opts) do
                  vim.g[k] = v
                end
              end
            '';
            opts = {
              git_messenger_no_default_mappings = true;
              git_messenger_floating_win_opts = {
                border = "rounded";
              };
            };
          };

          gitsigns = {
            name = "gitsigns";
            pkg = pkgs.vimPlugins.gitsigns-nvim;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            config = ''
              function(_, opts)
                require("gitsigns").setup(opts)
              end
            '';
            opts = {
              current_line_blame = false;
            };
          };

          haskell-tools = {
            name = "haskell-tools";
            pkg = pkgs.vimPlugins.haskell-tools-nvim;
            lazy = false; # Recommended by author
            # Don't call setup!
          };

          indent-blankline = {
            name = "indent-blankline";
            pkg = pkgs.vimPlugins.indent-blankline-nvim;
            lazy = false;
            config = ''
              function(_, opts)
                -- Regular setup
                require("ibl").setup(opts)

                -- Setup IBL with rainbow-delimiters
                -- local highlight = {
                --   "RainbowRed",
                --   "RainbowYellow",
                --   "RainbowBlue",
                --   "RainbowOrange",
                --   "RainbowGreen",
                --   "RainbowViolet",
                --   "RainbowCyan",
                -- }
                -- local hooks = require("ibl.hooks")

                -- -- create the highlight groups in the highlight setup hook, so they are reset
                -- -- every time the colorscheme changes
                -- hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                --   vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
                --   vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
                --   vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
                --   vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
                --   vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
                --   vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
                --   vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
                -- end)

                -- vim.g.rainbow_delimiters = { highlight = highlight }
                -- opts.scope = {highlight = highlight}

                -- Call setup function
                -- require("ibl").setup(opts)

                -- hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
              end
            '';
          };

          illuminate = {
            name = "illuminate";
            pkg = pkgs.vimPlugins.vim-illuminate;
            lazy = true;
            event = ["BufreadPost" "BufNewFile"];
            config = ''
              function(_, opts)
                require("illuminate").configure(opts)
              end
            '';
            opts = {
              filetypesDenylist = [
                "DressingSelect"
                "Outline"
                "TelescopePrompt"
                "alpha"
                "harpoon"
                "toggleterm"
                "neo-tree"
                "Spectre"
                "reason"
              ];
            };
          };

          _navic = {
            name = "navic";
            pkg = pkgs.vimPlugins.nvim-navic;
            lazy = true;
            config = ''
              function(_, opts)
                navic = require("nvim-navic")
                navic.setup(opts)

                -- NOTE: Use incline, because the default winbar isn't floating and disappears
                --       when leavin the split, which makes the buffer jump
                -- Register navic with lualine's winbar
                -- TODO: The setup function should only be ran once
                -- require("lualine").setup({
                --   winbar = {
                --     lualine_c = {
                --       {
                --         function()
                --           return navic.get_location()
                --         end,
                --         cond = function()
                --           return navic.is_available()
                --         end
                --       }
                --     }
                --   }
                -- })
              end
            '';
            opts = {
              lsp.auto_attach = true;
              click = true;
              highlight = true;
              depth_limit = 5;
            };
          };

          incline = {
            name = "incline";
            pkg = let
              nvim-incline = pkgs.vimUtils.buildVimPlugin {
                name = "nvim-incline";
                src = pkgs.fetchFromGitHub {
                  owner = "b0o";
                  repo = "incline.nvim";
                  rev = "16fc9c073e3ea4175b66ad94375df6d73fc114c0";
                  sha256 = "sha256-5DoIvIdAZV7ZgmQO2XmbM3G+nNn4tAumsShoN3rDGrs=";
                };
              };
            in
              nvim-incline;
            dependencies = [_navic];
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            config = ''
              function(_, opts)
                require("incline").setup(opts)
              end
            '';
            opts = {
              window = {
                padding = 0;
                margin = {
                  horizontal = 0;
                  vertical = 0;
                };
              };

              render.__raw = builtins.readFile ./inclineNavic.lua;
            };
          };

          intellitab = {
            name = "intellitab";
            pkg = pkgs.vimPlugins.intellitab-nvim;
            lazy = true;
            event = ["InsertEnter"];
          };

          lastplace = {
            name = "lastplace";
            pkg = pkgs.vimPlugins.nvim-lastplace;
            lazy = false;
            config = ''
              function(_, opts)
                require("nvim-lastplace").setup(opts)
              end
            '';
          };

          lazygit = {
            name = "lazygit";
            pkg = pkgs.vimPlugins.lazygit-nvim;
            dependencies = [_plenary];
            lazy = true;
            cmd = ["LazyGit" "LazyGitConfig" "LazyGitCurrentFile" "LazyGitFilter" "LazyGitFilterCurrentFile"];
          };

          lint = {
            name = "lint";
            pkg = pkgs.vimPlugins.nvim-lint;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
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
                c = ["clangtidy"];
                h = ["clangtidy"];
                cpp = ["clangtidy"];
                hpp = ["clangtidy"];
                clojure = ["clj-kondo"];
                java = ["checkstyle"];
                javascript = ["eslint_d"];
                lua = ["luacheck"];
                markdown = ["vale"];
                nix = ["statix"];
                python = ["flake8"];
                # rust = ["clippy"];
                text = ["vale"];
              };
            };
          };

          # Newer alternative to neodev
          _lazydev = {
            name = "lazydev";
            pkg = let
              nvim-lazydev = pkgs.vimUtils.buildVimPlugin {
                name = "nvim-lazydev";
                src = pkgs.fetchFromGitHub {
                  owner = "folke";
                  repo = "lazydev.nvim";
                  rev = "8146b3ad692ae7026fea1784fd5b13190d4f883c"; # v1.4
                  sha256 = "sha256-JGRjwRDx2Gdp/EBwO2XmWRGOWmHDu0XAzLps+/RSpYk=";
                };
              };
            in
              nvim-lazydev;
            ft = ["lua"];
            config = ''
              function(_, opts)
                require("lazydev").setup(opts)
              end
            '';
            # opts = {
            #   library = [
            #     "~/NixFlake/config/neovim/store"
            #   ];
            # };
          };

          # Predecessor of lazydev
          _neodev = {
            name = "neodev";
            pkg = pkgs.vimPlugins.neodev-nvim;
            lazy = false;
            config = ''
              function(_, opts)
                require("neodev").setup(opts)
              end
            '';
            opts = {
              library = {
                enabled = true;
                runtime = true;
                types = true;
                plugins = true;
              };

              setup_jsonls = false;
              lspconfig = true;
              pathStrict = true;
            };
          };

          # NOTE: This entire thing is rough, maybe I should look for another way...
          lspconfig = {
            name = "lspconfig";
            pkg = pkgs.vimPlugins.nvim-lspconfig;
            lazy = true;
            cmd = ["LspInfo"];
            event = ["BufReadPost" "BufNewFile"];
            dependencies = [
              _lazydev
              # _neodev # Has to be setup before lspconfig
            ];
            config = let
              servers = mylib.generators.toLuaObject [
                {
                  name = "clangd";
                  extraOptions = {
                    root_dir.__raw = ''
                      function(fname)
                        return require("lspconfig.util").root_pattern(
                          "Makefile",
                          "CMakeLists.txt",
                          ".clang-format",
                          ".clang-tidy"
                        )(fname) or require("lspconfig.util").root_pattern(
                          "compile_commands.json"
                        )(fname) or require("lspconfig.util").find_git_ancestor(fname)
                      end
                    '';

                    cmd = [
                      "clangd"
                      "--background-index"
                      "--clang-tidy"
                      "--header-insertion=iwyu"
                      "--completion-style=detailed"
                      "--function-arg-placeholders"
                      "--fallback-style=llvm"
                    ];

                    capabilities = {
                      offsetEncoding = ["utf-16"];
                    };

                    init_options = {
                      usePlaceholders = true;
                      completeUnimported = true;
                      clangdFileStatus = true;
                    };
                  };
                }
                {name = "clojure_lsp";}
                {name = "cmake";}
                {name = "lua_ls";}
                {name = "nil_ls";}
                {name = "pyright";}
                # {name = "rust_analyzer";} # Don't set up when using rustaceanvim
                {name = "texlab";}
                # {name = "hls";} # Don't set up when using haskell-tools
              ];
            in ''
              function(_, opts)
                -- Make LspInfo window border rounded
                require("lspconfig.ui.windows").default_options.border = "rounded"

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
          };

          lualine = {
            name = "lualine";
            pkg = pkgs.vimPlugins.lualine-nvim;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            config = ''
              function(_, opts)
                local lualine = require("lualine")

                lualine.setup(opts)

                -- Disable tabline/winbar sections
                lualine.hide({
                  place = {'tabline', 'winbar'},
                  unhide = false,
                })
              end
            '';
            opts = {
              extensions = ["fzf" "chadtree" "neo-tree" "toggleterm" "trouble"];

              options = {
                always_divide_middle = true;
                globalstatus = true;
                ignore_focus = ["neo-tree" "chadtree"];
                section_separators = {
                  left = "";
                  right = "";
                };

                component_separators = {
                  left = "";
                  right = "";
                };
              };

              sections = {
                lualine_a = ["mode"];
                lualine_b = ["branch" "diff" "diagnostics"];
                lualine_c.__raw = "{{ 'filename', path = 1, }}";

                lualine_x = ["filetype" "encoding" "fileformat"];
                lualine_y = ["progress" "searchcount" "selectioncount"];
                lualine_z = ["location"];
              };

              # tabline = {
              #   lualine_a = ["buffers"];
              #   lualine_z = ["tabs"];
              # };
            };
          };

          # TODO: Snippet configs (e.g. LaTeX)
          luasnip = {
            name = "luasnip";
            pkg = pkgs.vimPlugins.luasnip;
            lazy = false;
            config = ''
              function(_, opts)
                require("luasnip").config.set_config(opts)
              end
            '';
          };

          narrow-region = {
            name = "narrow-region";
            pkg = pkgs.vimPlugins.NrrwRgn;
            lazy = true;
            cmd = ["NR"];
            config = ''
              function(_, opts)
                vim.keymap.del("x", "<space>Nr")
                vim.keymap.del("x", "<space>nr")
                vim.keymap.del("n", "<space>nr")
              end
            '';
          };

          navbuddy = {
            name = "navbuddy";
            pkg = pkgs.vimPlugins.nvim-navbuddy;
            dependencies = [_navic];
            lazy = true;
            cmd = ["Navbuddy"];
            config = ''
              function(_, opts)
                local actions = require("nvim-navbuddy.actions") -- ?
                require("nvim-navbuddy").setup(opts)
              end
            '';
            opts = {
              lsp.auto_attach = true;
              window.border = "rounded";
            };
          };

          neo-tree = {
            name = "neo-tree";
            pkg = pkgs.vimPlugins.neo-tree-nvim;
            dependencies = [
              _plenary
              _web-devicons
              _nui
            ];
            lazy = true;
            cmd = ["Neotree"];
            config = ''
              function(_, opts)
                require("neo-tree").setup(opts)
              end
            '';
            opts = {
              use_default_mappings = false;
              popup_border_style = "rounded";
              enable_git_status = true;
              enable_diagnostics = false;
              open_files_do_not_replace_types = ["terminal" "trouble" "qf"];

              default_component_configs = {
                container = {
                  enable_character_fade = true;
                };
              };

              filesystem = {
                bind_to_cwd = true;
                cwd_target.sidebar = "global";

                filtered_items = {
                  visible = true;
                };

                follow_current_file = {
                  enabled = true;
                  leave_dirs_open = false;
                };
              };

              buffers = {
                follow_current_file = {
                  enabled = true;
                  leave_dirs_open = false;
                };
              };

              window = {
                position = "left";

                mappings = {
                  "<CR>" = "open";
                  "c" = "close_node";
                  "R" = "refresh";
                  "q" = "close_window";
                  "i" = "show_file_details";
                  "r" = "rename";
                  "d" = "delete";
                  "x" = "cut_to_clipboard";
                  "y" = "copy_to_clipboard";
                  "p" = "paste_from_clipboard";
                  "a" = "add";
                  "<Esc>" = "cancel";
                  "/" = "fuzzy_finder";
                  "?" = "show_help";
                };
              };
            };
          };

          _notify = {
            name = "notify";
            pkg = pkgs.vimPlugins.nvim-notify;
            lazy = true;
            config = ''
              function(_, opts)
                vim.notify = require("notify")
                require("notify").setup(opts)
              end
            '';
          };

          _nui = {
            name = "nui"; # For noice
            pkg = pkgs.vimPlugins.nui-nvim;
            lazy = true;
          };

          # TODO: Doesn't work
          # _inc-rename = {
          #   name = "inc-rename";
          #   pkg = pkgs.vimPlugins.inc-rename-nvim;
          #   lazy = false;
          #   cmd = ["IncRename"];
          #   config = ''
          #     function(_, opts)
          #       require("inc_rename").setup()
          #     end
          #   '';
          #   opts = {
          #     preview_empty_name = true;
          #   };
          # };

          noice = {
            name = "noice";
            pkg = pkgs.vimPlugins.noice-nvim;
            lazy = false;
            dependencies = [
              _notify
              _nui
            ];
            config = ''
              function(_, opts)
                require("noice").setup(opts)
              end
            '';
            opts = {
              presets = {
                bottom_search = false;
                command_palette = true;
                long_message_to_split = true;
                inc_rename = true;
                lsp_doc_border = true;
              };

              lsp = {
                documentation = {
                  opts = {
                    lang = "markdown";
                    replace = true;
                    render = "plain";
                    border = "rounded"; # single or rounded
                    format = ["{message}"];
                    win_options = {
                      concealcursor = "n";
                      conceallevel = 3;
                    };
                  };
                  view = "hover";
                };

                override = {
                  "vim.lsp.util.convert_input_to_markdown_lines" = true;
                  "vim.lsp.util.stylize_markdown" = true;
                  "cmp.entry.get_documentation" = true;
                };
              };

              notify = {
                enabled = true;
              };

              popupmenu = {
                enabled = true;
                backend = "nui"; # cmp completion is broken
              };

              # cmdline.enabled = false;
              # messages.enabled = false;

              routes = [
                # Hide inline search count info
                {
                  filter = {
                    event = "msg_show";
                    kind = "search_count";
                  };
                  opts = {skip = true;};
                }
              ];
            };
          };

          rainbow-delimiters = {
            name = "rainbow-delimiters";
            pkg = pkgs.vimPlugins.rainbow-delimiters-nvim;
            lazy = false;
          };

          rustaceanvim = {
            name = "rustaceanvim";
            pkg = pkgs.vimPlugins.rustaceanvim;
            lazy = false; # Recommended by author

            # Don't call setup!

            # TODO: Configure this in depth
            init = ''
              function()
                vim.g.rustaceanvim = {
                  tools = {
                    enable_clippy = true,
                  },

                  server = {
                    default_settings = {
                      ["rust-analyzer"] = {
                        cargo = {
                          allFeatures = true,
                          -- features = "all",
                          -- loadOutDirsFromCheck = true,
                          -- runBuildScripts = true,
                        },

                        -- lint-nvim doesn't support clippy
                        checkOnSave = {
                          allFeatures = true,
                          allTargets = true,
                          command = "clippy",
                          extraArgs = {
                            "--",
                            "--no-deps",
                            "-Dclippy::pedantic",
                            "-Dclippy::nursery",
                            "-Dclippy::unwrap_used",
                            "-Dclippy::enum_glob_use",
                            "-Dclippy::complexity",
                            "-Dclippy::perf",
                          },
                        },
                      },
                    },
                  },
                };
              end
            '';
          };

          sandwich = {
            name = "sandwich";
            pkg = pkgs.vimPlugins.vim-sandwich;
            lazy = false;
          };

          # TODO: Indent doesn't follow prev line correctly, don't know if sleuth issue
          sleuth = {
            name = "sleuth";
            pkg = pkgs.vimPlugins.vim-sleuth;
            lazy = false;
          };

          _plenary = {
            name = "plenary"; # For telescope
            pkg = pkgs.vimPlugins.plenary-nvim;
            lazy = true;
          };

          _telescope-fzf-native = {
            name = "telescope-fzf-native";
            pkg = pkgs.vimPlugins.telescope-fzf-native-nvim;
            lazy = true;
          };

          # TODO: Missing bat catppuccin theme
          _telescope-undo = {
            name = "telescope-undo";
            pkg = pkgs.vimPlugins.telescope-undo-nvim;
            lazy = true;
          };

          _telescope-ui-select = {
            name = "telescope-ui-select";
            pkg = pkgs.vimPlugins.telescope-ui-select-nvim;
            lazy = true;
          };

          # TODO: Check additional telescope backends
          telescope = {
            name = "telescope";
            pkg = pkgs.vimPlugins.telescope-nvim;
            lazy = true;
            cmd = ["Telescope"];
            dependencies = [
              _plenary
              _telescope-fzf-native
              _telescope-undo
              _telescope-ui-select
            ];
            config = let
              extensions = mylib.generators.toLuaObject [
                "undo"
                "ui-select"
                "fzf"
                # "lazygit"
              ];
            in ''
              function(_, opts)
                local telescope = require("telescope")
                telescope.setup(opts)

                for i, extension in ipairs(${extensions}) do
                    telescope.load_extension(extension)
                end
              end
            '';
            opts = {
              defaults = {
                mappings = {
                  i = {
                    "<Esc>" = {__raw = ''function(...) return require("telescope.actions").close(...) end'';};
                  };
                };
              };
            };
          };

          # TODO: Can't match @ for @todo etc.
          #       https://github.com/folke/todo-comments.nvim/issues/213
          #       https://github.com/folke/todo-comments.nvim/issues/56
          todo-comments = {
            name = "todo-comments";
            pkg = pkgs.vimPlugins.todo-comments-nvim;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            dependencies = [
              _plenary
            ];
            config = ''
              function(_, opts)
                require("todo-comments").setup(opts)
              end
            '';
            opts = {
              signs = true;

              keywords = {
                FIX = {
                  icon = " ";
                  color = "error";
                  alt = [
                    "FIXME"
                    "BUG"
                    "FIXIT"
                    "ISSUE"
                    # "#@fix" "#@fixme" "#@bug" "#@fixit" "#@issue"
                  ];
                  # signs = false; # Configure signs for some keywords individually
                };
                TODO = {
                  icon = " ";
                  color = "info";
                  alt = [
                    # "#@todo"
                  ];
                };
                HACK = {
                  icon = " ";
                  color = "warning";
                  alt = [
                    # "#@hack"
                  ];
                };
                WARN = {
                  icon = " ";
                  color = "warning";
                  alt = [
                    "WARNING"
                    "XXX"
                    # "#@warn" "#@warning" "#@xxx"
                  ];
                };
                PERF = {
                  icon = " ";
                  alt = [
                    "OPTIM"
                    "PERFORMANCE"
                    "OPTIMIZE"
                    # "#@perf" "#@optim" "#@performance" "#@optimize"
                  ];
                };
                NOTE = {
                  icon = " ";
                  color = "hint";
                  alt = [
                    "INFO"
                    # "#@note" "#@info"
                  ];
                };
                TEST = {
                  icon = "⏲ ";
                  color = "test";
                  alt = [
                    "TESTING"
                    "PASSED"
                    "FAILED"
                    # "#@test" "#@testing" "#@passed" "#@failed"
                  ];
                };
              };
            };
          };

          toggleterm = {
            name = "toggleterm";
            pkg = pkgs.vimPlugins.toggleterm-nvim;
            lazy = true;
            cmd = ["ToggleTerm"];
            keys = ["<C-/>"];
            config = ''
              function(_, opts)
                require("toggleterm").setup(opts)
              end
            '';
            opts = {
              open_mapping.__raw = "[[<C-/>]]";
              autochdir = true;
              hide_numbers = true;
              shade_terminals = false;
              shading_factor = 30; # Default is -30 to darken the terminal
              start_in_insert = true;
              terminal_mappings = true;
              persist_mode = true;
              insert_mappings = true;
              close_on_exit = true;
              shell = "fish";
              direction = "horizontal"; # 'vertical' | 'horizontal' | 'window' | 'float'
              auto_scroll = true;
              float_opts = {
                border = "curved"; # 'single' | 'double' | 'shadow' | 'curved'
                width = 80;
                height = 20;
                winblend = 0;
              };
            };
          };

          _treesitter-context = {
            name = "treesitter-context";
            pkg = pkgs.vimPlugins.nvim-treesitter-context;
            lazy = true;
            config = ''
              function(_, opts)
                require("treesitter-context").setup(opts)
              end
            '';
            opts = {
              max_lines = 3;
              line_numbers = false;
            };
          };

          _treesitter-refactor = {
            name = "treesitter-refactor";
            pkg = pkgs.vimPlugins.nvim-treesitter-refactor;
            lazy = true;
          };

          treesitter = let
            nvim-plugintree = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
            treesitter-parsers = pkgs.symlinkJoin {
              name = "treesitter-parsers";
              paths = nvim-plugintree.dependencies;
            };
          in {
            name = "treesitter";
            pkg = pkgs.vimPlugins.nvim-treesitter;
            dependencies = [
              # _treesitter-context # Ugly
              # _treesitter-refactor # Ugly
            ];
            lazy = true;
            cmd = ["TSModuleInfo"];
            event = ["BufReadPost" "BufNewFile"];
            config = ''
              function(_, opts)
                -- Fix treesitter grammars/parsers on nix
                vim.opt.runtimepath:append("${nvim-plugintree}")
                vim.opt.runtimepath:append("${treesitter-parsers}")

                require("nvim-treesitter.configs").setup(opts)
              end
            '';
            opts = {
              auto_install = false;
              ensure_installed = [];
              parser_install_dir = "${treesitter-parsers}";

              indent = {
                enable = true;
                # disable = ["python" "yaml"]; # NOTE: Check how bad it is
              };

              highlight = {
                enable = true;
                # disable = ["yaml"];
                additional_vim_regex_highlighting = false;
              };

              # refactor = {
              #   highlight_definitions.enable = true;
              #   highlight_current_scope.enable = false; # Ugly
              # };

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
          };

          trim = {
            name = "trim";
            pkg = pkgs.vimPlugins.trim-nvim;
            lazy = false;
            config = ''
              function(_, opts)
                require("trim").setup(opts)
              end
            '';
          };

          # TODO: Show in left pane (either neo-tree or trouble)
          trouble = {
            name = "trouble";
            pkg = pkgs.vimPlugins.trouble-nvim;
            lazy = true;
            cmd = ["Trouble" "TroubleToggle"];
            config = ''
              function(_, opts)
                require("trouble").setup(opts)
              end
            '';
          };

          twilight = {
            name = "twilight";
            pkg = pkgs.vimPlugins.twilight-nvim;
            config = ''
              function(_, opts)
                require("twilight").setup(opts)
              end
            '';
            opts = {
              dimming.alpha = 0.75;
              context = 15;
              treesitter = true;
              expand = [
                "function"
                "method"
                "table"
                "if_statement"
              ];
              # exclude = []; # Excluded filetypes
            };
          };

          _promise = {
            name = "promise";
            pkg = pkgs.vimPlugins.promise-async;
            lazy = true;
          };

          ufo = {
            name = "ufo";
            pkg = pkgs.vimPlugins.nvim-ufo;
            lazy = false;
            dependencies = [
              _promise
            ];
            config = ''
              function(_, opts)
                require("ufo").setup(opts)
              end
            '';
          };

          _web-devicons = {
            name = "web-devicons";
            pkg = pkgs.vimPlugins.nvim-web-devicons;
            lazy = true;
            config = ''
              function(_, opts)
                require("nvim-web-devicons").setup(opts)
              end
            '';
          };

          vimtex = {
            name = "vimtex";
            pkg = pkgs.vimPlugins.vimtex;
            config = ''
              function(_, opts)
                vim.g.vimtex_view_method = "zathura"
              end
            '';
          };

          which-key = {
            name = "which-key";
            pkg = pkgs.vimPlugins.which-key-nvim;
            lazy = false;
            priority = 500;
            config = ''
              function(_, opts)
                require("which-key").setup(opts)
              end
            '';
          };

          winshift = {
            name = "winshift";
            pkg = pkgs.vimPlugins.winshift-nvim;
            lazy = true;
            cmd = ["WinShift"];
            config = ''
              function(_, opts)
                require("winshift").setup(opts)
              end
            '';
            opts = {
              highlight_moving_win = true;

              keymaps = {
                disable_defaults = true;

                win_move_mode = {
                  "h" = "left";
                  "j" = "down";
                  "k" = "up";
                  "l" = "right";
                };
              };
            };
          };

          yanky = {
            name = "yanky"; # TODO: Bindings
            pkg = pkgs.vimPlugins.yanky-nvim;
            lazy = true;
            cmd = [
              "YankyClearHistory"
              "YankyRingHistory"
            ];
            config = ''
              function(_, opts)
                require("yanky").setup(opts)
              end
            '';
          };
        in [
          #
          # Theme
          #

          catppuccin
          _web-devicons

          #
          # Plugins
          #

          autopairs
          bbye
          better-escape
          # chadtree # NOTE: Using neo-tree
          clangd-extensions
          cmp
          # colorizer
          comment
          conform
          dashboard
          diffview
          flash
          gitmessenger
          gitsigns
          haskell-tools
          # indent-blankline # NOTE: Too much noise
          illuminate
          # incline # TODO: Bad styling
          intellitab
          lastplace
          lazygit
          lint
          lspconfig
          lualine
          luasnip
          narrow-region
          navbuddy
          neo-tree
          noice
          rainbow-delimiters
          rustaceanvim
          sandwich
          sleuth
          telescope
          todo-comments
          toggleterm
          treesitter
          trim
          trouble
          # twilight # NOTE: Don't like it
          ufo
          vimtex
          which-key
          winshift
          yanky
        ];
      };
    };
  };
}
