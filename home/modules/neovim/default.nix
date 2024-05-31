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
        timeoutlen = 50;
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

      # TODO: Half of the neovide config doesn't work
      # TODO: LSP Window doesn't work. Noice?
      extraConfigLua = ''
        local opt = vim.opt
        local g = vim.g
        local o = vim.o

        -- Neovide
        if g.neovide then
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
        # lua-curl # For rest
        # xml2lua # For rest
        # mimetypes # For rest
      ];

      extraPlugins = with pkgs.vimPlugins; [
        vim-airline-themes
        nvim-web-devicons
        nui-nvim # For noice
        # nvim-nio # For rest
      ];

      keymaps = [
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
          key = "<";
          action = "v<<Esc>";
          options.desc = "Outdent";
        }
        {
          mode = "n";
          key = ">";
          action = "v><Esc>";
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
        {
          mode = "i";
          key = "<C-S-v>";
          action = "<Esc>\"+pi";
          options.desc = "Paste from clipboard";
        }
        {
          mode = "v";
          key = "<C-S-c>";
          action = "\"+y";
          options.desc = "Copy to clipboard";
        }
        {
          mode = "n";
          key = "<C-h>";
          action = "<cmd>nohlsearch<CR>";
          options.desc = "Clear search highlights";
        }

        # General <leader>
        {
          mode = "n";
          key = "<leader>qq";
          action = "<cmd>quitall<CR>";
          options.desc = "Quit";
        }
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
          options.desc = "Show undo history";
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
          key = "<leader>r";
          action = "<cmd>Telescope resume<CR>";
          options.desc = "Show last telescope picker";
        }
        {
          mode = "n";
          key = "<leader>?";
          action = "<cmd>Telescope keymaps<CR>";
          options.desc = "Show keymaps";
        }
        {
          mode = "n";
          key = "<leader>:";
          action = "<cmd>Telescope commands<CR>";
          options.desc = "Execute command";
        }
        {
          mode = "n";
          key = "<leader>M";
          action = "<cmd>Telescope marks<CR>";
          options.desc = "Show marks";
        }
        {
          mode = "n";
          key = "<leader>J";
          action = "<cmd>Telescope jumplist<CR>";
          options.desc = "Show jumplist";
        }
        {
          mode = "n";
          key = "<leader>m";
          action = "<cmd>Telescope man_pages<CR>";
          options.desc = "Show manpages";
        }
        {
          mode = "n";
          key = "<leader>h";
          action = "<cmd>Telescope help_tags<CR>";
          options.desc = "Show help tags";
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
          options.desc = "Show open buffers";
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
          key = "<leader>bd";
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
          action = "<C-w>s";
          options.desc = "Split window horizontally";
        }
        {
          mode = "n";
          key = "<leader>wv";
          action = "<C-w>v";
          options.desc = "Split window vertically";
        }
        {
          mode = "n";
          key = "<leader>wd";
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
          action = "<cmd>Neotree action=show toggle=true<CR>";
          options.desc = "Toggle NeoTree";
        }
        {
          mode = "n";
          key = "<leader>tn";
          action = "<cmd>Navbuddy<CR>";
          options.desc = "Toggle NavBuddy";
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
          options.desc = "Show Git status";
        }
        {
          mode = "n";
          key = "<leader>gc";
          action = "<cmd>Telescope git_commits<CR>";
          options.desc = "Show Git log";
        }
        {
          mode = "n";
          key = "<leader>gb";
          action = "<cmd>Telescope git_branches<CR>";
          options.desc = "Show Git branches";
        }
        {
          mode = "n";
          key = "<leader>gf";
          action = "<cmd>Telescope git_bcommits<CR>";
          options.desc = "Show Git log for current file";
        }

        # LSP <leader>l
        {
          mode = "n";
          key = "<leader>l";
          action = "+lsp";
        }
        {
          mode = "n";
          key = "<leader>lr";
          action = "<cmd>Telescope lsp_references<CR>";
          options.desc = "Goto references";
        }
        {
          mode = "n";
          key = "<leader>ld";
          action = "<cmd>Telescope lsp_definitions<CR>";
          options.desc = "Goto definition";
        }
        {
          mode = "n";
          key = "<leader>li";
          action = "<cmd>Telescope lsp_implementations<CR>";
          options.desc = "Goto implementation";
        }
        {
          mode = "n";
          key = "<leader>lt";
          action = "<cmd>Telescope lsp_type_definitions<CR>";
          options.desc = "Goto type definition";
        }
        {
          mode = "n";
          key = "<leader>lI";
          action = "<cmd>Telescope lsp_incoming_calls<CR>";
          options.desc = "Show incoming calls";
        }
        {
          mode = "n";
          key = "<leader>lO";
          action = "<cmd>Telescope lsp_outgoing_calls<CR>";
          options.desc = "Show outgoing calls";
        }

        # Code <leader>c
        {
          mode = "n";
          key = "<leader>c";
          action = "+code";
        }
        {
          mode = "n";
          key = "<leader>cf";
          action = "<cmd>lua require('conform').format()<CR>";
          options.desc = "Format current buffer";
        }
        {
          mode = "n";
          key = "<leader>cd";
          action = "<cmd>Telescope diagnostics<CR>";
          options.desc = "Show diagnostics";
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
                  -- ['<C-Space>'] = cmp.complete(),

                  ['<CR>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      if require('luasnip').expandable() then
                        require('luasnip').expand()
                      else
                        cmp.confirm({ select = true })
                      end
                    else
                      fallback()
                    end
                  end),

                  ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif require('luasnip').locally_jumpable(1) then
                      require('luasnip').jump(1)
                    else
                      fallback()
                    end
                  end, { "i", "s" }),

                  ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    elseif require('luasnip').locally_jumpable(-1) then
                      require('luasnip').jump(-1)
                    else
                      fallback()
                    end
                  end, { "i", "s" }),
                })
              '';
            };

            extraConfigLua = ''
              -- local cmp = require('cmp')

              -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
              -- cmp.setup.cmdline({'/', "?" }, {
              --   sources = {
              --     { name = 'buffer' }
              --   }
              -- })

              -- Set configuration for specific filetype.
              -- cmp.setup.filetype('gitcommit', {
              --   sources = cmp.config.sources({
              --     { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
              --   }, {
              --     { name = 'buffer' },
              --   })
              -- })

              -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
              -- cmp.setup.cmdline(':', {
              --   sources = cmp.config.sources({
              --     { name = 'path' }
              --   }, {
              --     { name = 'cmdline' }
              --   }),
              -- })

              kind_icons = {
                Text = "󰊄",
                Method = "",
                Function = "󰡱",
                Constructor = "",
                Field = "",
                Variable = "󱀍",
                Class = "",
                Interface = "",
                Module = "󰕳",
                Property = "",
                Unit = "",
                Value = "",
                Enum = "",
                Keyword = "",
                Snippet = "",
                Color = "",
                File = "",
                Reference = "",
                Folder = "",
                EnumMember = "",
                Constant = "",
                Struct = "",
                Event = "",
                Operator = "",
                TypeParameter = "",
              }
            '';
          };
        };

        cmp-async-path.enable = true;
        cmp-buffer.enable = true;
        cmp-emoji.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-nvim-lsp-signature-help.enable = true;
        cmp_luasnip.enable = true;
        # cmp-cmdline.enable = true;

        # Comment/Uncomment line/selection etc.
        comment = {
          enable = true;

          settings = {
            mappings.basic = true; # Apparently required for opleader/toggler config
            mappings.extra = false;
            opleader.line = "<C-c>";
            toggler.line = "<C-c>";
          };
        };

        # TODO: Format on save + format region after paste
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

          # TODO: Autoformat https://github.com/redyf/Neve/blob/main/config/lsp/conform.nix
          # formatOnSave = " [???] ";
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

        # Changes nvim UI components, alternative to Noice
        # dressing = {
        #   enable = false;
        # };

        # Notifications + LSP progress, alternative to Noice
        # fidget = {
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
          noDefaultMappings = true;
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

        # Markdown etc. heading highlights
        headlines = {
          enable = true;
        };

        # Alternative to cursorline
        illuminate = {
          enable = true;
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

        # Live-preview of LSP renamings
        inc-rename = {
          enable = true;
        };

        # Indent to current level on empty line
        intellitab = {
          enable = true;
        };

        # Open file at last place
        lastplace = {
          enable = true;
        };

        lazygit = {
          enable = true;
        };

        # Linting as addition to LSP
        lint = {
          enable = true;

          lintersByFt = {
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

        # Language-Server-Protocol
        lsp = {
          enable = true;

          servers = {
            clangd.enable = true;
            clojure-lsp.enable = true;
            cmake.enable = true;
            cssls.enable = true;
            dockerls.enable = true;
            eslint.enable = true;
            hls.enable = true;
            html.enable = true;
            java-language-server.enable = true;
            jsonls.enable = true;
            ltex = {
              enable = true;
              autostart = true;
            };
            marksman.enable = true;
            nil_ls.enable = true;
            pyright.enable = true;
            rust-analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
            };
            tailwindcss.enable = true;
            texlab.enable = true;
          };

          keymaps = {
            lspBuf = {
              K = {
                action = "hover";
                desc = "Hover information";
              };
              "<leader>cr" = {
                action = "rename";
                desc = "Rename symbol";
              };
              "<leader>ca" = {
                action = "code_action";
                desc = "Show code actions";
              };
            };
            diagnostic = {
              "<leader>cD" = {
                action = "open_float";
                desc = "Show line diagnostic";
              };
            };
          };
        };

        # lsp-format = {
        #   enable = false;
        # };

        # Render diagnostics as virtual line overlay
        # lsp-lines = {
        #   enable = true;
        # };

        # Statusline, alternative to airline
        lualine = {
          enable = true;

          alwaysDivideMiddle = true;
          globalstatus = true;
          ignoreFocus = ["neo-tree"];
          extensions = ["fzf"];

          sections = {
            lualine_a = ["mode"];
            lualine_b = ["branch" "diff" "diagnostics"];
            lualine_c = ["filename"];

            lualine_x = ["filetype" "encoding" "fileformat"];
            lualine_y = ["progress"];
            lualine_z = ["location" "searchcount" "selectioncount"];
          };

          sectionSeparators = {
            left = "";
            right = "";
          };

          componentSeparators = {
            left = "";
            right = "";
          };
        };

        # TODO: Snippet configs
        luasnip = {
          enable = true;
        };

        # Show marks in the gutter
        # marks = {
        #   enable = false;
        # };

        # Structural overview
        navbuddy = {
          enable = true;

          lsp.autoAttach = true;
          window.border = "rounded";
        };

        # Generate doc comments
        # neogen = {
        #   enable = true;
        # };

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
            bindToCwd = true;
            followCurrentFile = {
              enabled = true; # TODO: Doesn't work
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

        # NeoVim UI refresh, alternative to fidget, dressing, notify and lspsaga
        noice = {
          enable = true;

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
            backend = "nui";
          };

          # cmdline.enabled = false;
          # messages.enabled = false;

          routes = [
            {
              filter = {
                event = "msg_show";
                kind = "search_count";
              };
              opts = {skip = true;};
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

        # Work with pairs of delimiters
        sandwich = {
          enable = true;
        };

        # Automatically infer tab width
        sleuth = {
          enable = true;
        };

        # Select something
        telescope = {
          enable = true;

          extensions = {
            fzf-native.enable = true;
            ui-select.enable = true;
            undo.enable = true;
          };

          settings = {
            defaults = {
              mappings = {
                i = {
                  "<esc>" = {
                    __raw = ''
                      function(...)
                        return require("telescope.actions").close(...)
                      end
                    '';
                  };
                };
              };
            };
          };
        };

        toggleterm = {
          enable = true;

          settings = {
            open_mapping = "[[<C-t>]]";
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

        treesitter = {
          enable = true;

          ensureInstalled = "all";
          folding = true;
          indent = true; # Required by intellitab
          nixvimInjections = true;

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
