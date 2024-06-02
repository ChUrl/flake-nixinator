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

    home.file.".config/neovide/config.toml".text = ''
      fork = true # Start neovide detached
      frame = "none" # full, buttonless, none
      idle = true # Don't render frames without changes
      # maximized = true
      title-hidden = true
      # vsync = true
    '';

    home.file.".config/vale/.vale.ini".text = ''
      # Core settings appear at the top
      # (the "global" section).

      [formats]
      # Format associations appear under
      # the optional "formats" section.

      [*]
      # Format-specific settings appear
      # under a user-provided "glob"
      # pattern.
    '';

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      enableMan = true;
      luaLoader.enable = true; # NOTE: Experimental
      # colorschemes.catppuccin.enable = true; # Managed using Lazy
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

      extraConfigLuaPost = builtins.readFile ./extraConfigLuaPost.lua;

      extraConfigLua = builtins.readFile ./extraConfigLua.lua;

      extraLuaPackages = with pkgs.lua51Packages; [];

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
        {
          event = ["BufWritePre"];
          callback = {__raw = "function() require('conform').format() end";};
        }
      ];

      # TODO: Toggle wrapping
      # TODO: Toggle format on save
      # TODO: Toggle format on paste
      keymaps = import ./keybinds.nix {inherit lib mylib;};

      plugins.lazy = {
        enable = true;

        plugins = builtins.concatLists [
          (import ./interface.nix {inherit lib mylib pkgs;})
          (import ./languages.nix {inherit lib mylib pkgs;})
          [
            #
            # Theme
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
            # Plugins
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
              name = "toggleterm";
              pkg = pkgs.vimPlugins.toggleterm-nvim;
              lazy = false;
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
              name = "yanky"; # TODO: Bindings
              pkg = pkgs.vimPlugins.yanky-nvim;
              lazy = false;
              config = ''
                function(_, opts)
                  require("yanky").setup(opts)
                end
              '';
            }
          ]
        ];
      };

      # NixVim plugins

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
