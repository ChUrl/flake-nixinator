_: {
  showmode = false; # Status line already shows this
  backspace = ["indent" "eol" "start"];
  termguicolors = true; # Required by multiple plugins
  hidden = true; # Don't unload buffers immediately (required for terminal persistence)
  mouse = "a";
  completeopt = ["menuone" "noselect" "noinsert"];
  timeoutlen = 50; # Controls which-key delay
  pumheight = 0;
  formatexpr = "v:lua.require('conform').formatexpr()";
  laststatus = 3; # Global statusline
  winblend = 30; # Floating popup transparency
  sessionoptions = ["buffers" "curdir" "folds" "globals" "help" "skiprtp" "tabpages" "winsize"]; # What should be saved when creating a session
  showtabline = 2; # Disable tabline with 0, show for > 1 with 1, always show with 2
  conceallevel = 2;

  # Cursor
  ruler = true; # Show cursor position in status line
  number = true;
  relativenumber = true;
  signcolumn = "yes"; # Always show to reduce window jumping
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
  undolevels = 10000;
  # autochdir = true;
  confirm = true;

  # Search
  incsearch = true; # Already highlight results while typing
  hlsearch = true;
  ignorecase = true;
  smartcase = true;
  grepprg = "rg --vimgrep";
  grepformat = "%f:%l:%c:%m";

  # Indentation
  autoindent = true; # Use previous line indentation level - Might mess up comment indentation
  smartindent = true; # Like autoindent but recognizes some C syntax - Might mess up comment indentation
  cindent = false;
  # cinkeys = "0{,0},0),0],:,!^F,o,O,e"; # Fix comment (#) indentation and intellitab (somehow)
  smarttab = true;
  expandtab = true;
  shiftwidth = 4;
  tabstop = 4;
  softtabstop = 4;

  splitbelow = true;
  splitright = true;
}
