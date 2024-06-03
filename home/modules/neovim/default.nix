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

      # TODO: Resize splits on window-resize
      autoCmd = [
        {
          event = ["BufWritePost"];
          callback.__raw = "function() require('lint').try_lint() end";
        }
        # Now setup directly in conform
        # {
        #   event = ["BufWritePre"];
        #   callback.__raw = "function() require('conform').format() end";
        # }
        {
          event = ["TextYankPost"];
          callback.__raw = "function() vim.highlight.on_yank() end";
        }
        {
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

      # TODO: Incremental LSP rename
      # TODO: Dashboard
      # TODO: Configure lazy-loading correctly with handlers
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

          # TODO: In LazyVim require("clang_extensions").setup(opts) is called where opts is the server definition from lspconfig...
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

          # TODO: Only colorize html/css/scss/sass...
          colorizer = {
            name = "colorizer";
            pkg = pkgs.vimPlugins.nvim-colorizer-lua;
            enabled = false;
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
            # keys = ["<C-c>" "<C-b>"]; # TODO: This list only works in normal mode
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

          # TODO: Config
          flash = {
            name = "flash";
            pkg = pkgs.vimPlugins.flash-nvim;
            lazy = false;
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

          # TODO: This entire thing is rough, maybe I should look for another way...
          lspconfig = {
            name = "lspconfig";
            pkg = pkgs.vimPlugins.nvim-lspconfig;
            lazy = true;
            cmd = ["LspInfo"];
            event = ["BufReadPost" "BufNewFile"];
            dependencies = [
              _neodev # Has to be setup before lspconfig
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
            lazy = false;
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

          # TODO: Snippet configs
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

          navbuddy = {
            name = "navbuddy";
            pkg = pkgs.vimPlugins.nvim-navbuddy;
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

          # TODO: Doesn't show up
          navic = {
            name = "navic";
            pkg = pkgs.vimPlugins.nvim-navic;
            lazy = false;
            config = ''
              function(_, opts)
                require("nvim-navic").setup(opts)
              end
            '';
            opts = {
              lsp.auto_attach = true;
              click = true;
              highlight = true;
            };
          };

          # TODO: Notification spam on filter (when searching for ignored/non-existing file)
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

              filesystem = {
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

          # TODO: Also recognize @todo etc. variants
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
          };

          toggleterm = {
            name = "toggleterm";
            pkg = pkgs.vimPlugins.toggleterm-nvim;
            lazy = true;
            cmd = ["ToggleTerm"];
            config = ''
              function(_, opts)
                require("toggleterm").setup(opts)
              end
            '';
            opts = {
              open_mapping = {__raw = "[[<C-/>]]";};
              hide_numbers = true;
              shade_terminals = true;
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

          treesitter = let
            nvim-plugintree = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
            treesitter-parsers = pkgs.symlinkJoin {
              name = "treesitter-parsers";
              paths = nvim-plugintree.dependencies;
            };
          in {
            name = "treesitter";
            pkg = pkgs.vimPlugins.nvim-treesitter;
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
          # chadtree
          clangd-extensions
          cmp
          colorizer
          comment
          conform
          flash
          gitmessenger
          gitsigns
          haskell-tools
          illuminate
          intellitab
          lastplace
          lazygit
          lint
          lspconfig
          lualine
          luasnip
          navbuddy
          navic
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
          ufo
          which-key
          yanky
        ];
      };

      # NixVim plugins

      # TODO: Figure out how debugging from nvim works...
      # Debug-Adapter-Protocol
      # dap = {
      #   enable = true;
      # };

      # TODO:
      # Dashboard
      # dashboard = {
      #   enable = true;
      # };

      # TODO: Figure out how diff-mode works...
      # diffview = {
      #   enable = true;
      # };

      # TODO: Incremental LSP rename (noice only does search/replace incrementally)
      # inc-rename = {
      #   enable = true;
      # };

      # TODO: Need enabled for conform fallback?
      # lsp-format = {
      #   enable = true;
      # };

      # TODO:
      # Show marks in the gutter
      # marks = {
      #   enable = true;
      # };

      # TODO:
      # Generate doc comments
      # neogen = {
      #   enable = true;
      # };

      # TODO:
      # Interact with test frameworks
      # neotest = {
      #   enable = true;
      # };

      # TODO: Lua deps not found
      # REST/HTTP client
      # rest = {
      #   enable = true;
      # };

      # TODO:
      # LaTeX
      # vimtex = {
      #   enable = true;
      #
      #   texlivePackage = null; # Don't auto-install
      # };
    };
  };
}
