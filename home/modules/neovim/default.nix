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
  options.modules.neovim = import ./options.nix { inherit lib mylib; };

  config = mkIf cfg.enable {
    # TODO: Configure by option
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    programs.neovim = {
      enable = true;

      extraConfig = ''
        set incsearch
        set hlsearch
        set ignorecase
        set autoindent
        set expandtab
        set smartindent
        set smarttab
        set shiftwidth=4
        set softtabstop=4
        set backspace=indent,eol,start
        set ruler
        set number
        set laststatus=2
        set noshowmode
        set undofile
        set undodir=~/.vim/undo
        set hidden
        set printfont=Victor\ Mono\ SemiBold:h10
        set guifont=Victor\ Mono\ SemiBold:h12
        let printencoding='utf-8'
        set encoding=utf-8
      '';

      plugins = with pkgs.vimPlugins; [
        # vim-nix
        # YouCompleteMe
        surround-nvim

        {
          plugin = lualine-nvim;
          config = ''
            lua << EOF
            require('lualine').setup {}
            EOF
          '';
        }

        {
          plugin = nvim-autopairs;
          config = ''
            lua << EOF
            require('nvim-autopairs').setup {}
            EOF
          '';
        }

        {
          plugin = nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars);
          config = ''
            lua << EOF
            require('nvim-treesitter.configs').setup {
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            }
            EOF
          '';
        }
      ];

      viAlias = cfg.alias;
      vimAlias = cfg.alias;
    };
  };
}
