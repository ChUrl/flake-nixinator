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
    # home.sessionVariables = {
    #   EDITOR = "nvim";
    #   VISUAL = "nvim";
    # };

    home.packages = with pkgs; [
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

      opts = {
        ruler = true; # Show cursor position in status line
        number = true;
        relativenumber = false;
        showmode = false; # Status line already shows this
        backspace = ["indent" "eol" "start"];
        undofile = true;
        undodir = "~/.vim/undo";
        encoding = "utf-8";

        # TODO: Move neovide config to this module
        # printfont = "JetBrainsMono Nerd Font Mono:h10";
        # guifont = "JetBrainsMono Nerd Font Mono:h12";

        # Search
        incsearch = true; # Already highlight results while typing
        hlsearch = true;
        ignorecase = true;
        laststatus = 2;
        hidden = true; # Don't unload buffers immediately

        # Indentation
        autoindent = true;
        expandtab = true;
        smartindent = true;
        smarttab = true;
        shiftwidth = 4;
        softtabstop = 4;

        termguicolors = true; # For bufferline
      };

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

      plugins = {
        # TODO: Fix the terribly ugly right side with the line numbers etc.
        # Status line, alternative to lualine
        airline = {
          enable = false;

          settings = {
            powerline_fonts = true;
            theme = "catppuccin";
          };
        };

        # Auto-close parenthesis, alternative to nvim-autopairs
        autoclose = {
          enable = true;
        };

        # TODO: Remove once I have telescope
        # Alternative to bufferline
        barbar = {
          enable = true;
        };

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
        chadtree = {
          enable = true;
        };

        # TODO: Requires LSP
        clangd-extensions = {
          enable = false;
        };

        # Completion engine
        cmp = {
          enable = true;

          settings = {
            sources = [
              { name = "async_path"; }
              { name = "emoji"; }
              { name = "nvim_lsp"; }
              { name = "nvim_lsp_signature_help"; }
            ];
          };
        };

        # TODO: Add snippet engine completion
        cmp-async-path.enable = true;
        cmp-emoji.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-nvim-lsp-signature-help.enable = true;

        # Comment/Uncomment line/selection etc.
        comment = {
          enable = true;
        };

        # TODO: Setup formatters
        # File formatter in addition to LSP (uses LSP as fallback)
        conform-nvim = {
          enable = true;

          formattersByFt = {
            nix = [ "alejandra" ];
          };

          # TODO: formatOnSave = " [???] ";
        };

        # TODO: Doesn't work, need LSP/treesitter?
        # Highlight words under cursor, alternative to illuminate
        cursorline = {
          enable = false;
        };

        # TODO: Figure out how debugging from nvim works...
        # Debug-Adapter-Protocol
        dap = {
          enable = false;
        };

        # TODO: Figure out how diff-mode works...
        diffview = {
          enable = false;
        };

        # TODO: Compare after telescope etc. are enabled
        # Changes nvim UI components, alternative to Noice
        dressing = {
          enable = false;
        };

        # Notifications + LSP progress, alternative to Noice
        fidget = {
          enable = false;
        };

        # TODO: Doesn't work
        # Search labels
        flash = {
          enable = true;
        };

        # Git client
        fugitive = {
          enable = true;
        };

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
        hardtime = {
          enable = false;
        };

        # TODO: Maybe, don't know yet (also, telescope)
        # Mark files and jump to them
        harpoon = {
          enable = false;
        };

        # Markdown etc. heading highlights
        headlines = {
          enable = true;
        };

        # TODO:
        # Alternative to cursorline
        illuminate = {
          enable = true;
        };

        # Live-preview of LSP renamings
        inc-rename = {
          enable = true;
        };

        # TODO: Shortcut compatible with cmp
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

        # TODO: Maybe too much?
        # Render diagnostics as virtual line overlay
        lsp-lines = {
          enable = true;
        };

        # Statusline, alternative to airline
        lualine = {
          enable = true;

          globalstatus = true;
          sectionSeparators = { left = ""; right = ""; };
          componentSeparators = { left = ""; right = ""; };
        };
        
        # TODO: When I start actually using marks
        # Show marks in the gutter
        marks = {
          enable = false;
        };

        # Structural overview
        navbuddy = {
          enable = true;

          lsp.autoAttach = true;
        };

        # Generate doc comments
        neogen = {
          enable = true;
        };

        # TODO: When I need this
        # Interact with test frameworks
        neotest = {
          enable = false;
        };

        # NeoVim UI refresh, alternative to fidget and dressing
        noice = {
          enable = true;
        };

        notify = {
          enable = true;
        };

        # Alternative to autoclose
        nvim-autopairs = {
          enable = false;
        };

        # Colorize color hex codes etc.
        nvim-colorizer = {
          enable = true;
        };

        # TODO: Folds the entire code at startup???
        # Code folding
        nvim-ufo = {
          enable = false;
        };

        # File system explorer that is editable like a normal buffer
        oil = {
          enable = true;
        };

        # Colorize paranthesis
        rainbow-delimiters = {
          enable = true;
        };

        # TODO: Lua deps not found
        # REST/HTTP client
        rest = {
          enable = false;
        };

        # TODO:
        rustaceanvim = {
          enable = false;
        };

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
        statuscol = {
          enable = false;
        };

        # Select something
        telescope = {
          enable = true;

          extensions = {
            fzf-native.enable = true;
            ui-select.enable = true;
            undo.enable = true;
          };
        };

        # TODO: Folds at startup
        treesitter = {
          enable = true;

          ensureInstalled = "all";
          folding = false;
          indent = true;

          incrementalSelection = {
            enable = true;
          };
        };

        # Trim whitespace
        trim = {
          enable = true;
        };

        # Window listing detected linting/lsp problems
        trouble = {
          enable = true;
        };

        # Don't mess up splits when closing buffers
        vim-bbye = {
          enable = true;
        };

        # TODO: Setup
        # LaTeX
        vimtex = {
          enable = true;

          texlivePackage = null; # Don't auto-install
        };

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

      # TODO: Use conform-nvim.formatOnSave, also make this toggleable and add a "Format" command
      extraConfigLua = ''
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*",
          callback = function(args)
            require("conform").format({ bufnr = args.buf })
          end,
        })
      '';

      viAlias = cfg.alias;
      vimAlias = cfg.alias;
    };
  };
}
