{
  lib,
  mylib,
  ...
}: {
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
}