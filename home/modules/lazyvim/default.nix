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
  cfg = config.modules.lazyvim;
in {
  options.modules.lazyvim = import ./options.nix {inherit lib mylib;};

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

    home.file.".config/nvim/parser".source = let
      parsers = pkgs.symlinkJoin {
        name = "treesitter-parsers";
        paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
      };
    in "${parsers}/parser";

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
      luaLoader.enable = true;
      # colorschemes.catppuccin.enable = true;
      viAlias = cfg.alias;
      vimAlias = cfg.alias;

      globals = {
        mapleader = " ";
        mallocalleader = " ";
      };

      opts = import ./vim_opts.nix {inherit lib mylib;};
      extraConfigLuaPost = builtins.readFile ./extraConfigLuaPost.lua;

      # extraLuaPackages = with pkgs.lua51Packages; [];

      # extraPython3Packages = p: [
      #   # For CHADtree
      #   p.pyyaml
      #   p.pynvim-pp
      #   p.std2
      # ];

      extraPlugins = with pkgs.vimPlugins; [
        lazy-nvim
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

      extraConfigLua = let
        plugins = with pkgs.vimPlugins; [
          LazyVim # Sets many vim options

          bufferline-nvim
          cmp-buffer
          cmp-nvim-lsp
          cmp-path
          cmp_luasnip
          conform-nvim
          dashboard-nvim
          dressing-nvim
          flash-nvim
          friendly-snippets
          gitsigns-nvim
          indent-blankline-nvim
          lualine-nvim
          neo-tree-nvim
          neoconf-nvim
          neodev-nvim
          noice-nvim
          nui-nvim
          nvim-cmp
          nvim-lint
          nvim-lspconfig
          nvim-notify
          nvim-spectre
          nvim-treesitter
          nvim-treesitter-context
          nvim-treesitter-textobjects
          nvim-ts-autotag
          nvim-ts-context-commentstring
          nvim-web-devicons
          persistence-nvim
          plenary-nvim
          telescope-fzf-native-nvim
          telescope-nvim
          todo-comments-nvim
          tokyonight-nvim
          trouble-nvim
          vim-illuminate
          vim-startuptime
          which-key-nvim
          {
            name = "LuaSnip";
            path = luasnip;
          }
          {
            name = "catppuccin";
            path = catppuccin-nvim;
          }
          {
            name = "mini.ai";
            path = mini-nvim;
          }
          {
            name = "mini.bufremove";
            path = mini-nvim;
          }
          {
            name = "mini.comment";
            path = mini-nvim;
          }
          {
            name = "mini.indentscope";
            path = mini-nvim;
          }
          {
            name = "mini.pairs";
            path = mini-nvim;
          }
          {
            name = "mini.surround";
            path = mini-nvim;
          }
        ];

        mkEntryFromDrv = drv:
          if lib.isDerivation drv
          then {
            name = "${lib.getName drv}";
            path = drv;
          }
          else drv;

        lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
      in (
        builtins.replaceStrings
        ["@lazyPath@"]
        ["${lazyPath}"]
        (builtins.readFile ./extraConfigLua.lua)
      );
    };
  };
}
