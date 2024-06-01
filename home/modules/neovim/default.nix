{
  config,
  nixosConfig,
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
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    home.packages = with pkgs;
      builtins.concatLists [
        (optionals cfg.neovide [neovide])

        [
          (pkgs.ripgrep.override {withPCRE2 = true;})

          # Linters
          clippy # rust
          checkstyle # java
          clj-kondo # clojure
          eslint_d # javascript
          python312Packages.flake8
          vale # text
          statix # nix

          # Formatters
          alejandra # nix
          google-java-format
          html-tidy
          jq # json
          prettierd # html/css/js
          # rustfmt
          # clang-tools
        ]
      ];

    # NOTE: Use nixvim.extraConfigLua configuration
    # home.file.".config/neovide/config.toml".text = ''
    #   [font]
    #     normal = ["JetBrainsMono Nerd Font Mono"] # Will use the bundled Fira Code Nerd Font by default
    #     size = 13.0
    #
    #   fork = true
    #   frame = "full" # full, buttonless, none
    #   idle = true
    #   maximized = false
    #   # neovim-bin = "/usr/bin/nvim" # in reality found dynamically on $PATH if unset
    #   no-multigrid = false
    #   srgb = false
    #   tabs = true
    #   theme = "light"
    #   title-hidden = true
    #   vsync = true
    #   wsl = false
    # '';

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      enableMan = true;
      # colorschemes.catppuccin.enable = true; # NOTE: Managed using Lazy
      viAlias = cfg.alias;
      vimAlias = cfg.alias;

      globals = {
        mapleader = " ";
        mallocalleader = " ";
      };

      opts = {
        showmode = false; # Status line already shows this
        backspace = ["indent" "eol" "start"];
        termguicolors = true; # Required by multiple plugins
        hidden = true; # Don't unload buffers immediately
        mouse = "a";
        completeopt = ["menuone" "noselect" "noinsert"];
        timeoutlen = 50;
        pumheight = 0;
        formatexpr = "v:lua.require('conform').formatexpr()";
        laststatus = 3;
        # winblend = 30;

        # Cursor
        ruler = true; # Show cursor position in status line
        number = true;
        relativenumber = true;
        signcolumn = "yes";
        cursorline = true;
        scrolloff = 10;

        # Folding
        foldcolumn = "0";
        foldlevel = 99;
        foldlevelstart = 99;
        foldenable = true;
        # foldmethod = "expr";
        # foldexpr = "nvim_treesitter#foldexpr()";

        # Files
        encoding = "utf-8";
        fileencoding = "utf-8";
        # swapfile = true;
        # backup = false;
        undofile = true;
        undodir = "/home/christoph/.vim/undo";
        # autochdir = true;

        # Search
        incsearch = true; # Already highlight results while typing
        hlsearch = true;
        ignorecase = true;
        smartcase = true;
        grepprg = "rg --vimgrep";
        grepformat = "%f:%l:%c:%m";

        # Indentation
        autoindent = false; # Use previous line indentation level - Might mess up comment indentation
        smartindent = false; # Like autoindent but recognizes some C syntax - Might mess up comment indentation
        cindent = true;
        cinkeys = "0{,0},0),0],:,!^F,o,O,e"; # Fix comment (#) indentation and intellitab (somehow)
        smarttab = true;
        expandtab = true;
        shiftwidth = 4;
        tabstop = 4;
        softtabstop = 4;

        splitbelow = true;
        splitright = true;
      };

      extraConfigLuaPost = ''
        local opt = vim.opt
        local g = vim.g
        local o = vim.o

        -- Neovide
        if g.neovide then
          -- require("notify").notify("Running in NeoVide")

          g.neovide_cursor_animate_command_line = true
          g.neovide_cursor_animate_in_insert_mode = true
          g.neovide_fullscreen = false
          g.neovide_hide_mouse_when_typing = false
          g.neovide_padding_top = 0
          g.neovide_padding_bottom = 0
          g.neovide_padding_right = 0
          g.neovide_padding_left = 0
          g.neovide_refresh_rate = 144
          g.neovide_theme = 'light'

          -- Neovide Fonts
          o.guifont = "JetBrainsMono Nerd Font:h13:Medium"
        else
          -- require("notify").notify("Not running in NeoVide")
        end
      '';

      extraConfigLua = ''
        -- Hide inline diagnostics and show border
        vim.diagnostic.config({
          virtual_text = false,
          float = { border = "rounded" }
        })

        -- Allow navigating popupmenu completion with Up/Down
        vim.api.nvim_set_keymap('c', '<Down>', 'v:lua.get_wildmenu_key("<right>", "<down>")', { expr = true })
        vim.api.nvim_set_keymap('c', '<Up>', 'v:lua.get_wildmenu_key("<left>", "<up>")', { expr = true })

        function _G.get_wildmenu_key(key_wildmenu, key_regular)
          return vim.fn.wildmenumode() ~= 0 and key_wildmenu or key_regular
        end
      '';

      extraLuaPackages = with pkgs.lua51Packages; [
        # TODO: Doesn't work
        # For rest
        # lua-curl
        # xml2lua
        # mimetypes

        jsregexp # For tree-sitter
      ];

      extraPython3Packages = p: [
        # For CHADtree
        p.pyyaml
        p.pynvim-pp
        p.std2
      ];

      autoCmd = [
        {
          event = ["BufWritePost"];
          # pattern = "*";
          callback = {__raw = "function() require('lint').try_lint() end";};
        }
      ];

      # TODO: Toggle wrapping
      # TODO: Toggle format on save
      # TODO: Toggle format on paste
      keymaps = import ./keybinds.nix {inherit lib mylib;};

      ##################################################################################################################################
      # Lazy Plugins                                                                                                                   #
      ##################################################################################################################################
      plugins.lazy = {
        enable = true;

        # TODO: Would be nicer if large dependencies could be referenced by name
        plugins = [
          #
          # Not available in NixVim
          #

          {
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
          }

          {
            name = "lspconfig";
            pkg = pkgs.vimPlugins.nvim-lspconfig;
            dependencies = [
              {
                name = "cmp";
                pkg = pkgs.vimPlugins.nvim-cmp;
                dependencies = [
                  {
                    name = "cmp-async-path";
                    pkg = pkgs.vimPlugins.cmp-async-path;
                  }
                  {
                    name = "cmp-buffer";
                    pkg = pkgs.vimPlugins.cmp-buffer;
                    enabled = false;
                  }
                  {
                    name = "cmp-cmdline";
                    pkg = pkgs.vimPlugins.cmp-cmdline;
                    enabled = false;
                  }
                  {
                    name = "cmp-emoji";
                    pkg = pkgs.vimPlugins.cmp-emoji;
                  }
                  {
                    name = "cmp-nvim-lsp";
                    pkg = pkgs.vimPlugins.cmp-nvim-lsp;
                  }
                  {
                    name = "cmp-nvim-lsp-signature-help";
                    pkg = pkgs.vimPlugins.cmp-nvim-lsp-signature-help;
                  }
                  {
                    name = "cmp-luasnip";
                    pkg = pkgs.vimPlugins.cmp_luasnip;
                  }
                ];
                lazy = false;
                config = ''
                  function(_, opts)
                    require("cmp").setup(opts)
                  end
                '';
                opts = let
                  sources = mylib.generators.toLuaObject [
                    {name = "async_path";}
                    # {name = "buffer";}
                    # {name = "cmdline";}
                    {name = "emoji";}
                    {name = "nvim_lsp";}
                    {name = "nvim_lsp_signature_help";}
                    {name = "luasnip";}
                  ];
                in {
                  __raw = ''
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

                          mapping = cmp.mapping.preset.insert({
                            ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                            ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                            ["<C-e>"] = cmp.mapping.abort();
                            ["<Esc>"] = cmp.mapping.abort();
                            ["<C-Up>"] = cmp.mapping.scroll_docs(-4),
                            ["<C-Down>"] = cmp.mapping.scroll_docs(4),
                            ["<C-Space>"] = cmp.mapping.complete({}),

                            ["<CR>"] = cmp.mapping.confirm({ select = true }),

                            ["<Tab>"] = cmp.mapping(function(fallback)
                              if cmp.visible() then
                                cmp.select_next_item()
                              elseif require("luasnip").expand_or_jumpable() then
                                require("luasnip").expand_or_jump()
                              elseif has_words_before() then
                                cmp.complete()
                              else
                                fallback()
                              end
                            end, { "i", "s" }),

                            ["<S-Tab>"] = cmp.mapping(function(fallback)
                              if cmp.visible() then
                                cmp.select_prev_item()
                              elseif luasnip.jumpable(-1) then
                                luasnip.jump(-1)
                              else
                                fallback()
                              end
                            end, { "i", "s" }),
                          }),
                        }
                      end
                  '';
                };
              }
              {
                name = "illuminate";
                pkg = pkgs.vimPlugins.vim-illuminate;
                lazy = false;
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
              }
              # {
              #   name = "inc-rename";
              #   pkg = pkgs.vimPlugins.inc-rename-nvim;
              #   config = ''
              #     function(_, opts)
              #       require("inc_rename").setup(opts)
              #     end
              #   '';
              # }
            ];
            lazy = false;
            config = let
              servers = mylib.generators.toLuaObject [
                {name = "cmake";}
                {name = "clojure_lsp";}
                {name = "clangd";}
                {name = "texlab";}
                {name = "rust_analyzer";}
                {name = "pyright";}
                {name = "nil_ls";}

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
            name = "web-devicons";
            pkg = pkgs.vimPlugins.nvim-web-devicons;
            lazy = false;
            config = ''
              function(_, opts)
                require("nvim-web-devicons").setup(opts)
              end
            '';
          }

          #
          # Also available in NixVim
          #

          {
            name = "better-escape";
            pkg = pkgs.vimPlugins.better-escape-nvim;
            lazy = false;
            config = ''
              function(_, opts)
                require("better_escape").setup(opts)
              end
            '';
            opts = {
              mapping = ["jk"];
              timeout = 200; # In ms
            };
          }

          {
            name = "chadtree";
            pkg = pkgs.vimPlugins.chadtree;
            config = ''
              function(_, opts)
                vim.api.nvim_set_var("chadtree_settings", opts)
              end
            '';
            opts = {
              theme.text_colour_set = "nerdtree_syntax_dark";
              xdg = true;
            };
          }

          {
            name = "comment";
            pkg = pkgs.vimPlugins.comment-nvim;
            dependencies = [
              {
                name = "ts-context-commentstring";
                pkg = pkgs.vimPlugins.nvim-ts-context-commentstring;
                lazy = false;
                config = ''
                  function(_, opts)
                    vim.g.skip_ts_context_commentstring_module = true -- Skip compatibility checks

                    require("ts_context_commentstring").setup(opts);
                  end
                '';
              }
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
          }

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
                markdown = [["prettierd" "prettier"]];
                nix = ["alejandra"];
                python = ["black"];
                rust = ["rustfmt"];
              };
            };
          }

          # TODO: Config
          {
            name = "flash";
            pkg = pkgs.vimPlugins.flash-nvim;
            config = ''
              function(_, opts)
                require("flash").setup(opts)
              end
            '';
          }

          {
            name = "gitmessenger";
            pkg = pkgs.vimPlugins.git-messenger-vim;
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
          }

          {
            name = "gitsigns";
            pkg = pkgs.vimPlugins.gitsigns-nvim;
            lazy = false;
            config = ''
              function(_, opts)
                require("gitsigns").setup(opts)
              end
            '';
            opts = {
              current_line_blame = false;
            };
          }

          {
            name = "headlines";
            pkg = pkgs.vimPlugins.headlines-nvim;
            config = ''
              function(_, opts)
                require("headlines").setup(opts)
              end
            '';
          }

          {
            name = "intellitab";
            pkg = pkgs.vimPlugins.intellitab-nvim;
            lazy = false;
          }

          {
            name = "lastplace";
            pkg = pkgs.vimPlugins.nvim-lastplace;
            lazy = false;
            config = ''
              function(_, opts)
                require("nvim-lastplace").setup(opts)
              end
            '';
          }

          {
            name = "lazygit";
            pkg = pkgs.vimPlugins.lazygit-nvim;
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
                markdown = ["vale"];
                nix = ["statix"];
                python = ["flake8"];
                rust = ["clippy"];
                text = ["vale"];
              };
            };
          }

          {
            name = "lualine";
            pkg = pkgs.vimPlugins.lualine-nvim;
            lazy = false;
            config = ''
              function(_, opts)
                require("lualine").setup(opts)
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
                  # left = "";
                  # right = "";
                };

                component_separators = {
                  left = "";
                  right = "";
                  # left = "";
                  # right = "";
                };
              };

              sections = {
                lualine_a = [
                  {
                    name = "mode";
                    # extraConfig = {
                    #   separator = {
                    #     left = "";
                    #   };
                    #   right_padding = "2";
                    # };
                  }
                ];
                lualine_b = ["branch" "diff" "diagnostics"];
                lualine_c = [
                  {
                    name = "filename";
                    extraConfig = {
                      path = 1;
                    };
                  }
                ];

                lualine_x = ["filetype" "encoding" "fileformat"];
                lualine_y = ["progress" "searchcount" "selectioncount"];
                lualine_z = [
                  {
                    name = "location";
                    # extraConfig = {
                    #   separator = {
                    #     right = "";
                    #   };
                    #   left_padding = "2";
                    # };
                  }
                ];
              };

              tabline = {
                lualine_a = ["buffers"];
                lualine_z = ["tabs"];
              };
            };
          }

          # TODO: Snippet configs
          {
            name = "luasnip";
            pkg = pkgs.vimPlugins.luasnip;
            config = ''
              function(_, opts)
                require("luasnip").config.set_config(opts)
              end
            '';
          }

          {
            name = "navbuddy";
            pkg = pkgs.vimPlugins.nvim-navbuddy;
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
          }

          # TODO: Doesn't show up
          {
            name = "navic";
            pkg = pkgs.vimPlugins.nvim-navic;
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
          }

          {
            name = "noice";
            pkg = pkgs.vimPlugins.noice-nvim;
            dependencies = [
              {
                name = "nui"; # For noice
                pkg = pkgs.vimPlugins.nui-nvim;
                lazy = false;
              }
            ];
            lazy = false;
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
          }

          {
            name = "notify";
            pkg = pkgs.vimPlugins.nvim-notify;
            lazy = false;
            config = ''
              function(_, opts)
                vim.notify = require("notify")
                require("notify").setup(opts)
              end
            '';
          }

          {
            name = "autopairs";
            pkg = pkgs.vimPlugins.nvim-autopairs;
            lazy = false;
            config = ''
              function(_, opts)
                require("nvim-autopairs").setup(opts)
              end
            '';
          }

          {
            name = "colorizer";
            pkg = pkgs.vimPlugins.nvim-colorizer-lua;
            lazy = false;
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
          }

          {
            name = "ufo";
            pkg = pkgs.vimPlugins.nvim-ufo;
            dependencies = [
              {
                name = "promise";
                pkg = pkgs.vimPlugins.promise-async;
              }
            ];
            config = ''
              function(_, opts)
                require("ufo").setup(opts)
              end
            '';
          }

          {
            name = "rainbow-delimiters";
            pkg = pkgs.vimPlugins.rainbow-delimiters-nvim;
            lazy = false;
          }

          {
            name = "sandwich";
            pkg = pkgs.vimPlugins.vim-sandwich;
            lazy = false;
          }

          {
            name = "sleuth";
            pkg = pkgs.vimPlugins.vim-sleuth;
            lazy = false;
          }

          {
            name = "telescope";
            pkg = pkgs.vimPlugins.telescope-nvim;
            dependencies = [
              {
                name = "plenary"; # For telescope
                pkg = pkgs.vimPlugins.plenary-nvim;
              }
              {
                name = "telescope-undo";
                pkg = pkgs.vimPlugins.telescope-undo-nvim;
              }
              {
                name = "telescope-ui-select";
                pkg = pkgs.vimPlugins.telescope-ui-select-nvim;
              }
              {
                name = "telescope-fzf-native";
                pkg = pkgs.vimPlugins.telescope-fzf-native-nvim;
              }
            ];
            lazy = false;
            config = let
              extensions = mylib.generators.toLuaObject [
                "undo"
                "ui-select"
                "fzf"
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
          }

          {
            name = "toggleterm";
            pkg = pkgs.vimPlugins.toggleterm-nvim;
            lazy = false;
            config = ''
              function(_, opts)
                require("toggleterm").setup(opts)
              end
            '';
            opts = {
              open_mapping = { __raw = "[[<C-/>]]"; };
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

          {
            name = "trim";
            pkg = pkgs.vimPlugins.trim-nvim;
            lazy = false;
            config = ''
              function(_, opts)
                require("trim").setup(opts)
              end
            '';
          }

          {
            name = "trouble";
            pkg = pkgs.vimPlugins.trouble-nvim;
            config = ''
              function(_, opts)
                require("trouble").setup(opts)
              end
            '';
          }

          {
            name = "bbye";
            pkg = pkgs.vimPlugins.vim-bbye;
          }

          {
            name = "which-key";
            pkg = pkgs.vimPlugins.which-key-nvim;
            lazy = false;
            priority = 100;
            config = ''
              function(_, opts)
                require("which-key").setup(opts)
              end
            '';
          }

          {
            name = "yanky"; # TODO: Bindings
            pkg = pkgs.vimPlugins.yanky-nvim;
            lazy = false;
            config = ''
              function(_, opts)
                require("yanky").setup(opts)
              end
            '';
          }
        ];
      };

      ##################################################################################################################################
      # NixVim Plugins                                                                                                                 #
      ##################################################################################################################################

      # TODO
      # clangd-extensions = {
      #   enable = true;
      # };

      # TODO: Figure out how debugging from nvim works...
      # Debug-Adapter-Protocol
      # dap = {
      #   enable = true;
      # };

      # TODO: Figure out how diff-mode works...
      # diffview = {
      #   enable = true;
      # };

      # TODO: Need enabled for conform fallback?
      # lsp-format = {
      #   enable = true;
      # };

      # TODO
      # Show marks in the gutter
      # marks = {
      #   enable = true;
      # };

      # TODO
      # Generate doc comments
      # neogen = {
      #   enable = true;
      # };

      # TODO
      # Interact with test frameworks
      # neotest = {
      #   enable = true;
      # };

      # TODO: Lua deps not found
      # REST/HTTP client
      # rest = {
      #   enable = true;
      # };

      # TODO: Setup
      # LaTeX
      # vimtex = {
      #   enable = true;
      #
      #   texlivePackage = null; # Don't auto-install
      # };
    };
  };
}
