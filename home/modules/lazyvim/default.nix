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

      opts = {
        ruler = true; # Show cursor position in status line
        number = true;
        relativenumber = false;
        showmode = false; # Status line already shows this
        backspace = ["indent" "eol" "start"];
        undofile = true;
        undodir = "/home/christoph/.vim/undo"; # TODO: Use username variable
        encoding = "utf-8";

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

      extraPlugins = with pkgs.vimPlugins; [
        lazy-nvim
        vim-airline-themes
        nvim-web-devicons
        # nvim-nio # For rest
      ];

      extraConfigLua = let
        plugins = with pkgs.vimPlugins; [
          # LazyVim
          LazyVim
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
      in ''
        require("lazy").setup({
          defaults = {
            lazy = true,
          },
          dev = {
            -- reuse files from pkgs.vimPlugins.*
            path = "${lazyPath}",
            patterns = { "." },
            -- fallback to download
            fallback = true,
          },
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            -- The following configs are needed for fixing lazyvim on nix
            -- force enable telescope-fzf-native.nvim
            { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
            -- disable mason.nvim, use config.extraPackages
            { "williamboman/mason-lspconfig.nvim", enabled = false },
            { "williamboman/mason.nvim", enabled = false },
            -- uncomment to import/override with your plugins
            -- { import = "plugins" },
            -- put this line at the end of spec to clear ensure_installed
            { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
          },
        })
      '';

      viAlias = cfg.alias;
      vimAlias = cfg.alias;
    };
  };
}
