{
  lib,
  mylib,
  ...
}: let
  no-leader = [
    {
      mode = "n";
      key = "<C-s>";
      action = "<cmd>w<CR>";
      options.desc = "Save current buffer";
    }
    {
      mode = "n";
      key = "<C-S-s>";
      action = "<cmd>wa<CR>";
      options.desc = "Save all buffers";
    }
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
      options.desc = "Jump down (centered)";
    }
    {
      mode = "n";
      key = "<C-u>";
      action = "<C-u>zz";
      options.desc = "Jump up (centered)";
    }
    {
      mode = "n";
      key = "n";
      action = "nzzzv";
      options.desc = "Next match (centered)";
    }
    {
      mode = "n";
      key = "N";
      action = "Nzzzv";
      options.desc = "Previous match (centered)";
    }
    {
      mode = "i";
      key = "<Tab>";
      action = "<cmd>lua require('intellitab').indent()<CR>";
      options.desc = "Indent (IntelliTab)";
    }
    {
      mode = "i";
      key = "<C-BS>";
      action = "<C-w>";
      options.desc = "Delete previous word"; # TODO: Breaks backspace <C-v><S-i> multiline cursor?
    }
    {
      mode = "i";
      key = "<M-BS>";
      action = "<C-w>";
      options.desc = "Delete previous word"; # TODO: Breaks backspace <C-v><S-i> multiline cursor?
    }
    {
      mode = "i";
      key = "<C-S-v>";
      action = "<Esc>\"+pi";
      options.desc = "Paste from clipboard";
    }
    {
      mode = "i";
      key = "<C-v>";
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
    {
      mode = "n";
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      options.desc = "Show LSP hover";
    }
  ];

  leader = [
    {
      mode = "n";
      key = "<leader>L";
      action = "<cmd>Lazy<CR>";
      options.desc = "Show Lazy";
    }
    {
      mode = "n";
      key = "<leader><Space>";
      action = "<cmd>Telescope buffers<CR>";
      options.desc = "Show open buffers";
    }
    {
      mode = "n";
      key = "<leader>S";
      action = "<cmd>wa<CR>";
      options.desc = "Save all buffers";
    }
    {
      mode = "n";
      key = "<leader>f";
      action = "<cmd>Telescope find_files<CR>";
      options.desc = "Find file";
    }
    {
      mode = "n";
      key = "<leader>o";
      action = "<cmd>Telescope vim_options<CR>";
      options.desc = "Show Vim options";
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
      key = "<leader>n";
      action = "<cmd>Telescope notify<CR>";
      options.desc = "Show notify history";
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
  ];

  leader-quit = [
    {
      mode = "n";
      key = "<leader>q";
      action = "+quit";
    }
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>quitall<CR>";
      options.desc = "Quit";
    }
    {
      mode = "n";
      key = "<leader>q!";
      action = "<cmd>quitall!<CR>";
      options.desc = "Quit forcefully";
    }
  ];

  leader-buffers = [
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
  ];

  leader-windows = [
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
      key = "<leader>w=";
      action = "<C-w>=";
      options.desc = "Balance windows";
    }
    {
      mode = "n";
      key = "<leader>wd";
      action = "<C-w>c";
      options.desc = "Close current window";
    }
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
  ];

  leader-toggles = [
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
    # {
    #   mode = "n";
    #   key = "<leader>tt";
    #   action = "<cmd>CHADopen --nofocus<CR>";
    #   options.desc = "Toggle CHADtree";
    # }
    {
      mode = "n";
      key = "<leader>tn";
      action = "<cmd>Navbuddy<CR>";
      options.desc = "Toggle NavBuddy";
    }
    {
      mode = "n";
      key = "<leader>td";
      action = "<cmd>TroubleToggle focus=false<CR>";
      options.desc = "Toggle Trouble";
    }
  ];

  leader-git = [
    {
      mode = "n";
      key = "<leader>g";
      action = "+git";
    }
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>LazyGit<CR>";
      options.desc = "Show LazyGit";
    }
    {
      mode = "n";
      key = "<leader>gm";
      action = "<cmd>GitMessenger<CR>";
      options.desc = "Show GitMessenger";
    }
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
  ];

  leader-lsp = [
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
  ];

  leader-code = [
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
    {
      mode = "n";
      key = "<leader>cr";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      options.desc = "Rename LSP symbol";
    }
    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      options.desc = "Show LSP code actions";
    }
    {
      mode = "n";
      key = "<leader>cD";
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
      options.desc = "Show LSP line diagnostics";
    }
  ];
in
  builtins.concatLists [
    no-leader
    leader
    leader-quit
    leader-buffers
    leader-windows
    leader-toggles
    leader-git
    leader-lsp
    leader-code
  ]
