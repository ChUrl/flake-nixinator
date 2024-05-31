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
    # TODO: Configure by option
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    home.packages = with pkgs; [
      (pkgs.ripgrep.override {withPCRE2 = true;})

      # Linters
      vale

      # Formatters
      alejandra # nix
      jq # json
      html-tidy # html
    ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      enableMan = true;
      colorschemes.catppuccin.enable = true;
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
        timeoutlen = 100;
        pumheight = 0;
        formatexpr = "v:lua.require'conform'.formatexpr()";
        laststatus = 3;

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

        # Files
        encoding = "utf-8";
        fileencoding = "utf-8";
        swapfile = false;
        backup = false;
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
        autoindent = false; # Might mess up comment indentation
        smartindent = false; # Might mess up comment indentation
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

      # TODO: Use conform-nvim.formatOnSave, also make this toggleable and add a "Format" command
      # TODO: Half of the neovide config doesn't work
      extraConfigLua = ''
        local opt = vim.opt
        local g = vim.g
        local o = vim.o

        -- Neovide
        if g.neovide then
          -- Neovide options
          g.neovide_fullscreen = false
          g.neovide_hide_mouse_when_typing = false
          g.neovide_refresh_rate = 144
          -- g.neovide_cursor_vfx_mode = "ripple"
          g.neovide_cursor_animate_command_line = true
          g.neovide_cursor_animate_in_insert_mode = true
          g.neovide_cursor_vfx_particle_lifetime = 5.0
          g.neovide_cursor_vfx_particle_density = 14.0
          g.neovide_cursor_vfx_particle_speed = 12.0
          -- g.neovide_transparency = 0.8
          g.neovide_theme = 'light'

          -- Neovide Fonts
          o.guifont = "JetBrainsMono Nerd Font:h13:Medium:i"
        end
      '';

      extraLuaPackages = with pkgs.lua51Packages; [
        # lua-curl # For rest
        # xml2lua # For rest
        # mimetypes # For rest
      ];

      extraPlugins = with pkgs.vimPlugins; [
        vim-airline-themes
        nvim-web-devicons
        # nvim-nio # For rest
      ];

      keymaps = [
        # {
        #   action = "<cmd>make<CR>";
        #   key = "<C-m>";
        #   options = {
        #     silent = true;
        #   };
        # }

        # Disable arrow keys
        # {
        #   mode = ["n" "i"];
        #   key = "<Up>";
        #   action = "<Nop>";
        #   options = {
        #     silent = true;
        #     noremap = true;
        #     desc = "Disable Up arrow key";
        #   };
        # }
        # {
        #   mode = ["n" "i"];
        #   key = "<Down>";
        #   action = "<Nop>";
        #   options = {
        #     silent = true;
        #     noremap = true;
        #     desc = "Disable Down arrow key";
        #   };
        # }
        # {
        #   mode = ["n" "i"];
        #   key = "<Right>";
        #   action = "<Nop>";
        #   options = {
        #     silent = true;
        #     noremap = true;
        #     desc = "Disable Right arrow key";
        #   };
        # }
        # {
        #   mode = ["n" "i"];
        #   key = "<Left>";
        #   action = "<Nop>";
        #   options = {
        #     silent = true;
        #     noremap = true;
        #     desc = "Disable Left arrow key";
        #   };
        # }

        # No Leader
        {
          mode = "v";
          key = "<";
          action = "<gv";
          options.desc = "Outdent";
        }
        {
          mode = "v";
          key = ">";
          action = ">gv";
          options.desc = "Indent";
        }
        {
          mode = "n";
          key = "<C-d>";
          action = "<C-d>zz";
          options.desc = "Jump down";
        }
        {
          mode = "n";
          key = "<C-u>";
          action = "<C-u>zz";
          options.desc = "Jump up";
        }
        {
          mode = "n";
          key = "n";
          action = "nzzzv";
          options.desc = "Next match";
        }
        {
          mode = "n";
          key = "N";
          action = "Nzzzv";
          options.desc = "Previous match";
        }
        # { # Already included in intellitab config
        #   mode = "i";
        #   key = "<Tab>";
        #   action = "<cmd>lua require('intellitab').indent()<CR>";
        #   options.desc = "Indent";
        # }
        {
          mode = "i";
          key = "<C-BS>";
          action = "<C-w>";
          options.desc = "Delete previous word";
        }
        {
          mode = "i";
          key = "<M-BS>";
          action = "<C-w>";
          options.desc = "Delete previous word";
        }

        # General <leader>
        {
          mode = "n";
          key = "<leader>f";
          action = "<cmd>Telescope find_files<CR>";
          options.desc = "Find file";
        }
        {
          mode = "n";
          key = "<leader>u";
          action = "<cmd>Telescope undo<CR>";
          options.desc = "View undo history";
        }
        {
          mode = "n";
          key = "<leader>/";
          action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";
          options.desc = "Find in current buffer";
        }
        {
          mode = "n";
          key = "<leader>s";
          action = "<cmd>Telescope live_grep<CR>";
          options.desc = "Find in working directory";
        }
        {
          mode = "n";
          key = "<leader>d";
          action = "<cmd>Telescope diagnostics<CR>";
          options.desc = "View diagnostics";
        }
        {
          mode = "n";
          key = "<leader>?";
          action = "<cmd>Telescope keymaps<CR>";
          options.desc = "View keymaps";
        }
        {
          mode = "n";
          key = "<leader>:";
          action = "<cmd>Telescope commands<CR>";
          options.desc = "Execute command";
        }

        # Buffers <leader>b
        {
          mode = "n";
          key = "<leader>b";
          action = "+buffers";
        }
        {
          mode = "n";
          key = "<leader>bb";
          action = "<cmd>Telescope buffers<CR>";
          options.desc = "View open buffers";
        }
        {
          mode = "n";
          key = "<leader>bn";
          action = "<cmd>bnext<CR>";
          options.desc = "Goto next buffer";
        }
        {
          mode = "n";
          key = "<leader>bp";
          action = "<cmd>bprevious<CR>";
          options.desc = "Goto previous buffer";
        }
        {
          mode = "n";
          key = "<leader>bq";
          action = "<cmd>Bdelete<CR>";
          options.desc = "Close current buffer";
        }

        # Windows <leader>w
        {
          mode = "n";
          key = "<leader>w";
          action = "+windows";
        }
        {
          mode = "n";
          key = "<leader>ws";
          action = "<C-w>v";
          options.desc = "Split window vertically";
        }
        {
          mode = "n";
          key = "<leader>wq";
          action = "<C-w>c";
          options.desc = "Close current window";
        }
        # {
        #   mode = "n";
        #   key = "<leader>wh";
        #   action = "<C-W>s";
        #   options.desc = "Split window horizontally";
        # }
        {
          mode = "n";
          key = "<leader>wh";
          action = "<C-w>h";
          options.desc = "Goto left window";
        }
        {
          mode = "n";
          key = "<leader>wl";
          action = "<C-w>l";
          options.desc = "Goto right window";
        }
        {
          mode = "n";
          key = "<leader>wj";
          action = "<C-w>j";
          options.desc = "Goto bottom window";
        }
        {
          mode = "n";
          key = "<leader>wk";
          action = "<C-w>k";
          options.desc = "Goto top window";
        }
        {
          mode = "n";
          key = "<leader>ww";
          action = "<C-w>p";
          options.desc = "Goto other window";
        }

        # Toggles <leader>t
        {
          mode = "n";
          key = "<leader>t";
          action = "+toggle";
        }
        {
          mode = "n";
          key = "<leader>tt";
          action = "<cmd>Neotree toggle<CR>";
          options.desc = "Toggle NeoTree";
        }
        # {
        #   mode = "n";
        #   key = "<leader>tg";
        #   action = "<cmd>LazyGit<CR>";
        # }
        # {
        #   mode = "n";
        #   key = "<leader>tp";
        #   action = "<cmd>TroubleToggle<CR>";
        # }

        # Git <leader>g
        {
          mode = "n";
          key = "<leader>g";
          action = "+git";
        }
        {
          mode = "n";
          key = "<leader>gg";
          action = "<cmd>LazyGit<CR>";
          options.desc = "Toggle LazyGit";
        }
        {
          mode = "n";
          key = "<leader>gm";
          action = "<cmd>GitMessenger<CR>";
          options.desc = "Toggle GitMessenger";
        }
        # {
        #   mode = "n";
        #   key = "<leader>gs";
        #   action = "<cmd>Git status<CR>";
        # }
        {
          mode = "n";
          key = "<leader>gs";
          action = "<cmd>Telescope git_status<CR>";
          options.desc = "View Git status";
        }
        {
          mode = "n";
          key = "<leader>gc";
          action = "<cmd>Telescope git_commits<CR>";
          options.desc = "View Git log";
        }
        {
          mode = "n";
          key = "<leader>gb";
          action = "<cmd>Telescope git_branches<CR>";
          options.desc = "View Git branches";
        }
        {
          mode = "n";
          key = "<leader>gf";
          action = "<cmd>Telescope git_bcommits<CR>";
          options.desc = "View Git log for current file";
        }

        # Code <leader>c
        {
          mode = "n";
          key = "<leader>c";
          action = "+code";
        }
        # TODO: Autoformat https://github.com/redyf/Neve/blob/main/config/lsp/conform.nix
        {
          mode = "n";
          key = "<leader>cf";
          action = "<cmd>lua require('conform').format()<CR>";
          options.desc = "Format current buffer";
        }
      ];

      plugins = {
        # Status line, alternative to lualine
        # airline = {
        #   enable = false;
        #
        #   settings = {
        #     powerline_fonts = true;
        #     theme = "catppuccin";
        #   };
        # };

        # Auto-close parenthesis, alternative to nvim-autopairs
        # autoclose = {
        #   enable = true;
        # };

        # Alternative to bufferline
        # barbar = {
        #   enable = true;
        # };

        # Escape insert mode by pressing jk
        better-escape = {
          enable = true;
          # keys = "keys.__raw = '' function() return vim.api.nvim_win_get_cursor(0)[2] > 1 and ‘<esc>l’ or ‘<esc>’ end '';";
          mapping = ["jk"];
          timeout = 200; # In ms
        };

        # Alternative to barbar
        # bufferline = {
        #   enable = true;

        #   middleMouseCommand = "bdelete! %d";
        #   # rightMouseCommand = "BufferLineTogglePin";
        #   separatorStyle = "thin";
        # };

        # Directory tree
        # chadtree = {
        #   enable = true;
        # };

        # clangd-extensions = {
        #   enable = false;
        # };

        # Completion engine
        cmp = {
          enable = true;

          autoEnableSources = false;

          settings = {
            sources = [
              {name = "async_path";}
              {name = "emoji";}
              {name = "nvim_lsp";}
              {name = "nvim_lsp_signature_help";}
              {name = "luasnip";}
              # {name = "cmdline";}
            ];

            snippet.expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';

            window = {
              completion.border = "rounded";
              completion.winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None";
              documentation.border = "rounded";
            };

            mapping = {
              __raw = ''
                cmp.mapping.preset.insert({
                  ['<Down>'] = cmp.mapping.select_next_item(),
                  ['<Up>'] = cmp.mapping.select_prev_item(),
                  ['<C-e>'] = cmp.mapping.abort(),
                  ['<Esc>'] = cmp.mapping.abort(),
                  ['<C-Up>'] = cmp.mapping.scroll_docs(-4),
                  ['<C-Down>'] = cmp.mapping.scroll_docs(4),
                  ['<CR>'] = cmp.mapping.confirm({ select = true }),
                })
              '';
            };
          };
        };

        cmp-async-path.enable = true;
        cmp-emoji.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-nvim-lsp-signature-help.enable = true;
        cmp_luasnip.enable = true;
        # cmp-cmdline.enable = true;

        # Comment/Uncomment line/selection etc.
        comment = {
          enable = true;

          settings = {
            mappings.extra = false;
            opleader.line = "<C-c>";
            toggler.line = "<C-c>";
          };
        };

        # TODO: Setup formatters
        # File formatter in addition to LSP (uses LSP as fallback)
        conform-nvim = {
          enable = true;

          formattersByFt = {
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

          # TODO: formatOnSave = " [???] ";
        };

        # TODO: Figure out how debugging from nvim works...
        # Debug-Adapter-Protocol
        # dap = {
        #   enable = false;
        # };

        # TODO: Figure out how diff-mode works...
        # diffview = {
        #   enable = false;
        # };

        # TODO: Compare after telescope etc. are enabled
        # Changes nvim UI components, alternative to Noice
        # dressing = {
        #   enable = false;
        # };

        # Notifications + LSP progress, alternative to Noice
        # fidget = {
        #   enable = true;
        # };

        # TODO: Doesn't work
        # Search labels
        # flash = {
        #   enable = true;
        # };

        # Git client
        # fugitive = {
        #   enable = true;
        # };

        # Alternative to gitsigns
        # gitgutter = {
        #   enable = true;
        #   grep.package = (pkgs.ripgrep.override {withPCRE2 = true;});
        #   grep.command = "rg";
        # };

        # Display message of commit that modified the current line
        gitmessenger = {
          enable = true;
        };

        # Alternative to gitgutter
        gitsigns = {
          enable = true;

          settings = {
            current_line_blame = false;
          };
        };

        # Vim habit trainer, blocks keys
        # hardtime = {
        #   enable = false;
        # };

        # TODO: Maybe, don't know yet (also, telescope)
        # Mark files and jump to them
        # harpoon = {
        #   enable = false;
        # };

        # Markdown etc. heading highlights
        headlines = {
          enable = true;
        };

        # Alternative to cursorline
        illuminate = {
          enable = true;
        };

        # Live-preview of LSP renamings
        inc-rename = {
          enable = true;
        };

        # Indent to current level on empty line
        intellitab = {
          enable = true;
        };

        lazygit = {
          enable = true;
        };

        # TODO: More linters
        # Linting as addition to LSP
        lint = {
          enable = true;

          lintersByFt = {
            text = ["vale"];
            markdown = ["vale"];
          };
        };

        # TODO: More LSP servers
        # Language-Server-Protocol
        lsp = {
          enable = true;

          servers = {
            nil_ls.enable = true;
          };
        };

        # Render diagnostics as virtual line overlay
        # lsp-lines = {
        #   enable = true;
        # };

        # Statusline, alternative to airline
        lualine = {
          enable = true;

          globalstatus = true;
          sectionSeparators = {
            left = "";
            right = "";
          };
          componentSeparators = {
            left = "";
            right = "";
          };
        };

        luasnip = {
          enable = true;
        };

        # TODO: When I start actually using marks
        # Show marks in the gutter
        # marks = {
        #   enable = false;
        # };

        # Structural overview
        navbuddy = {
          enable = true;

          lsp.autoAttach = true;
        };

        # Generate doc comments
        # neogen = {
        #   enable = true;
        # };

        # TODO: When I need this
        # Interact with test frameworks
        # neotest = {
        #   enable = false;
        # };

        neo-tree = {
          enable = true;

          enableDiagnostics = true;
          enableGitStatus = true;
          enableModifiedMarkers = true;
          enableRefreshOnWrite = true;
          closeIfLastWindow = true;
          popupBorderStyle = "rounded";

          buffers = {
            bindToCwd = false;
            followCurrentFile = {
              enabled = true;
            };
          };

          window = {
            width = 40;
            height = 15;
            autoExpandWidth = false;
            mappings = {
              "<space>" = "none";
            };
          };
        };

        # NeoVim UI refresh, alternative to fidget, dressing and notify
        noice = {
          enable = true;

          lsp.override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };

          notify = {
            enabled = true;
          };

          popupmenu = {
            enabled = true;
            backend = "cmp";
          };

          routes = [
            {
              filter = {
                event = "msg_show";
                kind = "search_count";
              };
              opts = { skip = true; };
            }
          ];
        };

        # Alternative to noice.notify
        notify = {
          enable = true;
        };

        # Alternative to autoclose
        nvim-autopairs = {
          enable = true;
        };

        # Colorize color hex codes etc.
        nvim-colorizer = {
          enable = true;
        };

        # TODO: Folds the entire code at startup???
        # Code folding
        nvim-ufo = {
          enable = true;
        };

        # File system explorer that is editable like a normal buffer
        # oil = {
        #   enable = true;
        # };

        # Colorize paranthesis
        rainbow-delimiters = {
          enable = true;
        };

        # TODO: Lua deps not found
        # REST/HTTP client
        # rest = {
        #   enable = false;
        # };

        # TODO:
        # rustaceanvim = {
        #   enable = false;
        # };

        # Work with pairs of delimiters
        sandwich = {
          enable = true;
        };

        # Automatically infer tab width
        sleuth = {
          enable = true;
        };

        # TODO: Doesn't show up
        # Left-hand side status column with folding markers
        # statuscol = {
        #   enable = false;
        # };

        # Select something
        telescope = {
          enable = true;

          extensions = {
            fzf-native.enable = true;
            ui-select.enable = true;
            undo.enable = true;
          };
        };

        toggleterm = {
          enable = true;
        };

        treesitter = {
          enable = true;

          ensureInstalled = "all";
          folding = true; # TODO: Folds at startup
          indent = true; # Required by intellitab

          incrementalSelection = {
            enable = true;
          };
        };

        # Trim whitespace
        trim = {
          enable = true;
        };

        # Window listing detected linting/lsp problems
        # trouble = {
        #   enable = true;
        # };

        # Don't mess up splits when closing buffers
        vim-bbye = {
          enable = true;
        };

        # TODO: Setup
        # LaTeX
        # vimtex = {
        #   enable = true;
        #
        #   texlivePackage = null; # Don't auto-install
        # };

        # Display keybindings help
        which-key = {
          enable = true;
        };

        # TODO: Bindings
        # Clipboard enhancements (e.g. history)
        yanky = {
          enable = true;
        };
      };
    };
  };
}
