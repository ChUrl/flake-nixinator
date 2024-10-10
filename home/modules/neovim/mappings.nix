{...}: let
  disabled-mappings = let
    mkDisabledMapping = mapping: {
      key = mapping;
      action = "<Nop>";
    };

    disableMappings = [
      # I only use f and F together with flash.nvim and s and S with sneak
      "t"
      "T"
    ];
  in
    builtins.map mkDisabledMapping disableMappings;

  no-leader = [
    # Cursor movement
    {
      mode = "n";
      key = "j";
      action = "v:count == 0 ? 'gj' : 'j'";
      options.desc = "Move Cursor Down";
      options.expr = true;
    }
    {
      mode = "n";
      key = "<Down>";
      action = "v:count == 0 ? 'gj' : 'j'";
      options.desc = "Move Cursor Down";
      options.expr = true;
    }
    {
      mode = "n";
      key = "k";
      action = "v:count == 0 ? 'gk' : 'k'";
      options.desc = "Move Cursor Up";
      options.expr = true;
    }
    {
      mode = "n";
      key = "<Up>";
      action = "v:count == 0 ? 'gk' : 'k'";
      options.desc = "Move Cursor Up";
      options.expr = true;
    }

    # Window resize
    {
      mode = "n";
      key = "<C-h>";
      action = "<cmd>vertical resize -2<cr>";
      options.desc = "Decrease Window Width";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<cmd>vertical resize +2<cr>";
      options.desc = "Increase Window Width";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<cmd>resize -2<cr>";
      options.desc = "Decrease Window Height";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<cmd>resize +2<cr>";
      options.desc = "Increase Window Height";
    }

    # Move lines
    {
      mode = "n";
      key = "<M-j>";
      action = "<cmd>m .+1<cr>==";
      options.desc = "Move Line Down";
    }
    {
      mode = "i";
      key = "<M-j>";
      action = "<Esc><cmd>m .+1<cr>==gi";
      options.desc = "Move Line Down";
    }
    {
      mode = "v";
      key = "<M-j>";
      action = ":m '>+1<cr>gv=gv";
      options.desc = "Move Line Down";
    }
    {
      mode = "n";
      key = "<M-k>";
      action = "<cmd>m .-2<cr>==";
      options.desc = "Move Line Up";
    }
    {
      mode = "i";
      key = "<M-k>";
      action = "<Esc><cmd>m .-2<cr>==gi";
      options.desc = "Move Line Up";
    }
    {
      mode = "v";
      key = "<M-k>";
      action = ":m '<-2<cr>gv=gv";
      options.desc = "Move Line Up";
    }

    # Save buffers
    {
      mode = ["n" "i" "v"];
      key = "<C-s>";
      action = "<cmd>w<cr>";
      options.desc = "Save Buffer";
    }
    {
      mode = ["n" "i" "v"];
      key = "<C-S-s>";
      action = "<cmd>wa<cr>";
      options.desc = "Save All Buffers";
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
      options.desc = "Jump Down (Centered)";
    }
    {
      mode = "n";
      key = "<C-u>";
      action = "<C-u>zz";
      options.desc = "Jump Up (Centered)";
    }
    {
      mode = "n";
      key = "n";
      action = "nzzzv";
      options.desc = "Next Match (Centered)";
    }
    {
      mode = "n";
      key = "N";
      action = "Nzzzv";
      options.desc = "Previous Match (Centered)";
    }

    # Delete word
    {
      mode = "i";
      key = "<C-BS>";
      action = "<C-w>";
      options.desc = "Delete Previous Word"; # TODO: Breaks backspace <C-v><S-i> multiline cursor?
    }
    {
      mode = "i";
      key = "<M-BS>";
      action = "<C-w>";
      options.desc = "Delete Previous Word"; # TODO: Breaks backspace <C-v><S-i> multiline cursor?
    }

    # Clipboard
    {
      mode = "i";
      key = "<C-S-v>";
      action = "<Esc>\"+pi";
      options.desc = "Paste";
    }
    {
      mode = "i";
      key = "<C-v>";
      action = "<Esc>\"+pi";
      options.desc = "Paste";
    }
    {
      mode = "v";
      key = "<C-S-c>";
      action = "\"+y";
      options.desc = "Copy";
    }
    {
      mode = "n";
      key = "<C-p>";
      action = "<cmd>YankyRingHistory<cr>";
      options.desc = "Paste (Yanky)";
    }
    {
      mode = "n";
      key = "<C-S-p>";
      action = "<cmd>YankyClearHistory<cr>";
      options.desc = "Clear Yanky History";
    }

    # Various
    {
      mode = "n";
      key = "<C-S-h>";
      action = "<cmd>nohlsearch<cr>";
      options.desc = "Clear Search Highlights";
    }
    {
      mode = "n";
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      options.desc = "LSP Hover";
    }
    {
      mode = "n";
      key = "/";
      action = "<cmd>Telescope current_buffer_fuzzy_find<cr>";
      options.desc = "Grep Buffer";
    }
  ];

  leader = [
    {
      mode = "n";
      key = "<leader>L";
      action = "<cmd>Lazy<cr>";
      options.desc = "Lazy";
    }
    {
      mode = "n";
      key = "<leader>f";
      action = "<cmd>Telescope find_files<cr>";
      options.desc = "Find File";
    }
    # {
    #   mode = "v";
    #   key = "<leader>n";
    #   action = ":NR!<cr>";
    #   options.desc = "Narrow region";
    # }
    {
      mode = "n";
      key = "<leader>N";
      action = "<cmd>Telescope notify<cr>";
      options.desc = "Notication History";
    }
    {
      mode = "n";
      key = "<leader>r";
      action = "<cmd>Telescope resume<cr>";
      options.desc = "Last Telescope Picker";
    }
    {
      mode = "n";
      key = "<leader>:";
      action = "<cmd>Telescope commands<cr>";
      options.desc = "Find Command";
    }
    # {
    #   mode = "n";
    #   key = "<leader>M";
    #   action = "<cmd>Telescope marks<cr>";
    #   options.desc = "Show marks";
    # }
    # {
    #   mode = "n";
    #   key = "<leader>J";
    #   action = "<cmd>Telescope jumplist<cr>";
    #   options.desc = "Show jumplist";
    # }
    {
      mode = "n";
      key = "<leader>T";
      action = "<cmd>TodoTelescope<cr>";
      options.desc = "List TODOs";
    }
    {
      mode = "n";
      key = "<leader>u";
      action = "<cmd>Telescope undo<cr>";
      options.desc = "Undo History";
    }
    {
      mode = "n";
      key = "<leader>/";
      action = "<cmd>Telescope live_grep<cr>";
      options.desc = "Grep Directory";
    }
    {
      mode = "n";
      key = "<leader>o";
      action = "<cmd>ObsidianSearch<cr>";
      options.desc = "Obsidian Note";
    }
  ];

  leader-help = [
    {
      mode = "n";
      key = "<leader>h";
      action = "+help";
    }
    {
      mode = "n";
      key = "<leader>hv";
      action = "<cmd>Telescope vim_options<cr>";
      options.desc = "Vim Options";
    }
    {
      mode = "n";
      key = "<leader>hk";
      action = "<cmd>Telescope keymaps<cr>";
      options.desc = "Keymaps";
    }
    {
      mode = "n";
      key = "<leader>hm";
      action = "<cmd>Telescope man_pages<cr>";
      options.desc = "Manpages";
    }
    {
      mode = "n";
      key = "<leader>hh";
      action = "<cmd>Telescope help_tags<cr>";
      options.desc = "Vim Help";
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
      options.desc = "Force Quit";
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
      options.desc = "Restore";
    }
    {
      mode = "n";
      key = "<leader>ss";
      action = "<cmd>SessionSave<cr>";
      options.desc = "Save";
    }
    {
      mode = "n";
      key = "<leader>sd";
      action = "<cmd>SessionDelete<cr>";
      options.desc = "Delete";
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
      action = "<cmd>Telescope buffers sort_lastused=true<cr>"; # There is also sort_mru=true
      options.desc = "List Buffers";
    }
    {
      mode = "n";
      key = "<leader><Space>";
      action = "<cmd>Telescope buffers sort_lastused=true<cr>";
      options.desc = "List Buffers";
    }
    {
      mode = "n";
      key = "<leader>R";
      action = "<cmd>edit!<cr>";
      options.desc = "Reload Buffer";
    }
    {
      mode = "n";
      key = "<leader>bn";
      action = "<cmd>bnext<cr>";
      options.desc = "Next Buffer";
    }
    {
      mode = "n";
      key = "<leader>bp";
      action = "<cmd>bprevious<cr>";
      options.desc = "Previous Buffer";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>Bdelete<cr>";
      options.desc = "Close Buffer";
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
      options.desc = "Close Window";
    }

    {
      mode = "n";
      key = "<leader>ws";
      action = "<C-w>s";
      options.desc = "Split Horizontally";
    }
    {
      mode = "n";
      key = "<leader>wv";
      action = "<C-w>v";
      options.desc = "Split Vertically";
    }
    {
      mode = "n";
      key = "<leader>w=";
      action = "<C-w>=";
      options.desc = "Balance Windows";
    }

    {
      mode = "n";
      key = "<leader>wh";
      action = "<C-w>h";
      options.desc = "Goto Left Window";
    }
    {
      mode = "n";
      key = "<leader>wl";
      action = "<C-w>l";
      options.desc = "Goto Wight Window";
    }
    {
      mode = "n";
      key = "<leader>wj";
      action = "<C-w>j";
      options.desc = "Goto Bottom Window";
    }
    {
      mode = "n";
      key = "<leader>wk";
      action = "<C-w>k";
      options.desc = "Goto Top Window";
    }
    {
      mode = "n";
      key = "<leader>ww";
      action = "<C-w>p";
      options.desc = "Goto Other Window";
    }

    {
      mode = "n";
      key = "<leader>wm";
      action = "<cmd>WinShift<cr>";
      options.desc = "Move Window";
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
      options.desc = "NeoTree";
    }
    {
      mode = "n";
      key = "<leader>to";
      action = "<cmd>Oil<cr>";
      options.desc = "Oil";
    }
    {
      mode = "n";
      key = "<leader>tn";
      action = "<cmd>Navbuddy<cr>";
      options.desc = "NavBuddy";
    }
    {
      mode = "n";
      key = "<leader>td";
      action = "<cmd>Trouble diagnostics toggle focus=false win.position=bottom<cr>";
      options.desc = "Trouble Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>tT";
      action = "<cmd>Trouble todo toggle focus=false win.position=right<cr>";
      options.desc = "Trouble TODOs";
    }
    {
      mode = "n";
      key = "<leader>ts";
      action = "<cmd>Trouble symbols toggle focus=false win.position=right<cr>";
      options.desc = "Trouble Symbols";
    }

    {
      mode = "n";
      key = "<leader>tf";
      action = "<cmd>ToggleAutoformat<cr>";
      options.desc = "Format on Save";
    }

    {
      mode = "n";
      key = "<leader>tl";
      action = "<cmd>ToggleAutoLint<cr>";
      options.desc = "Lint on Save";
    }

    {
      mode = "n";
      key = "<leader>tD";
      action = "<cmd>ToggleInlineDiagnostics<cr>";
      options.desc = "Inline Diagnostics";
    }

    {
      mode = "n";
      key = "<leader>tw";
      action = "<cmd>:set wrap!<cr>";
      options.desc = "Word Wrapping";
    }
    {
      mode = "n";
      key = "<leader>tv";
      action = "<cmd>VimtexTocToggle<cr>";
      options.desc = "VimTex ToC";
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
      options.desc = "LazyGit";
    }
    {
      mode = "n";
      key = "<leader>gm";
      action = "<cmd>GitMessenger<cr>";
      options.desc = "GitMessenger";
    }

    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>Telescope git_status<cr>";
      options.desc = "Status";
    }
    {
      mode = "n";
      key = "<leader>gl";
      action = "<cmd>Telescope git_commits<cr>";
      options.desc = "Log";
    }
    {
      mode = "n";
      key = "<leader>gb";
      action = "<cmd>Telescope git_branches<cr>";
      options.desc = "Branches";
    }
    {
      mode = "n";
      key = "<leader>gf";
      action = "<cmd>Telescope git_bcommits<cr>";
      options.desc = "File History";
    }
    {
      mode = "n";
      key = "<leader>gd";
      action = "<cmd>DiffviewOpen<cr>";
      options.desc = "DiffView";
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
      options.desc = "Format Buffer";
    }

    {
      mode = "n";
      key = "<leader>cd";
      action = "<cmd>lua vim.diagnostic.open_float()<cr>";
      options.desc = "Line Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>cD";
      action = "<cmd>Telescope diagnostics<cr>";
      options.desc = "List Diagnostics";
    }

    {
      mode = "n";
      key = "<leader>cr";
      action = "<cmd>lua vim.lsp.buf.rename()<cr>";
      options.desc = "Rename Symbol";
    }
    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
      options.desc = "Code Actions";
    }
    # {
    #   mode = "n";
    #   key = "<leader>cr";
    #   action = ":IncRename ";
    #   options.desc = "Rename LSP symbol";
    # }

    {
      mode = "n";
      key = "<leader>cg";
      action = "+goto";
    }
    {
      mode = "n";
      key = "<leader>cgh";
      action = "<cmd>ClangdSwitchSourceHeader<cr>";
      options.desc = "Switch C/C++ Source/Header";
    }
    {
      mode = "n";
      key = "<leader>cgr";
      action = "<cmd>Telescope lsp_references<cr>";
      options.desc = "Symbol References";
    }
    {
      mode = "n";
      key = "<leader>cgd";
      action = "<cmd>Telescope lsp_definitions<cr>";
      options.desc = "Symbol Definition";
    }
    {
      mode = "n";
      key = "<leader>cgi";
      action = "<cmd>Telescope lsp_implementations<cr>";
      options.desc = "Symbol Implementation";
    }
    {
      mode = "n";
      key = "<leader>cgt";
      action = "<cmd>Telescope lsp_type_definitions<cr>";
      options.desc = "Type Definition";
    }
    {
      mode = "n";
      key = "<leader>cI";
      action = "<cmd>Telescope lsp_incoming_calls<cr>";
      options.desc = "Incoming Calls";
    }
    {
      mode = "n";
      key = "<leader>cO";
      action = "<cmd>Telescope lsp_outgoing_calls<cr>";
      options.desc = "Outgoing Calls";
    }
  ];
in
  builtins.concatLists [
    disabled-mappings

    no-leader
    leader
    leader-help
    leader-quit
    leader-session
    leader-buffers
    leader-windows
    leader-toggles
    leader-git
    leader-code
  ]
