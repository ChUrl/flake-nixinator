{...}: let
  no-leader = [
    # Cursor movement
    {
      mode = "n";
      key = "j";
      action = "v:count == 0 ? 'gj' : 'j'";
      options.desc = "Move cursor down";
      options.expr = true;
    }
    {
      mode = "n";
      key = "<Down>";
      action = "v:count == 0 ? 'gj' : 'j'";
      options.desc = "Move cursor down";
      options.expr = true;
    }
    {
      mode = "n";
      key = "k";
      action = "v:count == 0 ? 'gk' : 'k'";
      options.desc = "Move cursor up";
      options.expr = true;
    }
    {
      mode = "n";
      key = "<Up>";
      action = "v:count == 0 ? 'gk' : 'k'";
      options.desc = "Move cursor up";
      options.expr = true;
    }

    # Window resize
    {
      mode = "n";
      key = "<C-h>";
      action = "<cmd>vertical resize -2<cr>";
      options.desc = "Decrease window width";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<cmd>vertical resize +2<cr>";
      options.desc = "Increase window width";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<cmd>resize -2<cr>";
      options.desc = "Decrease window height";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<cmd>resize +2<cr>";
      options.desc = "Increase window height";
    }

    # Move lines
    {
      mode = "n";
      key = "<M-j>";
      action = "<cmd>m .+1<cr>==";
      options.desc = "Move line down";
    }
    {
      mode = "i";
      key = "<M-j>";
      action = "<Esc><cmd>m .+1<cr>==gi";
      options.desc = "Move line down";
    }
    {
      mode = "v";
      key = "<M-j>";
      action = ":m '>+1<cr>gv=gv";
      options.desc = "Move line down";
    }
    {
      mode = "n";
      key = "<M-k>";
      action = "<cmd>m .-2<cr>==";
      options.desc = "Move line up";
    }
    {
      mode = "i";
      key = "<M-k>";
      action = "<Esc><cmd>m .-2<cr>==gi";
      options.desc = "Move line up";
    }
    {
      mode = "v";
      key = "<M-k>";
      action = ":m '<-2<cr>gv=gv";
      options.desc = "Move line up";
    }

    # Save buffers
    {
      mode = ["n" "i" "v"];
      key = "<C-s>";
      action = "<cmd>w<cr>";
      options.desc = "Save current buffer";
    }
    {
      mode = ["n" "i" "v"];
      key = "<C-S-s>";
      action = "<cmd>wa<cr>";
      options.desc = "Save all buffers";
    }

    # Indentation
    {
      mode = "v";
      key = "<";
      action = "<gv";
      options.desc = "Outdent";
    }
    {
      mode = "n";
      key = "<";
      action = "v<<Esc>";
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
      key = ">";
      action = "v><Esc>";
      options.desc = "Indent";
    }
    {
      mode = "i";
      key = "<Tab>";
      action = "<cmd>lua require('intellitab').indent()<cr>";
      options.desc = "Indent (IntelliTab)";
    }

    # Centered jumping
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

    # Delete word
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

    # Clipboard
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

    # Flash/Search
    {
      mode = "n";
      key = "s";
      action = "<cmd>lua require('flash').jump()<cr>";
      options.desc = "Flash jump";
    }
    {
      mode = "n";
      key = "S";
      action = "<cmd>lua require('flash').treesitter()<cr>";
      options.desc = "Flash treesitter";
    }

    # Various
    {
      mode = "n";
      key = "<C-S-h>";
      action = "<cmd>nohlsearch<cr>";
      options.desc = "Clear search highlights";
    }

    {
      mode = "n";
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      options.desc = "Show LSP hover";
    }

    {
      mode = "n";
      key = "/";
      action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
      options.desc = "Find in current buffer";
    }

    {
      mode = "v";
      key = ";";
      action = "<Esc>";
      options.desc = "Exit visual mode";
    }
  ];

  leader = [
    {
      mode = "n";
      key = "<leader>L";
      action = "<cmd>Lazy<cr>";
      options.desc = "Show Lazy";
    }

    # Already have <C-s> and <C-S-s>
    # {
    #   mode = "n";
    #   key = "<leader>s";
    #   action = "<cmd>w<cr>";
    #   options.desc = "Save current buffer";
    # }
    # {
    #   mode = "n";
    #   key = "<leader>S";
    #   action = "<cmd>wa<cr>";
    #   options.desc = "Save all buffers";
    # }

    {
      mode = "n";
      key = "<leader>R";
      action = "<cmd>edit!<cr>";
      options.desc = "Reload current buffer";
    }

    {
      mode = "n";
      key = "<leader><Space>";
      action = "<cmd>Telescope buffers<cr>";
      options.desc = "Show open buffers";
    }
    {
      mode = "n";
      key = "<leader>f";
      action = "<cmd>Telescope find_files<cr>";
      options.desc = "Find file";
    }
    {
      mode = "n";
      key = "<leader>p";
      action = "<cmd>Telescope projects<cr>";
      options.desc = "Open project";
    }
    {
      mode = "n";
      key = "<leader>o";
      action = "<cmd>Telescope vim_options<cr>";
      options.desc = "Show Vim options";
    }
    {
      mode = "n";
      key = "<leader>u";
      action = "<cmd>Telescope undo<cr>";
      options.desc = "Show undo history";
    }
    {
      mode = "n";
      key = "<leader>/";
      action = "<cmd>Telescope live_grep<cr>";
      options.desc = "Find in working directory";
    }
    {
      mode = "v";
      key = "<leader>n";
      action = ":NR!<cr>";
      options.desc = "Narrow region";
    }
    {
      mode = "n";
      key = "<leader>N";
      action = "<cmd>Telescope notify<cr>";
      options.desc = "Show notify history";
    }
    {
      mode = "n";
      key = "<leader>r";
      action = "<cmd>Telescope resume<cr>";
      options.desc = "Show last telescope picker";
    }
    {
      mode = "n";
      key = "<leader>?";
      action = "<cmd>Telescope keymaps<cr>";
      options.desc = "Show keymaps";
    }
    {
      mode = "n";
      key = "<leader>:";
      action = "<cmd>Telescope commands<cr>";
      options.desc = "Execute command";
    }
    {
      mode = "n";
      key = "<leader>M";
      action = "<cmd>Telescope marks<cr>";
      options.desc = "Show marks";
    }
    {
      mode = "n";
      key = "<leader>J";
      action = "<cmd>Telescope jumplist<cr>";
      options.desc = "Show jumplist";
    }
    {
      mode = "n";
      key = "<leader>m";
      action = "<cmd>Telescope man_pages<cr>";
      options.desc = "Show manpages";
    }
    {
      mode = "n";
      key = "<leader>h";
      action = "<cmd>Telescope help_tags<cr>";
      options.desc = "Show help tags";
    }
    {
      mode = "n";
      key = "<leader>T";
      action = "<cmd>TodoTelescope<cr>";
      options.desc = "Show TODOs";
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
      action = "<cmd>quitall<cr>";
      options.desc = "Quit";
    }
    {
      mode = "n";
      key = "<leader>q!";
      action = "<cmd>quitall!<cr>";
      options.desc = "Quit forcefully";
    }
  ];

  leader-session = [
    {
      mode = "n";
      key = "<leader>s";
      action = "+session";
    }
    {
      mode = "n";
      key = "<leader>sl";
      action = "<cmd>Telescope persisted<cr>";
      options.desc = "Restore session";
    }
    {
      mode = "n";
      key = "<leader>ss";
      action = "<cmd>SessionSave<cr>";
      options.desc = "Save session";
    }
    {
      mode = "n";
      key = "<leader>sd";
      action = "<cmd>SessionDelete<cr>";
      options.desc = "Delete current session";
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
      action = "<cmd>Telescope buffers<cr>";
      options.desc = "Show open buffers";
    }
    {
      mode = "n";
      key = "<leader>bn";
      action = "<cmd>bnext<cr>";
      options.desc = "Goto next buffer";
    }
    {
      mode = "n";
      key = "<leader>bp";
      action = "<cmd>bprevious<cr>";
      options.desc = "Goto previous buffer";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>Bdelete<cr>";
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
      key = "<leader>wd";
      action = "<C-w>c";
      options.desc = "Close current window";
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

    {
      mode = "n";
      key = "<leader>wm";
      action = "<cmd>WinShift<cr>";
      options.desc = "Move window";
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
      action = "<cmd>Neotree action=show toggle=true<cr><C-w>=";
      options.desc = "Toggle NeoTree";
    }
    # {
    #   mode = "n";
    #   key = "<leader>tt";
    #   action = "<cmd>CHADopen --nofocus<cr>";
    #   options.desc = "Toggle CHADtree";
    # }
    {
      mode = "n";
      key = "<leader>tn";
      action = "<cmd>Navbuddy<cr>";
      options.desc = "Toggle NavBuddy";
    }
    {
      mode = "n";
      key = "<leader>td";
      action = "<cmd>Trouble diagnostics toggle focus=false win.position=bottom<cr>";
      options.desc = "Toggle Trouble diagnostics";
    }
    {
      mode = "n";
      key = "<leader>tT";
      action = "<cmd>Trouble todo toggle focus=false win.position=right<cr>";
      options.desc = "Toggle Trouble TODOs";
    }
    {
      mode = "n";
      key = "<leader>ts";
      action = "<cmd>Trouble symbols toggle focus=false win.position=right<cr>";
      options.desc = "Toggle Trouble symbols";
    }

    {
      mode = "n";
      key = "<leader>tf";
      action = "<cmd>ToggleAutoformat<cr>";
      options.desc = "Toggle autoformat-on-save";
    }

    {
      mode = "n";
      key = "<leader>tl";
      action = "<cmd>ToggleAutoLint<cr>";
      options.desc = "Toggle autolint-on-save";
    }

    {
      mode = "n";
      key = "<leader>tD";
      action = "<cmd>ToggleInlineDiagnostics<cr>";
      options.desc = "Toggle inline diagnostics";
    }

    {
      mode = "n";
      key = "<leader>tw";
      action = "<cmd>:set wrap!<cr>";
      options.desc = "Toggle word-wrap";
    }
    {
      mode = "n";
      key = "<leader>tv";
      action = "<cmd>VimtexTocToggle<cr>";
      options.desc = "Toggle Vimtex ToC";
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
      action = "<cmd>LazyGit<cr>";
      options.desc = "Show LazyGit";
    }
    {
      mode = "n";
      key = "<leader>gm";
      action = "<cmd>GitMessenger<cr>";
      options.desc = "Show GitMessenger";
    }

    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>Telescope git_status<cr>";
      options.desc = "Show Git status";
    }
    {
      mode = "n";
      key = "<leader>gc";
      action = "<cmd>Telescope git_commits<cr>";
      options.desc = "Show Git log";
    }
    {
      mode = "n";
      key = "<leader>gb";
      action = "<cmd>Telescope git_branches<cr>";
      options.desc = "Show Git branches";
    }
    {
      mode = "n";
      key = "<leader>gf";
      action = "<cmd>Telescope git_bcommits<cr>";
      options.desc = "Show Git log for current file";
    }
    {
      mode = "n";
      key = "<leader>gd";
      action = "<cmd>DiffviewOpen<cr>";
      options.desc = "Show Git diff for current worktree";
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
      action = "<cmd>Telescope lsp_references<cr>";
      options.desc = "Goto references";
    }
    {
      mode = "n";
      key = "<leader>ld";
      action = "<cmd>Telescope lsp_definitions<cr>";
      options.desc = "Goto definition";
    }
    {
      mode = "n";
      key = "<leader>li";
      action = "<cmd>Telescope lsp_implementations<cr>";
      options.desc = "Goto implementation";
    }
    {
      mode = "n";
      key = "<leader>lt";
      action = "<cmd>Telescope lsp_type_definitions<cr>";
      options.desc = "Goto type definition";
    }
    {
      mode = "n";
      key = "<leader>lI";
      action = "<cmd>Telescope lsp_incoming_calls<cr>";
      options.desc = "Show incoming calls";
    }
    {
      mode = "n";
      key = "<leader>lO";
      action = "<cmd>Telescope lsp_outgoing_calls<cr>";
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
      action = "<cmd>lua require('conform').format()<cr>";
      options.desc = "Format current buffer";
    }

    {
      mode = "n";
      key = "<leader>cd";
      action = "<cmd>lua vim.diagnostic.open_float()<cr>";
      options.desc = "Show LSP line diagnostics";
    }
    {
      mode = "n";
      key = "<leader>cD";
      action = "<cmd>Telescope diagnostics<cr>";
      options.desc = "Show diagnostics";
    }

    {
      mode = "n";
      key = "<leader>cr";
      action = "<cmd>lua vim.lsp.buf.rename()<cr>";
      options.desc = "Rename LSP symbol";
    }
    # {
    #   mode = "n";
    #   key = "<leader>cr";
    #   action = ":IncRename ";
    #   options.desc = "Rename LSP symbol";
    # }
    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
      options.desc = "Show LSP code actions";
    }
    {
      mode = "n";
      key = "<leader>ch";
      action = "<cmd>ClangdSwitchSourceHeader<cr>";
      options.desc = "Switch C/C++ source/header";
    }
  ];
in
  builtins.concatLists [
    no-leader
    leader
    leader-quit
    leader-session
    leader-buffers
    leader-windows
    leader-toggles
    leader-git
    leader-lsp
    leader-code
  ]
