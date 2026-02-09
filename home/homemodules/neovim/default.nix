{
  inputs,
  system,
  headless,
  username,
  hostname,
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) neovim color;
in {
  options.homemodules.neovim = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf neovim.enable {
    home = {
      file.".config/neovide/config.toml".source = ./neovide_config.ini;
      file.".config/vale/.vale.ini".source = ./vale_config.ini;

      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      packages = with pkgs;
        builtins.concatLists [
          (lib.optionals neovim.neovide [neovide])

          (lib.optionals (!headless) [
            # Language servers
            clang-tools
            clojure-lsp
            cmake-language-server
            haskell-language-server
            jdt-language-server
            ltex-ls # TODO: Only enable on-demand
            lua-language-server
            # nil
            basedpyright
            pyrefly
            ty
            rust-analyzer
            svelte-language-server
            tailwindcss-language-server
            tex-fmt
            texlab
            tinymist
            typescript
            vscode-langservers-extracted # includes nodejs
            autotools-language-server
            just-lsp

            # Linters
            checkstyle # java
            clippy # rust
            clj-kondo # clojure
            eslint_d # javascript
            python313Packages.ruff
            python313Packages.flake8
            python313Packages.pylint
            lua54Packages.luacheck
            vale # text
            # statix # nix (doesn't recognize pipe operator)

            # Formatters
            cljfmt
            python313Packages.black
            google-java-format
            html-tidy
            jq # json
            # prettierd # Use prettier instead because of plugins
            # nodePackages_latest.prettier # Use local install as plugins change per project
            rustfmt
            stylua
            typstyle
            mbake
            just-formatter
          ])

          [
            (pkgs.ripgrep.override {withPCRE2 = true;})

            # Dependencies
            lua54Packages.jsregexp # For tree-sitter
            # nodejs_latest

            nixd
            alejandra # nix
          ]
        ];
    };

    programs.nixvim = {
      defaultEditor = true;
      enable = true;
      enableMan = false; # Nixvim man pages
      luaLoader.enable = true; # NOTE: Experimental
      viAlias = neovim.alias;
      vimAlias = neovim.alias;

      # Configured using plugin
      # colorschemes.catppuccin = {
      #   enable = true;
      #   settings = {
      #     flavour = "mocha"; # latte, frappe, macchiato, mocha
      #     background = {
      #       light = "latte";
      #       dark = "mocha";
      #     };
      #   };
      # };

      performance.byteCompileLua = {
        enable = true;
        configs = true;
        initLua = false; # When debugging init.lua turn this off
        nvimRuntime = true;
        plugins = true;
      };

      globals = {
        mapleader = " ";
        maplocalleader = ",";
      };

      opts = import ./vim_opts.nix {inherit lib mylib;};
      extraConfigLuaPost = builtins.readFile ./extraConfigLuaPost.lua;
      extraConfigLua = builtins.readFile ./extraConfigLua.lua;

      # Those files will be added to the nvim runtimpath
      extraFiles = {
        # For this its probably important to set the default filetype to tex (see extraConfigLua)
        "ftplugin/tex/mappings.lua".text = mylib.generators.toLuaKeymap (import ./mappings_latex.nix {});
        "ftplugin/markdown/mappings.lua".text = mylib.generators.toLuaKeymap (import ./mappings_markdown.nix {});

        # Luasnip searches the luasnippets folder in the runtimepath
        "luasnippets/tex.lua".text = builtins.readFile ./snippets_latex.lua;
      };

      highlight = {
        # Manually define blink.cmp highlight groups until catpuccin supports it. Update: Catpuccin supports it now.
        # BlinkCmpMenu = {
        #   bg = "#${color.hex.dark.base}";
        # };
        # BlinkCmpMenuBorder = {
        #   bg = "#${color.hex.dark.base}";
        #   fg = "#${color.hex.dark.blue}";
        # };
        # BlinkCmpMenuSelection = {
        #   bg = "#${color.hex.dark.blue}";
        #   fg = "#${color.hex.dark.crust}";
        #   bold = true;
        # };
        # BlinkCmpLabel = {
        #   bg = "#${color.hex.dark.base}";
        #   fg = "#${color.hex.dark.text}";
        #   bold = false;
        # };
      };

      # extraLuaPackages = with pkgs.lua51Packages; [];
      # extraPython3Packages = p: [];

      autoCmd = [
        # TODO: This only works if neotree has been opened before...
        # {
        #   desc = "Refresh neotree when closing lazygit";
        #   event = ["BufLeave"];
        #   pattern = ["*lazygit*"];
        #   callback.__raw = ''
        #     function()
        #       local manager = require("neo-tree.sources.manager")
        #       local renderer = require("neo-tree.ui.renderer")
        #       local state = manager.get_state("filesystem")
        #       local window_exists = renderer.window_exists(state)

        #       if window_exists then
        #         require("neo-tree.sources.filesystem.commands").refresh(state)
        #       end
        #     end
        #   '';
        # }

        {
          desc = "Lint the file if autolint is enabled";
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
          desc = "Highlight yanked regions";
          event = ["TextYankPost"];
          callback.__raw = "function() vim.highlight.on_yank() end";
        }

        {
          desc = "Resize splits when Neovim is resized by the WM";
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
          desc = "Disable conceal in JSON files";
          event = ["FileType"];
          pattern = ["json" "jsonc" "json5"]; # Disable conceal for these filetypes
          callback.__raw = "function() vim.opt_local.conceallevel = 0 end";
        }

        {
          desc = "Attach JDTLS to Java files";
          event = ["FileType"];
          pattern = ["Java" "java"];
          callback.__raw = ''
            function()
              local workspace = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1])

              local opts = {
                root_dir = workspace,
                cmd = {
                  "jdtls",
                  "-data",
                  "/home/christoph/.local/share/eclipse/" .. vim.fn.fnamemodify(workspace, ":p:h:t"),
                },
              }

              require('jdtls').start_or_attach(opts)
            end
          '';
        }
      ];

      keymaps = import ./mappings.nix {inherit lib mylib;};

      plugins.lazy = let
        mkDefaultConfig = name: ''
          function(_, opts)
            require("${name}").setup(opts)
          end
        '';
      in {
        enable = true;

        plugins = let
          autopairs = rec {
            name = "nvim-autopairs";
            pkg = pkgs.vimPlugins.nvim-autopairs;
            lazy = true;
            event = ["InsertEnter"];
            config = mkDefaultConfig name;
            opts = {
              check_ts = true;
            };
          };

          better-escape = rec {
            name = "better_escape";
            pkg = pkgs.vimPlugins.better-escape-nvim;
            lazy = true;
            event = ["InsertEnter"];
            config = mkDefaultConfig name;
            opts = {
              # mapping = ["jk"]; # Deprecated but still the default
              default_mappings = true;
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
              # https://github.com/catppuccin/nvim/tree/main?tab=readme-ov-file#integrations
              default_integrations = true;
              integrations = {
                blink_cmp = true;
                dashboard = true;
                diffview = true;
                flash = true;
                gitsigns = true;
                mini.enabled = true;
                neotree = true;
                noice = true;
                native_lsp = {
                  enabled = true;
                  virtual_text = {
                    errors = ["italic"];
                    hints = ["italic"];
                    warnings = ["italic"];
                    information = ["italic"];
                    ok = ["italic"];
                  };
                  underlines = {
                    errors = ["underline"];
                    hints = ["underline"];
                    warnings = ["underline"];
                    information = ["underline"];
                    ok = ["underline"];
                  };
                  inlay_hints = {
                    background = true;
                  };
                };
                navic = {
                  enabled = true;
                  # custom_bg = "crust";
                };
                notify = true;
                treesitter = true;
                ufo = true;
                rainbow_delimiters = true;
                telescope.enabled = true;
                lsp_trouble = true;
                illuminate = {
                  enabled = true;
                  lsp = true;
                };
                which_key = true;
              };
            };
          };

          # NOTE: In LazyVim require("clang_extensions").setup(opts) is called where opts is the server definition from lspconfig...
          clangd-extensions = rec {
            name = "clangd_extensions";
            pkg = pkgs.vimPlugins.clangd_extensions-nvim;
            lazy = true;
            config = mkDefaultConfig name;
            opts = {
              inlay_hints = {
                inline = false;
              };
            };
          };

          blink-cmp = rec {
            name = "blink.cmp";
            # pkg = inputs.blink-cmp.packages.${system}.default;
            pkg = pkgs.vimPlugins.blink-cmp;
            lazy = true;
            event = ["InsertEnter"];
            config = mkDefaultConfig name;

            opts = {
              keymap.preset = "enter";

              completion = {
                keyword = {
                  range = "full"; # Fuzzy match on text before and after the cursor
                };

                accept = {
                  auto_brackets = {
                    enabled = true; # Insert brackets for functions
                  };
                };

                menu = {
                  enabled = true;
                  auto_show = true;
                  scrollbar = true;
                  border = "rounded";
                };

                documentation = {
                  auto_show = true;
                  auto_show_delay_ms = 250;
                  treesitter_highlighting = true;

                  window = {
                    scrollbar = true;
                    border = "rounded";
                  };
                };

                ghost_text = {
                  enabled = false;
                };
              };

              signature = {
                enabled = true;
                window = {
                  border = "rounded";
                };
              };

              fuzzy = {
                frecency.enabled = true;
                use_proximity = true;
              };

              sources = {
                default = ["lsp" "path" "snippets"]; # No "buffer"
              };

              cmdline = {
                enabled = false;
              };

              term = {
                enabled = false;
              };

              appearance = {
                use_nvim_cmp_as_default = true;
                nerd_font_variant = "mono";
              };
            };
          };

          colorizer = rec {
            name = "colorizer";
            pkg = pkgs.vimPlugins.nvim-colorizer-lua;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            config = mkDefaultConfig name;

            # https://github.com/catgoose/nvim-colorizer.lua
            opts = {
              filtetypes = ["*"];
              user_default_options = {
                names = false;
                RGB = true; # #RGB hex codes
                RGBA = true; # #RGBA hex codes
                RRGGBB = true; # #RRGGBB hex codes
                RRGGBBAA = true; # #RRGGBBAA hex codes
                AARRGGBB = false; # 0xAARRGGBB hex codes
                rgb_fn = true; # CSS rgb() and rgba() functions
                hsl_fn = true; # CSS hsl() and hsla() functions
              };
            };
          };

          _ts-context-commentstring = rec {
            name = "ts_context_commentstring";
            pkg = pkgs.vimPlugins.nvim-ts-context-commentstring;
            lazy = true;
            # NOTE: Init is run before the plugin loads, e.g. for legacy vim.g settings
            init = ''
              function()
                -- Skip compatibility checks
                vim.g.skip_ts_context_commentstring_module = true
              end
            '';
            # NOTE: Config is run after the plugin was loaded
            config = mkDefaultConfig name;
          };

          comment = rec {
            name = "Comment";
            pkg = pkgs.vimPlugins.comment-nvim;
            lazy = false;
            # keys = ["<C-c>" "<C-b>"]; # NOTE: This list only works in normal mode
            dependencies = [
              _ts-context-commentstring
            ];
            config = mkDefaultConfig name;
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

          # Code formatting
          conform = rec {
            name = "conform";
            pkg = pkgs.vimPlugins.conform-nvim;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            config = mkDefaultConfig name;
            opts = {
              formatters_by_ft = {
                c = ["clang-format"];
                h = ["clang-format"];
                cpp = ["clang-format"];
                hpp = ["clang-format"];
                clojure = ["cljfmt"];
                css = ["prettierd" "prettier"];
                html = ["prettierd" "prettier"];
                java = ["google-java-format"];
                javascript = ["prettierd" "prettier"];
                just = ["just"];
                latex = ["tex-fmt"];
                lua = ["stylua"];
                make = ["bake"];
                markdown = ["prettierd" "prettier"];
                nix = ["alejandra"];
                python = ["black"];
                qml = ["qmlformat"];
                rust = ["rustfmt"];
                svelte = ["prettierd" "prettier"];
                typescript = ["prettierd" "prettier"];
                typst = ["typstyle"];
              };

              default_format_opts = {
                lsp_format = "fallback";
                stop_after_first = true;
              };

              # format_on_save formats synchronously, format_after_save asynchronously
              format_after_save.__raw = ''
                function(bufnr)
                  -- Disable with a global or buffer-local variable
                  if vim.g.disable_autoformat then
                    return
                  end
                  return { timeout_ms = 500, lsp_format = "fallback", stop_after_first = true, }
                end
              '';

              log_level.__raw = ''vim.log.levels.DEBUG'';
            };
          };

          direnv = {
            name = "direnv";
            pkg = pkgs.vimPlugins.direnv-vim;
            lazy = false;
          };

          diffview = {
            name = "diffview";
            pkg = pkgs.vimPlugins.diffview-nvim;
            lazy = true;
            cmd = ["DiffviewOpen"];
          };

          flash = rec {
            name = "flash";
            pkg = pkgs.vimPlugins.flash-nvim;
            lazy = true;
            keys = ["f" "F"];
            config = mkDefaultConfig name;
          };

          gitsigns = rec {
            name = "gitsigns";
            pkg = pkgs.vimPlugins.gitsigns-nvim;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            config = mkDefaultConfig name;
            opts = {
              numhl = false;
              linehl = false;
              current_line_blame = true;
              current_line_blame_opts = {
                delay = 50;
              };
            };
          };

          haskell-tools = {
            name = "haskell-tools";
            pkg = pkgs.vimPlugins.haskell-tools-nvim;
            lazy = false; # Recommended by author
            # Don't call setup!
          };

          # hover = let
          #   # Display LSP information and Diagnostics at the same time
          #   # https://github.com/lewis6991/hover.nvim/issues/34#issuecomment-1625662866
          #   lspWithDiag = ''
          #     {
          #        name = "LSP",
          #        priority = 1000,
          #        enabled = function()
          #          return true
          #        end,
          #
          #        execute = function(opts, done)
          #          local params = vim.lsp.util.make_position_params()
          #          local ___ = "\n─────────────────────────────────────────────────────────────────────────────\n"
          #
          #          vim.lsp.buf_request_all(0, 'textDocument/hover', params, function(responses)
          #            local value = ""
          #            for _, response in pairs(responses) do
          #              local result = response.result
          #              if result and result.contents and result.contents.value then
          #                if value ~= "" then
          #                  value = value .. ___
          #                end
          #                value = value .. result.contents.value
          #              end
          #            end
          #
          #            local _, row = unpack(vim.fn.getpos("."))
          #            local lineDiag = vim.diagnostic.get(0, { lnum = row - 1 })
          #            for _, d in pairs(lineDiag) do
          #              if d.message then
          #                if value ~= "" then
          #                  value = value .. ___
          #                end
          #                value = value .. string.format("*%s* %s", d.source, d.message)
          #              end
          #            end
          #            value = value:gsub("\r", "")
          #
          #            if value ~= "" then
          #              done({ lines = vim.split(value, "\n", true), filetype = "markdown" })
          #            else
          #              done()
          #            end
          #          end)
          #        end,
          #      }
          #   '';
          # in rec {
          #   name = "hover";
          #   pkg = pkgs.vimPlugins.hover-nvim;
          #   lazy = true;
          #   event = ["BufReadPost" "BufNewFile"];
          #   config = mkDefaultConfig name;
          #   opts = {
          #     init.__raw = ''
          #       function()
          #         -- Register custom providers
          #         require('hover').register(${lspWithDiag})
          #
          #         -- Require providers
          #         -- require("hover.providers.lsp")
          #         -- require('hover.providers.diagnostic')
          #         require('hover.providers.fold_preview')
          #         require('hover.providers.man')
          #
          #         -- require('hover.providers.gh')
          #         -- require('hover.providers.gh_user')
          #         -- require('hover.providers.jira')
          #         -- require('hover.providers.dap')
          #         -- require('hover.providers.dictionary')
          #         -- require('hover.providers.highlight')
          #       end
          #     '';
          #     preview_opts = {
          #       border = "rounded";
          #     };
          #     # Whether the contents of a currently open hover window should be moved
          #     # to a :h preview-window when pressing the hover keymap.
          #     preview_window = false;
          #     title = false;
          #   };
          # };

          illuminate = rec {
            name = "illuminate";
            pkg = pkgs.vimPlugins.vim-illuminate;
            lazy = true;
            event = ["BufreadPost" "BufNewFile"];
            config = ''
              function(_, opts)
                require("${name}").configure(opts)
              end
            '';
            opts = {
              filetypesDenylist = [
                "DressingSelect"
                "Outline"
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

          intellitab = {
            name = "intellitab";
            pkg = pkgs.vimPlugins.intellitab-nvim; # Prints at each indent :(
            # TODO: Build broken
            # pkg = pkgs.vimUtils.buildVimPlugin {
            #   name = "intellitab-nvim";
            #   src = pkgs.fetchFromGitHub {
            #     owner = "ChUrl";
            #     repo = "intellitab.nvim";
            #     rev = "6d644b7d92198477f2920d0c3b3b22dad470ef10"; # Disable print
            #     sha256 = "sha256-MwBcsYpyrjoXa7nxcwaci3h0NIWyMoF1NyYfEbFzo0E=";
            #   };
            # };
            lazy = true;
            event = ["InsertEnter"];
          };

          jdtls = {
            name = "jdtls";
            pkg = pkgs.vimPlugins.nvim-jdtls;
            lazy = false; # Is only ever loaded in Java buffers anyway

            # Additional configuration is done in autoCmd
          };

          lastplace = rec {
            name = "nvim-lastplace";
            pkg = pkgs.vimPlugins.nvim-lastplace;
            lazy = false;
            config = mkDefaultConfig name;
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

                local chktex = lint.linters.chktex
                chktex.args = {
                  '-v0',
                  '-I0',
                  '-n3', -- Enclose previous parenthesis with {}
                  -- '-n8', -- Wrong length of dash may have been used
                  -- '-n24', -- Delete this space to maintain correct page references
                  '-s',
                  ':',
                  '-f',
                  '%l%b%c%b%d%b%k%b%n%b%m%b%b%b'
                }
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
                # nix = ["statix"];
                python = ["ruff" "flake8"]; # TODO: "pylint" can't resolve some imports (e.g. PySide6.QtGui)
                tex = ["chktex"];
                # rust = ["clippy"]; # Not supported, but integrated through rustaceanvim
                text = ["vale"];
              };
            };
          };

          # Newer alternative to neodev
          _lazydev = rec {
            name = "lazydev";
            pkg = pkgs.vimPlugins.lazydev-nvim;
            lazy = true;
            ft = ["lua"];
            config = mkDefaultConfig name;
            # opts = {
            #   library = [
            #     "~/NixFlake/config/neovim/store"
            #   ];
            # };
          };

          # NOTE: This entire thing is rough, I should rewrite...
          # TODO: Need to rewrite this once lspconfig 3.0 comes around
          lspconfig = {
            name = "lspconfig";
            pkg = pkgs.vimPlugins.nvim-lspconfig;
            lazy = false;
            cmd = ["LspInfo"];
            event = ["BufReadPost" "BufNewFile"];
            dependencies = [_lazydev];
            config = let
              servers = mylib.generators.toLuaObject [
                {name = "basedpyright";}
                # {name = "pyrefly";} # TODO: Config
                # {name = "ty";} # TODO: Config
                {
                  name = "clangd";
                  extraOptions = {
                    # root_markers = [
                    #   "Makefile"
                    #   "CMakeLists.txt"
                    #   ".clang-format"
                    #   ".clang-tidy"
                    #   "compile_commands.json"
                    # ];
                    # workspace_required = true;

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
                {name = "cssls";}
                {name = "html";} # vscode-langservers-extracted
                {name = "just-lsp";} # TODO: Doesn't autostart?
                {name = "lua_ls";}
                {
                  name = "ltex";
                  extraOptions.settings = {
                    ltex = {
                      checkFrequency = "save";
                      enabled = ["markdown" "org" "tex" "latex" "plaintext"];
                    };
                  };
                }
                {name = "autotools-language-server";}
                # {name = "nil_ls";}
                {
                  name = "nixd";
                  extraOptions.cmd = [
                    "nixd"
                    "--inlay-hints=true"
                    "--semantic-tokens=true"
                  ];
                  extraOptions.settings = {
                    nixd = {
                      nixpkgs = {
                        expr = "import <nixpkgs> { }";
                      };
                      formatting = {
                        command = ["alejandra"];
                      };
                      options = {
                        nixos = {
                          expr = "(builtins.getFlake \"/home/${username}/NixFlake\").nixosConfigurations.${hostname}.options";
                        };

                        # For HM standalone
                        # home-manager = {
                        #   expr = "(builtins.getFlake \"/home/${username}/NixFlake\").homeConfigurations.\"${username}@${hostname}\".options";
                        # };

                        # For HM NixOS module
                        home-manager = {
                          expr = "(builtins.getFlake \"/home/${username}/NixFlake\").nixosConfigurations.\"${hostname}\".options.home-manager.users.type.getSubOptions []";
                        };
                      };
                      diagnostic = {
                        suppress = [
                          "sema-escaping-with"
                          "var-bind-to-this"
                          "escaping-this-with"
                        ];
                      };
                    };
                  };
                }
                {
                  name = "qmlls";
                  extraOptions.cmd = [
                    "qmlls"
                    "-E" # Use QML_IMPORT_PATH env variable
                  ];
                }
                {name = "svelte";}
                {name = "tailwindcss";}
                {name = "texlab";}
                {
                  name = "tinymist";
                  extraOptions.settings = {
                    formatterMode = "typstyle";
                    exportPdf = "onType";
                    semanticTokens = "disable";
                  };
                }

                # {name = "jdtls";} # Don't set up when using nvim-jdtls
                # {name = "rust_analyzer";} # Don't set up when using rustaceanvim
                # {name = "hls";} # Don't set up when using haskell-tools
              ];
            in ''
              function(_, opts)
                local __lspOnAttach = function(client, bufnr)

                  -- NOTE: The ltex-extra package needs to be loaded in ltex's onAttach.
                  --       I don't know how to do this more declaratively with the current structure.
                  if client.name == "ltex" then
                    require("ltex_extra").setup({})
                  end

                  -- NOTE: The svelte-lsp apparently has a bug and doesn't watch files correctly
                  if client.name == "svelte" then
                    vim.api.nvim_create_autocmd("BufWritePost", {
                      pattern = { "*.js", "*.ts" },
                      group = vim.api.nvim_create_augroup("svelte_ondidchangetsorjsfile", { clear = true }),
                      callback = function(ctx)
                        -- Here use ctx.match instead of ctx.file
                        client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
                      end,
                    })
                  end

                end

                local __lspCapabilities = function()

                  capabilities = vim.lsp.protocol.make_client_capabilities()

                  -- I don't remember where this came from, but without cmp it makes no sense
                  -- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

                  -- get_lsp_capabilities merges with the existing capabilities
                  capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

                  return capabilities

                end

                local __setup = {
                  on_attach = __lspOnAttach,
                  capabilities = __lspCapabilities(),
                }

                -- Enable configured servers
                for i, server in ipairs(${servers}) do
                  if type(server) == "string" then
                    -- require("lspconfig")[server].setup(__setup)
                    vim.lsp.config(server, __setup)
                    vim.lsp.enable(server)
                  else
                    local options = server.extraOptions

                    if options == nil then
                      options = __setup
                    else
                      options = vim.tbl_extend("keep", options, __setup)
                    end

                    -- require("lspconfig")[server.name].setup(options)
                    vim.lsp.config(server.name, options)
                    vim.lsp.enable(server.name)
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
            opts = let
              bubbles = ''
                {
                  normal = {
                    a = { fg = "#${color.hex.base}", bg = "#${color.hex.accent}", gui = "bold" },
                    b = { fg = "#${color.hex.text}", bg = "#${color.hex.crust}" },
                    c = { fg = "#${color.hex.text}", bg = "NONE" },
                  },

                  insert = {
                    a = { fg = "#${color.hex.base}", bg = "#${color.hex.green}", gui = "bold" },
                    b = { fg = "#${color.hex.green}", bg = "#${color.hex.crust}" },
                  },

                  visual = {
                    a = { fg = "#${color.hex.base}", bg = "#${color.hex.blue}", gui = "bold" },
                    b = { fg = "#${color.hex.blue}", bg = "#${color.hex.crust}" },
                  },

                  replace = {
                    a = { fg = "#${color.hex.base}", bg = "#${color.hex.red}", gui = "bold" },
                    b = { fg = "#${color.hex.red}", bg = "#${color.hex.crust}" },
                  },

                  -- terminal = {
                  --   a = { fg = "#${color.hex.base}", bg = "#${color.hex.green}", gui = "bold" },
                  --   b = { fg = "#${color.hex.green}", bg = "#${color.hex.crust}" },
                  -- },

                  command = {
                    a = { fg = "#${color.hex.base}", bg = "#${color.hex.peach}", gui = "bold" },
                    b = { fg = "#${color.hex.peach}", bg = "#${color.hex.crust}" },
                  },

                  inactive = {
                    a = { fg = "#${color.hex.text}", bg = "#${color.hex.base}" },
                    b = { fg = "#${color.hex.text}", bg = "#${color.hex.base}" },
                    c = { fg = "#${color.hex.text}", bg = "NONE" },
                  },
                }
              '';
            in {
              extensions = ["fzf" "lazy" "quickfix" "toggleterm" "trouble"];

              options = {
                # theme = "catppuccin";
                theme.__raw = bubbles;
                always_divide_middle = true;
                globalstatus = true;
                ignore_focus = ["neo-tree"];
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
                # These often use mixed lists/attrSets, so we have to use __raw alot
                lualine_a.__raw = ''{ { "mode", separator = {}, } }'';
                lualine_b.__raw = ''
                  {
                    {
                      "branch",
                      on_click = function() vim.cmd("LazyGit") end,
                    },
                    {
                      "diff",
                      on_click = function() vim.cmd("DiffviewOpen") end,
                    },
                    {
                      "diagnostics",
                      on_click = function() vim.cmd("Trouble diagnostics toggle") end,
                    },
                    {
                      "filename",
                      path = 1,
                    },
                  }
                '';
                lualine_c.__raw = ''{}''; # Use __raw: Nixvim does nothing with "[]", so the default config would be used

                lualine_x.__raw = ''{}'';
                lualine_y = ["filetype" "encoding" "fileformat"];
                lualine_z.__raw = ''{ { "location", separator = {}, } }'';
              };

              inactive_sections = {
                lualine_a = [];
                lualine_b = ["filename"];
                lualine_c = [];
                lualine_x = [];
                lualine_y = [];
                lualine_z = ["location"];
              };

              # Using tabby for this
              # tabline = {
              #   lualine_a = ["hostname"];
              #   lualine_b = ["tabs"]; # buffers
              #   lualine_x = ["windows"];
              # };
            };
          };

          luasnip = {
            name = "luasnip";
            pkg = pkgs.vimPlugins.luasnip;
            lazy = true;
            event = ["InsertEnter"];
            config = ''
              function(_, opts)
                require("luasnip").config.set_config(opts)

                -- Load snippets. Because we don't set "path", the nvim runtimepath is searched.
                -- Snippet files are added through nixvim's extraFiles (see at the top).
                require("luasnip.loaders.from_lua").lazy_load({})
              end
            '';
            opts = {
              enable_autosnippets = false;
            };
          };

          ltex-extra = {
            name = "ltex_extra";
            pkg = pkgs.vimPlugins.ltex_extra-nvim;
            lazy = true;
            ft = ["markdown" "tex"];
            dependencies = [lspconfig];
            config = ''
              -- Do nothing, as we call require("ltex_extra") in ltex's onAttach
              function(_, opts) end
            '';
          };

          markview = {
            name = "markview";
            pkg = pkgs.vimPlugins.markview-nvim;
            lazy = true;
            ft = ["markdown"];
            dependencies = [
              treesitter
              web-devicons
            ];
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

          neogen = rec {
            name = "neogen";
            pkg = pkgs.vimPlugins.neogen;
            lazy = true;
            cmd = ["Neogen"];
            config = mkDefaultConfig name;
            opts = {
              snippet_engine = "luasnip";
            };
          };

          neotree = rec {
            name = "neo-tree";
            pkg = pkgs.vimPlugins.neo-tree-nvim;
            dependencies = [
              _plenary
              web-devicons
              _nui
            ];
            lazy = true;
            cmd = ["Neotree"];
            config = mkDefaultConfig name;
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
                  visible = false; # Toggle with "H"
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
                  "." = "set_root";
                  ">" = "navigate_up";
                  "H" = "toggle_hidden";
                  "<Esc>" = "cancel";
                  "/" = "fuzzy_finder";
                  "?" = "show_help";
                };
              };
            };
          };

          _nui = {
            name = "nui"; # For noice
            pkg = pkgs.vimPlugins.nui-nvim;
            lazy = true;
          };

          noice = rec {
            name = "noice";
            pkg = pkgs.vimPlugins.noice-nvim;
            lazy = false;
            dependencies = [
              _nui
            ];
            config = mkDefaultConfig name;
            opts = {
              presets = {
                bottom_search = false;
                command_palette = true;
                long_message_to_split = true;
                inc_rename = true; # TODO: Doesn't work as I expect (not for LSP rename)
                lsp_doc_border = true;
              };

              lsp = {
                progress.enabled = true;
                hover.enabled = true;
                signature.enabled = false; # Use blink for this
                message.enabled = true;
                documentation = {
                  view = "hover";
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

          # obsidian = rec {
          #   name = "obsidian";
          #   pkg = pkgs.vimPlugins.obsidian-nvim;
          #   lazy = true;
          #   cmd = ["ObsidianSearch" "ObsidianNew"];
          #   ft = ["markdown"];
          #   dependencies = [
          #     _plenary
          #   ];
          #   config = mkDefaultConfig name;
          #   opts = {
          #     workspaces = [
          #       {
          #         name = "Chriphost";
          #         path = "~/Notes/Obsidian/Chriphost";
          #       }
          #     ];
          #   };
          # };

          # TODO: Don't autosave, but if a session exists, update it (using should_save)
          # TODO: No idea which opts below really exist...
          persisted = rec {
            name = "persisted";
            pkg = pkgs.vimPlugins.persisted-nvim;
            lazy = false;
            config = mkDefaultConfig name;
            opts = {
              silent = false;
              use_git_branch = false;
              autostart = false;
              autosave = false;
              autoload = false;
              follow_cwd = true;
              ignored_dirs = [
                "/"
                "~/"
                "~/Projects/"
              ];
            };
          };

          presence = rec {
            name = "presence";
            pkg = pkgs.vimPlugins.presence-nvim;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            config = mkDefaultConfig name;
            opts = {
              auto_update = true;
              show_time = false;
            };
          };

          quickfix-reflector = {
            name = "quickfix-reflector";
            pkg = pkgs.vimPlugins.quickfix-reflector-vim;
            lazy = false;
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

            init = ''
              function()
                vim.g.rustaceanvim = {
                  tools = {
                    enable_clippy = true,
                    float_win_config = {
                      border = "rounded",
                    },
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

          scope = rec {
            name = "scope";
            pkg = pkgs.vimPlugins.scope-nvim;
            lazy = false;
            config = mkDefaultConfig name;
          };

          sleuth = {
            name = "sleuth";
            pkg = pkgs.vimPlugins.vim-sleuth;
            lazy = false;
          };

          snacks = rec {
            name = "snacks";
            pkg = pkgs.vimPlugins.snacks-nvim;
            dependencies = [
              web-devicons
            ];
            lazy = false;
            priority = 1000;
            config = mkDefaultConfig name;
            opts = {
              # Disables slow stuff in big files
              bigfile = {
                enabled = true;
                notify = true;
                size = 1.5 * 1024 * 1024; # 1.5MB
                line_length = 1000;
              };

              bufdelete.enabled = false;

              dashboard = {
                enabled = true;

                preset = {
                  keys = [
                    {
                      icon = " ";
                      key = "f";
                      desc = "Find File";
                      action = "<cmd>lua Snacks.dashboard.pick('files')<cr>";
                    }
                    {
                      icon = " ";
                      key = "n";
                      desc = "New File";
                      action = "<cmd>ene | startinsert<cr>";
                    }
                    {
                      icon = " ";
                      key = "g";
                      desc = "Find Text";
                      action = "<cmd>lua Snacks.dashboard.pick('live_grep')<cr>";
                    }
                    {
                      icon = " ";
                      key = "r";
                      desc = "Recent Files";
                      action = "<cmd>lua Snacks.dashboard.pick('oldfiles')<cr>";
                    }
                    {
                      icon = " ";
                      key = "s";
                      desc = "Restore Session";
                      action = "<cmd>lua require('persisted').select()<cr>";
                    }
                    {
                      icon = "󰒲 ";
                      key = "L";
                      desc = "Lazy";
                      action = "<cmd>Lazy<cr>";
                    }
                    {
                      icon = " ";
                      key = "q";
                      desc = "Quit";
                      action = "<cmd>quitall<cr>";
                    }
                  ];

                  sections = [
                    {section = "header";}
                    {
                      section = "keys";
                      gap = 1;
                      padding = 1;
                    }
                    {section = "startup";}
                  ];
                };
              };

              debug.enabled = false;
              dim.enabled = false;

              explorer = {
                enabled = false;
                replace_netrw = false; # Use yazi for that
              };

              gh.enabled = false;
              git.enabled = false;
              gitbrowse.enabled = false;
              image.enabled = false;
              indent.enabled = false;
              input.enabled = false;
              keymap.enabled = false;
              layout.enabled = false;
              lazygit.enabled = true;

              notifier = {
                enabled = true;
              };

              picker = let
                defaultLayout = ''
                  --- Use the default layout or vertical if the window is too narrow
                  function()
                    return vim.o.columns >= 120 and "default" or "vertical"
                  end
                '';
              in {
                enabled = true;

                layout = {
                  cycle = true;
                  preset.__raw = defaultLayout;
                };

                sources = {
                  lines = {
                    layout.__raw = defaultLayout;
                  };
                };

                formatters = {
                  file = {
                    filename_first = true;
                    truncate = 80;
                  };
                };
              };

              profiler.enabled = false;
              quickfile.enabled = false;
              rename.enabled = false;
              scope.enabled = false;
              scratch.enabled = false;
              scroll.enabled = false;
              statuscolumn.enabled = false;
              terminal.enabled = false;
              toggle.enabled = false;
              util.enabled = false;
              win.enabled = false;
              words.enabled = false;
              zen.enabled = false;
            };
          };

          tabby = rec {
            name = "tabby";
            pkg = pkgs.vimPlugins.tabby-nvim;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            dependencies = [web-devicons];
            config = mkDefaultConfig name;
            opts = {
              line.__raw = ''
                function(line)
                  local base = { fg = "#${color.hex.base}", bg = "#${color.hex.base}" }
                  local crust = { fg = "#${color.hex.crust}", bg = "#${color.hex.crust}" }
                  local text = { fg = "#${color.hex.text}", bg = "#${color.hex.crust}" }
                  local accent = { fg = "#${color.hex.accent}", bg = "#${color.hex.accent}" }

                  local numtabs = vim.call("tabpagenr", "$")

                  return {
                    -- Head
                    {
                        { " NEOVIM ", hl = { fg = "#${color.hex.base}", bg = "#${color.hex.accent}", style = "bold" } },

                        -- The separator gets a foreground and background fill (each have fg + bg).
                        -- line.sep("", accent, lavender),
                    },

                    -- Tabs
                    line.tabs().foreach(function(tab)
                      -- Switch out the start separator instead of the ending one because the last separator is different
                      local hl = tab.is_current() and { fg = "#${color.hex.accent}", bg = "#${color.hex.crust}", style = "bold" } or text
                      local sep_start = tab.number() == 1 and "" or ""
                      local sep_end = tab.number() == numtabs and "" or ""

                      return {
                        line.sep(sep_start, accent, crust),
                        tab.number(),
                        tab.name(),
                        line.sep(sep_end, crust, base),
                        hl = hl,
                        margin = " ",
                      }
                    end),

                    -- Background
                    hl = bg,
                  }
                end
              '';
            };
          };

          _plenary = {
            name = "plenary";
            pkg = pkgs.vimPlugins.plenary-nvim;
            lazy = true;
          };

          todo-comments = rec {
            name = "todo-comments";
            pkg = pkgs.vimPlugins.todo-comments-nvim;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            dependencies = [
              _plenary
            ];
            config = mkDefaultConfig name;
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
                  ];
                  # signs = false; # Configure signs for some keywords individually
                };
                TODO = {
                  icon = " ";
                  color = "info";
                  alt = [
                  ];
                };
                HACK = {
                  icon = " ";
                  color = "warning";
                  alt = [
                  ];
                };
                WARN = {
                  icon = " ";
                  color = "warning";
                  alt = [
                    "WARNING"
                    "XXX"
                  ];
                };
                PERF = {
                  icon = " ";
                  alt = [
                    "OPTIM"
                    "PERFORMANCE"
                    "OPTIMIZE"
                  ];
                };
                NOTE = {
                  icon = " ";
                  color = "hint";
                  alt = [
                    "INFO"
                  ];
                };
                TEST = {
                  icon = "⏲ ";
                  color = "test";
                  alt = [
                    "TESTING"
                    "PASSED"
                    "FAILED"
                  ];
                };
              };
            };
          };

          toggleterm = rec {
            name = "toggleterm";
            pkg = pkgs.vimPlugins.toggleterm-nvim;
            lazy = true;
            cmd = ["ToggleTerm"];
            keys = ["<C-/>"];
            config = mkDefaultConfig name;

            opts = {
              open_mapping.__raw = "[[<C-/>]]";
              autochdir = true;
              hide_numbers = true;
              shade_terminals = false;
              shading_factor = 30; # Default is -30 to darken the terminal
              start_in_insert = true;
              terminal_mappings = true;
              size = 20;
              persist_size = true;
              persist_mode = false; # Don't persist the current mode (insert/normal)
              insert_mappings = true;
              close_on_exit = true;
              shell = "fish";
              direction = "horizontal"; # 'vertical' | 'horizontal' | 'window' | 'float'
              auto_scroll = true;

              float_opts = {
                border = "curved"; # 'single' | 'double' | 'shadow' | 'curved'
                width = 80;
                height = 80;
                winblend = 0;
              };
            };
          };

          # _treesitter-context = {
          #   name = "treesitter-context";
          #   pkg = pkgs.vimPlugins.nvim-treesitter-context;
          #   lazy = true;
          #   config = ''
          #     function(_, opts)
          #       require("treesitter-context").setup(opts)
          #     end
          #   '';
          #   opts = {
          #     max_lines = 3;
          #     line_numbers = false;
          #   };
          # };

          # _treesitter-refactor = {
          #   name = "treesitter-refactor";
          #   pkg = pkgs.vimPlugins.nvim-treesitter-refactor;
          #   lazy = true;
          # };

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
            lazy = false;
            init = ''
              function()
                -- Fix treesitter grammars/parsers on nix
                vim.opt.runtimepath:append("${nvim-plugintree}")
                vim.opt.runtimepath:append("${treesitter-parsers}")
              end
            '';
            config = ''
              function(_, opts)
                -- require("nvim-treesitter.configs").setup(opts)
                require("nvim-treesitter").setup(opts)

                -- TODO: Why is GLSL filetype in the treesitter setup???

                -- GLSL filetypes
                vim.filetype.add {
                  extension = {
                    vert = "vert",
                    frag = "frag",
                  },
                }

                -- Tell treesitter that those filetypes are GLSL
                vim.treesitter.language.register("glsl", "vert")
                vim.treesitter.language.register("glsl", "frag")
              end
            '';
            opts = {
              auto_install = false;
              ensure_installed = [];
              # parser_install_dir = "${treesitter-parsers}";
              install_dir = "${treesitter-parsers}";

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

              incremental_selection = {
                enable = false;
                keymaps = {
                  "init_selection" = "gnn";
                  "node_decremental" = "grm";
                  "node_incremental" = "grn";
                  "scope_incremental" = "grc";
                };
              };
            };
          };

          trim = rec {
            name = "trim";
            pkg = pkgs.vimPlugins.trim-nvim;
            lazy = false;
            config = mkDefaultConfig name;
          };

          trouble = rec {
            name = "trouble";
            pkg = pkgs.vimPlugins.trouble-nvim;
            lazy = true;
            cmd = ["Trouble" "TroubleToggle"];
            config = mkDefaultConfig name;
          };

          ts-autotag = rec {
            name = "nvim-ts-autotag";
            pkg = pkgs.vimPlugins.nvim-ts-autotag;
            lazy = false;
            config = mkDefaultConfig name;
          };

          typescript-tools = rec {
            name = "typescript-tools";
            pkg = pkgs.vimPlugins.typescript-tools-nvim;
            lazy = true;
            ft = ["javascript" "typescript" "svelte" "html"];
            dependencies = [_plenary lspconfig];
            config = mkDefaultConfig name;
          };

          typst-preview = rec {
            name = "typst-preview";
            pkg = pkgs.vimPlugins.typst-preview-nvim;
            lazy = true;
            ft = ["typst"];
            config = mkDefaultConfig name;
            opts = {
              dependencies_bin.__raw = ''
                {
                  ['tinymist'] = "${pkgs.tinymist}/bin/tinymist",
                  ['websocat'] = "${pkgs.websocat}/bin/websocat"
                }
              '';
              # open_cmd = "qutebrowser %s";
              # open_cmd = "firefox %s -P typst-preview --class typst-preview";
            };
          };

          _promise = {
            name = "promise";
            pkg = pkgs.vimPlugins.promise-async;
            lazy = true;
          };

          ufo = rec {
            name = "ufo";
            pkg = pkgs.vimPlugins.nvim-ufo;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            dependencies = [
              _promise
            ];
            config = mkDefaultConfig name;
          };

          vimtex = {
            name = "vimtex";
            pkg = pkgs.vimPlugins.vimtex;
            init = ''
              function()
                vim.g.vimtex_mappings_enabled = false
                vim.g.vimtex_view_method = "zathura"
                vim.g.vimtex_compiler_latexmk = {
                  options = {
                    "-shell-escape",
                    "-file-line-error",
                    "-synctex=1",
                    "-interaction=nonstopmode",
                  },
                  aux_dir = ".aux",
                  out_dir = ".out",
                }
              end
            '';
          };

          visual-whitespace = rec {
            name = "visual-whitespace";
            pkg = pkgs.vimPlugins.visual-whitespace-nvim;
            event = ["ModeChanged *:[vV\22]"];
            config = mkDefaultConfig name;
            opts = {
              enabled = true;
              highlight = {
                link = "Visual";
                default = true;
              };
              match_types = {
                space = true;
                tab = true;
                nbsp = true;
                lead = false;
                trail = false;
              };
              list_chars = {
                space = "·";
                tab = "↦";
                nbsp = "␣";
                lead = "‹";
                trail = "›";
              };
              fileformat_chars = {
                unix = "↲";
                mac = "←";
                dos = "↙";
              };
            };
          };

          # wakatime = {
          #   name = "wakatime";
          #   pkg = pkgs.vimPlugins.vim-wakatime;
          #   lazy = true;
          #   event = ["BufReadPost" "BufNewFile"];
          # };

          web-devicons = rec {
            name = "nvim-web-devicons";
            pkg = pkgs.vimPlugins.nvim-web-devicons;
            lazy = true;
            config = mkDefaultConfig name;
          };

          _mini = {
            name = "mini";
            pkg = pkgs.vimPlugins.mini-nvim;
            lazy = true;
          };

          which-key = rec {
            name = "which-key";
            pkg = pkgs.vimPlugins.which-key-nvim;
            lazy = false;
            dependencies = [
              _mini
            ];
            priority = 500;
            config = mkDefaultConfig name;
            opts = {
              preset = "helix"; # or "modern"
            };
          };

          window-picker = rec {
            name = "window-picker";
            pkg = pkgs.vimPlugins.nvim-window-picker;
            lazy = true;
            event = ["VeryLazy"];
            config = mkDefaultConfig name;
            opts = {
              hint = "floating-big-letter";
              show_prompt = false;

              filter_rules = {
                autoselect_one = false;
                include_current_win = false;

                bo = {
                  # Ignored filetypes
                  filetype = ["NvimTree" "neo-tree" "notify" "TelescopePrompt" "noice"];
                  # Ignored buffer types
                  buftype = ["terminal" "quickfix"];
                };
              };
            };
          };

          winshift = rec {
            name = "winshift";
            pkg = pkgs.vimPlugins.winshift-nvim;
            lazy = true;
            cmd = ["WinShift"];
            config = mkDefaultConfig name;
            opts = {
              highlight_moving_win = true;

              keymaps = {
                disable_defaults = true;

                win_move_mode = {
                  h = "left";
                  j = "down";
                  k = "up";
                  l = "right";
                };
              };
            };
          };

          yanky = rec {
            name = "yanky";
            pkg = pkgs.vimPlugins.yanky-nvim;
            lazy = true;
            cmd = [
              "YankyClearHistory"
              "YankyRingHistory"
            ];
            config = mkDefaultConfig name;
          };

          yazi = rec {
            name = "yazi";
            pkg = pkgs.vimPlugins.yazi-nvim;
            lazy = true;
            event = ["VeryLazy"];
            dependencies = [_plenary];
            config = mkDefaultConfig name;
            opts = {
              open_for_directories = true;
              highlight_hovered_buffers_in_same_directory = false;

              integrations = {
                grep_in_directory.__raw = ''
                  function(directory)
                    Snacks.picker.grep({dirs={directory}})
                  end
                '';
                picker_add_copy_relative_path_action = "snacks.picker";
              };
            };
          };
        in [
          autopairs # Automatic closing brackets/parens

          # better-escape # Escape with "jk" # NOTE: Bad in lazygit + looses visual selection when correcting too fast

          catppuccin # Colortheme (also add this here to access palettes)
          clangd-extensions # Improved clang LSP support
          blink-cmp # Fast as fuck auto completion
          colorizer # Colorize color strings
          comment # Toggle line- or block-comments
          conform # Auto formatting on save

          # dadbod # Database interface # TODO:
          # dadbod-ui # Dadbod UI # TODO:

          # dap # Debug adapter protocol # TODO:
          # dap-ui # Debugger UI # TODO:
          diffview # Git diff # TODO: Check the keybindings

          direnv # Automatically load local environments
          flash # Highlight f/F search results
          gitsigns # Show git line additions/deletions/changes in the gutter
          haskell-tools # Haskell integration

          # hover # Multiple hover providers

          illuminate # Highlight usages of word under cursor

          intellitab # Indent to the correct level on blanklines # TODO: Behaves bit fishy sometimes

          jdtls # Eclipse JDT language server integration for Java
          lastplace # Reopen a file at the last editing position
          lint # Lint documents on save
          lspconfig # Language server configurations for different languages
          lualine # Status line
          luasnip # Snippets
          ltex-extra # Additional ltex lsp support, e.g. for add-to-dictionary action

          markview # Markdown support # TODO: Disable in help buffers (?) + confiure a bit more

          navbuddy # Structural file view
          neogen # Generate doc comments
          neotree
          noice # Modern UI overhaul, e.g. floating cmdline
          # obsidian # Integration with Obsidian.md

          # overseer # Run tasks from within neovim (e.g. cargo) # TODO:

          persisted # Session management
          presence # Discord rich presence
          quickfix-reflector # Make the quickfix list editable and saveable to apply changes
          rainbow-delimiters # Bracket/Paren colorization
          rustaceanvim # Rust integration
          scope # Buffers scoped to tabpages

          sleuth # Heuristically set indent depth # TODO: See intellitab

          snacks # Lots of QoL
          tabby # Nicer tabline (only showing tabpages)
          todo-comments # Highlight TODOs
          toggleterm # Integrated terminal
          treesitter # AST based syntax highlighting + indentation
          trim # Trim whitespace
          trouble # Diagnostics window
          ts-autotag # Automatic html tag insertion/updating
          typescript-tools # Typescript tsserver LSP
          typst-preview # Typst support
          ufo # Code folding
          vimtex # LaTeX support
          visual-whitespace
          # wakatime # Time tracking
          web-devicons # Icons for many plugins
          which-key # Live keybinding help
          window-picker # Jump to window without multiple <leader-hjkl>
          winshift # Move windows around
          yanky # Clipboard history

          yazi # File manager: TODO: Theming
        ];
      };
    };
  };
}
