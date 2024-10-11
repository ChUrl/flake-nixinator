{
  username,
  hostname,
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
            nixd
            pyright
            rust-analyzer
            texlab
            ltex-ls

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

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      enableMan = false; # Nixvim man pages
      luaLoader.enable = true; # NOTE: Experimental
      viAlias = cfg.alias;
      vimAlias = cfg.alias;

      colorschemes.catppuccin = {
        enable = true;
        settings = {
          flavour = "mocha"; # latte, frappe, macchiato, mocha
          background = {
            light = "latte";
            dark = "mocha";
          };
        };
      };

      performance.byteCompileLua = {
        enable = true;
        configs = true;
        initLua = true;
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

      extraFiles = {
        # For this its probably important to set the default filetype to tex (see extraConfigLua)
        "ftplugin/tex/mappings.lua".text = mylib.generators.toLuaKeymap (import ./mappings_latex.nix {});
        "ftplugin/markdown/mappings.lua".text = mylib.generators.toLuaKeymap (import ./mappings_markdown.nix {});
      };

      # extraLuaPackages = with pkgs.lua51Packages; [];
      # extraPython3Packages = p: [];

      autoCmd = [
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
        {
          desc = "Enable line wrapping in telescope preview";
          event = ["User"];
          pattern = ["TelescopePreviewerLoaded"];
          callback.__raw = ''
            function(args)
              if args.data.bufname:match("*.csv") then
                vim.wo.wrap = false
              else
                vim.wo.wrap = true
              end
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

          bbye = {
            name = "vim-bbye";
            pkg = pkgs.vimPlugins.vim-bbye;
            lazy = true;
            cmd = ["Bdelete" "Bwipeout"];
          };

          better-escape = rec {
            name = "better_escape";
            pkg = pkgs.vimPlugins.better-escape-nvim;
            lazy = true;
            event = ["InsertEnter"];
            config = mkDefaultConfig name;
            opts = {
              # mapping = ["jk"]; # NOTE: Deprecated
              default_mappings = true;
              timeout = 200; # In ms
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

          # _cmp-nvim-lsp-signature-help = {
          #   name = "cmp-nvim-lsp-signature-help";
          #   pkg = pkgs.vimPlugins.cmp-nvim-lsp-signature-help;
          #   lazy = true;
          # };

          _cmp-luasnip = {
            name = "cmp_luasnip";
            pkg = pkgs.vimPlugins.cmp_luasnip;
            lazy = true;
          };

          cmp = rec {
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
              # _cmp-nvim-lsp-signature-help
              _cmp-luasnip
            ];
            config = mkDefaultConfig name;
            opts.__raw = let
              sources = mylib.generators.toLuaObject [
                {name = "async_path";}
                {name = "emoji";}
                {name = "nvim_lsp";}
                {name = "luasnip";}

                # {name = "nvim_lsp_signature_help";} # Already provided by something else (noice?)
                # {name = "buffer";} # Too much noise
                # {name = "cmdline";} # Using nui as cmdline completion backend
              ];

              mapping = mylib.generators.toLuaObject {
                "<Down>".__raw = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select })";
                "<Up>".__raw = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select })";
                "<C-e>".__raw = "cmp.mapping.abort()";
                "<Esc>".__raw = "cmp.mapping.abort()";
                "<C-Up>".__raw = "cmp.mapping.scroll_docs(-4)";
                "<C-Down>".__raw = "cmp.mapping.scroll_docs(4)";
                "<C-Space>".__raw = "cmp.mapping.complete({})";
                "<CR>".__raw = ''
                  cmp.mapping(function(fallback)
                    if cmp.visible() then
                      if luasnip.expandable() then
                        luasnip.expand()
                      else
                        cmp.confirm({select = true})
                      end
                    else
                      fallback()
                    end
                  end)
                '';
                "<Tab>".__raw = ''
                  cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif luasnip.locally_jumpable(1) then
                      luasnip.jump(1)
                    else
                      fallback() -- This will call the intellitab <Tab> binding
                    end
                  end, { "i", "s" })
                '';
                "<S-Tab>".__raw = ''
                  cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    elseif luasnip.locally_jumpable(-1) then
                      luasnip.jump(-1)
                    else
                      fallback()
                    end
                  end, { "i", "s" })
                '';
              };
            in ''
              function()
                local cmp = require("${name}")
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

          # colorizer = rec {
          #   name = "colorizer";
          #   pkg = pkgs.vimPlugins.nvim-colorizer-lua;
          #   lazy = true;
          #   event = ["BufReadPost" "BufNewFile"];
          #   config = (mkDefaultConfig name);
          #   opts = {
          #     filtetypes = null;
          #     user_default_options = null;
          #     buftypes = null;
          #   };
          # };

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

          # TODO: Don't autosave, but if a session exists, update it (using should_autosave)
          _persisted = {
            name = "persisted";
            pkg = pkgs.vimPlugins.persisted-nvim;
            dependencies = [telescope];
            lazy = true;
            cmd = ["SessionSave" "SessionDelete" "Telescope persisted"];
            config = ''
              function(_, opts)
                require("persisted").setup(opts)

                require("telescope").load_extension("persisted")
              end
            '';
            opts = {
              silent = false;
              use_git_branch = false;
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

          direnv = {
            name = "direnv";
            pkg = pkgs.vimPlugins.direnv-vim;
            lazy = false;
          };

          dashboard = rec {
            name = "dashboard";
            pkg = pkgs.vimPlugins.dashboard-nvim;
            dependencies = [
              web-devicons
              _persisted
            ];
            lazy = false;
            config = mkDefaultConfig name;
            opts = {
              theme = "doom";
              disable_move = true;
              shortcut_type = "number";

              config = {
                center = [
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
                    action = "ObsidianSearch";
                    desc = " Obsidian Note";
                    icon = " ";
                    key = "o";
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

          flash = rec {
            name = "flash";
            pkg = pkgs.vimPlugins.flash-nvim;
            lazy = true;
            keys = ["f" "F"];
            config = mkDefaultConfig name;
          };

          gitmessenger = {
            name = "gitmessenger";
            pkg = pkgs.vimPlugins.git-messenger-vim;
            lazy = true;
            cmd = ["GitMessenger"];
            init = let
              mappings = mylib.generators.toLuaObject {
                git_messenger_no_default_mappings = true;
                git_messenger_floating_win_opts = {
                  border = "rounded";
                };
              };
            in ''
              function()
                for k, v in pairs(${mappings}) do
                  vim.g[k] = v
                end
              end
            '';
          };

          gitsigns = rec {
            name = "gitsigns";
            pkg = pkgs.vimPlugins.gitsigns-nvim;
            lazy = true;
            event = ["BufReadPost" "BufNewFile"];
            config = mkDefaultConfig name;
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

          # incline = {
          #   name = "incline";
          #   pkg = let
          #     nvim-incline = pkgs.vimUtils.buildVimPlugin {
          #       name = "nvim-incline";
          #       src = pkgs.fetchFromGitHub {
          #         owner = "b0o";
          #         repo = "incline.nvim";
          #         rev = "16fc9c073e3ea4175b66ad94375df6d73fc114c0";
          #         sha256 = "sha256-5DoIvIdAZV7ZgmQO2XmbM3G+nNn4tAumsShoN3rDGrs=";
          #       };
          #     };
          #   in
          #     nvim-incline;
          #   dependencies = [_navic];
          #   lazy = true;
          #   event = ["BufReadPost" "BufNewFile"];
          #   config = ''
          #     function(_, opts)
          #       require("incline").setup(opts)
          #     end
          #   '';
          #   opts = {
          #     window = {
          #       padding = 0;
          #       margin = {
          #         horizontal = 0;
          #         vertical = 0;
          #       };
          #     };
          #
          #     render.__raw = builtins.readFile ./inclineNavic.lua;
          #   };
          # };

          intellitab = {
            name = "intellitab";
            # pkg = pkgs.vimPlugins.intellitab-nvim; # Prints at each indent :(
            pkg = pkgs.vimUtils.buildVimPlugin {
              name = "intellitab-nvim";
              src = pkgs.fetchFromGitHub {
                owner = "ChUrl";
                repo = "intellitab.nvim";
                rev = "6d644b7d92198477f2920d0c3b3b22dad470ef10"; # Disable print
                sha256 = "sha256-MwBcsYpyrjoXa7nxcwaci3h0NIWyMoF1NyYfEbFzo0E=";
              };
            };
            lazy = true;
            event = ["InsertEnter"];
          };

          jdtls = {
            name = "jdtls";
            pkg = pkgs.vimPlugins.nvim-jdtls;
            lazy = false; # Is only ever loaded in Java buffers anyway
            # NOTE: The below stuff is configured in the AutoCMD
            # ft = ["Java" "java"];
            # config = ''
            #   function(_, opts)
            #     require('jdtls').start_or_attach(opts)
            #   end
            # '';
            # opts = {
            #   cmd.__raw = ''
            #     {
            #       "jdtls",
            #       "-data",
            #       "/home/christoph/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t"),
            #     }
            #   '';
            #   root_dir.__raw = "vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1])";
            # };
          };

          lastplace = rec {
            name = "nvim-lastplace";
            pkg = pkgs.vimPlugins.nvim-lastplace;
            lazy = false;
            config = mkDefaultConfig name;
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
                nix = ["statix"];
                python = ["flake8"];
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
          lspconfig = {
            name = "lspconfig";
            pkg = pkgs.vimPlugins.nvim-lspconfig;
            lazy = true;
            cmd = ["LspInfo"];
            event = ["BufReadPost" "BufNewFile"];
            dependencies = [_lazydev];
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
                # {name = "nil_ls";} # TODO: To use together with nixd, its hover functionality needs to be disabled to not conflict
                {
                  name = "ltex";
                  extraOptions.settings = {
                    ltex = {
                      checkFrequency = "save";
                    };
                  };
                }
                {
                  name = "nixd";
                  # TODO: Figure out how to structure this attrset
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
                        home_manager = {
                          expr = "(builtins.getFlake \"/home/${username}/NixFlake\").homeConfigurations.\"${username}@${hostname}\".options";
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
                {name = "pyright";}
                {name = "texlab";}

                # {name = "jdtls";} # Don't set up when using nvim-jdtls
                # {name = "rust_analyzer";} # Don't set up when using rustaceanvim
                # {name = "hls";} # Don't set up when using haskell-tools
              ];
            in ''
              function(_, opts)
                -- Make LspInfo window border rounded
                require("lspconfig.ui.windows").default_options.border = "rounded"

                local __lspOnAttach = function(client, bufnr)
                  -- NOTE: The ltex-extra package needs to be loaded in ltex's onAttach.
                  --       I don't know how to do this more declaratively with the current structure.
                  if client.name == "ltex" then
                    require("ltex_extra").setup({})
                  end
                end

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
              extensions = ["fzf" "neo-tree" "toggleterm" "trouble"];

              options = {
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

          # narrow-region = {
          #   name = "narrow-region";
          #   pkg = pkgs.vimPlugins.NrrwRgn;
          #   lazy = true;
          #   cmd = ["NR"];
          #   config = ''
          #     function(_, opts)
          #       vim.keymap.del("x", "<space>Nr")
          #       vim.keymap.del("x", "<space>nr")
          #       vim.keymap.del("n", "<space>nr")
          #     end
          #   '';
          # };

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

          neo-tree = rec {
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

          _notify = {
            name = "notify";
            pkg = pkgs.vimPlugins.nvim-notify;
            lazy = true;
            config = ''
              function(_, opts)
                local notify = require("notify")

                notify.setup(opts)
                vim.notify = notify -- Vim uses notify by default
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

          noice = rec {
            name = "noice";
            pkg = pkgs.vimPlugins.noice-nvim;
            lazy = false;
            dependencies = [
              _notify
              _nui
            ];
            config = mkDefaultConfig name;
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

          obsidian = rec {
            name = "obsidian";
            pkg = pkgs.vimPlugins.obsidian-nvim;
            lazy = true;
            cmd = ["ObsidianSearch" "ObsidianNew"];
            ft = ["markdown"];
            dependencies = [
              _plenary
            ];
            config = mkDefaultConfig name;
            opts = {
              workspaces = [
                {
                  name = "Chriphost";
                  path = "~/Notes/Obsidian/Chriphost";
                }
              ];
            };
          };

          oil = rec {
            name = "oil";
            pkg = pkgs.vimPlugins.oil-nvim;
            lazy = false;
            config = mkDefaultConfig name;
            opts = {
              default_file_explorer = true;
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
                wrap_results = false; # Do wrapping in the preview instead, see autoCmd
                preview = {
                  treesitter = true;
                };
                mappings = {
                  i = {
                    "<Esc>" = {__raw = ''function(...) return require("telescope.actions").close(...) end'';};
                  };
                };
              };
            };
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
              persist_mode = true;
              insert_mappings = true;
              close_on_exit = true;
              shell = "fish";
              direction = "horizontal"; # 'vertical' | 'horizontal' | 'window' | 'float'
              auto_scroll = true;
              float_opts = {
                border = "curved"; # 'single' | 'double' | 'shadow' | 'curved'
                width = 80;
                height = 45;
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
            lazy = true;
            cmd = ["TSModuleInfo"];
            event = ["BufReadPost" "BufNewFile"];
            init = ''
              function()
                -- Fix treesitter grammars/parsers on nix
                vim.opt.runtimepath:append("${nvim-plugintree}")
                vim.opt.runtimepath:append("${treesitter-parsers}")
              end
            '';
            config = ''
              function(_, opts)
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

          _promise = {
            name = "promise";
            pkg = pkgs.vimPlugins.promise-async;
            lazy = true;
          };

          ufo = rec {
            name = "ufo";
            pkg = pkgs.vimPlugins.nvim-ufo;
            lazy = false;
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

          wakatime = {
            name = "wakatime";
            pkg = pkgs.vimPlugins.vim-wakatime;
          };

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
        in [
          autopairs # Automatic closing brackets/parens
          bbye # Delete buffer without closing the window or split
          better-escape # Escape to normal mode using "jk"
          clangd-extensions

          # blink-cmp # Auto completion popups # TODO: Try this instead of cmp

          cmp # Auto completion popups

          # colorizer # Colorize color strings # TODO: Only colorize html/css/scss/sass/js

          comment # Toggle line- or block-comments
          conform # Auto formatting on save
          dashboard # Dashboard when starting nvim

          diffview # Git diff # TODO: Check the keybindings

          direnv # Automatically load local environments
          flash # Highlight f/F search results
          gitmessenger # Show last git commit for the current line
          gitsigns # Show git line additions/deletions/changes in the gutter
          haskell-tools # Haskell integration
          illuminate # Highlight usages of word under cursor

          # incline # Statuslines for each window # TODO: Cool but bad styling

          intellitab # Indent to the correct level on blanklines
          jdtls # Eclipse JDT language server integration for Java
          lastplace # Reopen a file at the last editing position
          lazygit # Git frontend
          lint # Lint documents on save
          lspconfig # Language server configurations for different languages
          lualine # Status line

          luasnip # Snippets # TODO: How to add snippets, maybe use luasnip from nixvim directly?

          ltex-extra # Additional ltex lsp support, e.g. for add-to-dictionary action

          markview # Markdown support # TODO: Disable in help buffers + confiure a bit more

          # narrow-region # Open a buffer restricted to the selection
          navbuddy # Structural file view
          neo-tree # File tree sidebar
          noice # Modern UI overhaul, e.g. floating cmdline
          obsidian # Integration with Obsidian.md
          oil # File manager
          rainbow-delimiters # Bracket/Paren colorization
          rustaceanvim # Rust integration
          sleuth # Heuristically set indent depth
          telescope # Option picker frontend
          todo-comments # Highlight TODOs
          toggleterm # Integrated terminal
          treesitter # AST based syntax highlighting + indentation
          trim # Trim whitespace
          trouble # Diagnostics window
          ufo # Code folding
          vimtex # LaTeX support
          wakatime # Time tracking
          web-devicons
          which-key # Live keybinding help
          winshift # Move windows around
          yanky # Clipboard history
        ];
      };
    };
  };
}
