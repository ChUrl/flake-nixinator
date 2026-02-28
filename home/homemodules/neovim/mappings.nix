_: let
  # TODO: Doesn't work reliably. I think they are rebound by plugins after? Try setting in extraConfigLuaPost...
  disabled-mappings = let
    mkDisabledMapping = mapping: {
      mode = ["n" "v"];
      key = mapping;
      action = "<Nop>";
    };

    disableMappings = [
      # I only use f/F with flash
      "s"
      "S"
      "t"
      "T"
      "H"
      "L"

      # Use flash to repeat f/F instead of ;/,
      # ;/, are now free for localleader and exiting visual mode like helix
      ","
      ";"

      # Use Telescope on "/", I don't want backwards search
      "?"
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
    {
      mode = "n";
      key = "H";
      action = "^";
      options.desc = "Move Cursor to Line Start";
    }
    {
      mode = "n";
      key = "L";
      action = "$";
      options.desc = "Move Cursor to Line End";
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
      options.desc = "Delete Previous Word"; # TODO: Breaks backspace in <C-v><S-i> although i binding?
    }
    {
      mode = "i";
      key = "<M-BS>";
      action = "<C-w>";
      options.desc = "Delete Previous Word"; # TODO: Breaks backspace in <C-v><S-i> although i binding?
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
      mode = ["n" "i"];
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
    # {
    #   mode = "n";
    #   key = "K";
    #   action = "<cmd>lua require('hover').hover()<cr>";
    #   options.desc = "LSP Hover";
    # }
    {
      mode = "n";
      key = "/";
      action = "<cmd>lua Snacks.picker.lines()<cr>";
      options.desc = "Find in Buffer";
    }
    {
      mode = ["n" "v"];
      key = ";";
      action = "%";
      options.desc = "Matching ()[]<>";
    }
    # {
    #   mode = "v";
    #   key = ";";
    #   action = "<Esc>";
    #   options.desc = "Exit Visual Mode";
    # }
  ];

  leader = [
    {
      mode = "n";
      key = "<leader>L";
      action = "<cmd>Lazy<cr>";
      options.desc = "Lazy Packages";
    }
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree action=show toggle=true<cr><C-w>=";
      options.desc = "Toggle Explorer";
    }
    {
      mode = "n";
      key = "<leader>E";
      action = "<cmd>Neotree<cr>";
      options.desc = "Focus Explorer";
    }
    {
      mode = "n";
      key = "<leader>n";
      action = "<cmd>Navbuddy<cr>";
      options.desc = "Toggle NavBuddy";
    }
    {
      mode = "n";
      key = "<leader>p";
      action = "<cmd>lua Snacks.picker.pickers()<cr>";
      options.desc = "Show Pickers";
    }
    {
      mode = "n";
      key = "<leader>N";
      action = "<cmd>lua Snacks.picker.notifications()<cr>";
      options.desc = "Notifications Picker";
    }
    {
      mode = "n";
      key = "<leader>R";
      action = "<cmd>lua Snacks.picker.resume()<cr>";
      options.desc = "Last Picker";
    }
    {
      mode = "n";
      key = "<leader>r";
      action = "<cmd>lua vim.g.toggle_rmpc()<cr>"; # Defined in extraConfigLua.lua
      options.desc = "Show Rmpc";
    }
    {
      mode = "n";
      key = "<leader>i";
      action = "<cmd>lua Snacks.picker.icons()<cr>";
      options.desc = "Icons Picker";
    }
    {
      mode = "n";
      key = "<leader>;";
      action = "<cmd>lua Snacks.picker.command_history()<cr>";
      options.desc = "Command History";
    }
    {
      mode = "n";
      key = "<leader>:";
      action = "<cmd>lua Snacks.picker.commands()<cr>";
      options.desc = "Commands Picker";
    }
    {
      mode = "n";
      key = "<leader>m";
      action = "<cmd>lua Snacks.picker.marks()<cr>";
      options.desc = "Marks Picker";
    }
    {
      mode = "n";
      key = "<leader>j";
      action = "<cmd>lua Snacks.picker.jumps()<cr>";
      options.desc = "Jumps Picker";
    }
    {
      mode = "n";
      key = "<leader>d";
      action = "<cmd>lua Snacks.picker.todo_comments()<cr>";
      options.desc = "List TODOs";
    }
    {
      mode = "n";
      key = "<leader>/";
      action = "<cmd>lua Snacks.picker.grep()<cr>";
      options.desc = "Find in Project";
    }
    {
      mode = "n";
      key = "<leader>Q";
      action = "<cmd>lua Snacks.picker.qflist()<cr>";
      options.desc = "Quickfix History";
    }
    # {
    #   mode = "n";
    #   key = "<leader>Q";
    #   action = "<cmd>cexpr []<cr>";
    #   options.desc = "Clear Quickfix List";
    # }
    {
      mode = "n";
      key = "<leader>W";
      action = "<cmd>:set wrap!<cr>";
      options.desc = "Toggle Word Wrap";
    }
    {
      mode = "n";
      key = "<leader>y";
      action = "<cmd>Yazi<cr>";
      options.desc = "Toggle Yazi";
    }
  ];

  leader-file = [
    {
      mode = "n";
      key = "<leader>f";
      action = "+file";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>lua Snacks.picker.files()<cr>";
      options.desc = "Find File";
    }
    {
      mode = "n";
      key = "<leader>fl";
      action = "<cmd>lua Snacks.picker.recent()<cr>";
      options.desc = "Last Files";
    }
    # {
    #   mode = "n";
    #   key = "<leader>fo";
    #   action = "<cmd>ObsidianSearch<cr>";
    #   options.desc = "Obsidian Note";
    # }
    {
      mode = "n";
      key = "<leader>fr";
      action = "<cmd>edit!<cr>";
      options.desc = "Reload File";
    }
    {
      mode = "n";
      key = "<leader>fu";
      action = "<cmd>lua Snacks.picker.und()<cr>";
      options.desc = "Undo Picker";
    }
    {
      mode = "n";
      key = "<leader>fc";
      action = "<cmd>edit ~/.config/nvim/init.lua<cr>";
      options.desc = "Open NeoVim Config";
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = "<cmd>edit ~/.config/hypr/hyprland.conf<cr>";
      options.desc = "Open Hyprland Config";
    }
    {
      mode = "n";
      key = "<leader>fn";
      action = "<cmd>enew<cr>";
      options.desc = "New File";
    }
    {
      mode = "n";
      key = "<leader>fs";
      action.__raw = ''
        function()
          local filename = vim.fn.input("Enter Filename: ")
          vim.cmd("write "..filename)
        end
      '';
      options.desc = "Save File";
    }
  ];

  leader-help = [
    {
      mode = "n";
      key = "<leader>h";
      action = "+help";
    }
    # {
    #   mode = "n";
    #   key = "<leader>hv";
    #   action = "<cmd>Telescope vim_options<cr>";
    #   options.desc = "Telescope Vimopts";
    # }
    {
      mode = "n";
      key = "<leader>hk";
      action = "<cmd>lua Snacks.picker.keymaps()<cr>";
      options.desc = "Keymaps Picker";
    }
    {
      mode = "n";
      key = "<leader>hm";
      action = "<cmd>lua Snacks.picker.man()<cr>";
      options.desc = "Manpages Picker";
    }
    {
      mode = "n";
      key = "<leader>hh";
      action = "<cmd>lua Snacks.picker.help()<cr>";
      options.desc = "Helptags Picker";
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
      key = "<leader>qQ";
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
      action = "<cmd>lua require('persisted').select()<cr>";
      options.desc = "Restore Session";
    }
    {
      mode = "n";
      key = "<leader>ss";
      action = "<cmd>SessionSave<cr>";
      options.desc = "Save Session";
    }
    {
      mode = "n";
      key = "<leader>sd";
      action = "<cmd>SessionDelete<cr>";
      options.desc = "Delete Session";
    }
  ];

  leader-buffers = [
    {
      mode = "n";
      key = "<leader>b";
      action = "+buffer";
    }
    {
      mode = "n";
      key = "<leader>bb";
      action = "<cmd>lua Snacks.picker.buffers()<cr>";
      options.desc = "Buffers Picker";
    }
    {
      mode = "n";
      key = "<leader><Space>";
      action = "<cmd>lua Snacks.picker.buffers()<cr>";
      options.desc = "Buffers Picker";
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
      key = "<leader>bN";
      action = "<cmd>enew<cr>";
      options.desc = "New Buffer";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>lua Snacks.bufdelete()<cr>";
      options.desc = "Close Buffer";
    }
  ];

  leader-tabs = [
    {
      mode = "n";
      key = "<leader>T";
      action = "+tab";
    }
    # {
    #   mode = "n";
    #   key = "<leader>Tt";
    #   action = "<cmd>Telescope telescope-tabs list_tabs<cr>";
    #   options.desc = "List Tabpages";
    # }
    # {
    #   mode = "n";
    #   key = "<leader><C-Space>";
    #   action = "<cmd>Telescope telescope-tabs list_tabs<cr>";
    #   options.desc = "List Tabpages";
    # }
    {
      mode = "n";
      key = "<leader>Tn";
      action = "<cmd>tabnext<cr>";
      options.desc = "Next Tabpage";
    }
    {
      mode = "n";
      key = "<leader>Tp";
      action = "<cmd>tabprevious<cr>";
      options.desc = "Previous Tabpage";
    }
    {
      mode = "n";
      key = "<leader>TN";
      action = "<cmd>tabnew<cr>";
      options.desc = "New Tabpage";
    }
    {
      mode = "n";
      key = "<leader>Td";
      action = "<cmd>tabclose<cr>";
      options.desc = "Close Tabpage";
    }
  ];

  leader-windows = [
    {
      mode = "n";
      key = "<leader>w";
      action = "+window";
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
      action = "<cmd>lua vim.api.nvim_set_current_win(require('window-picker').pick_window() or vim.api.nvim_get_current_win())<cr>";
      options.desc = "Jump to Window";
    }

    {
      mode = "n";
      key = "<leader>wm";
      action = "<cmd>WinShift<cr>";
      options.desc = "Move Window";
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
      action = "<cmd>lua Snacks.lazygit.open()<cr>";
      options.desc = "LazyGit";
    }
    {
      mode = "n";
      key = "<leader>gm";
      action = "<cmd>lua Snacks.git.blame_line()<cr>";
      options.desc = "Git Blame";
    }

    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>lua Snacks.picker.git_status()<cr>";
      options.desc = "Git Status";
    }
    {
      mode = "n";
      key = "<leader>gl";
      action = "<cmd>lua Snacks.picker.git_log()<cr>";
      options.desc = "Git Log";
    }
    {
      mode = "n";
      key = "<leader>gb";
      action = "<cmd>lua Snacks.picker.git_branches()<cr>";
      options.desc = "Git Branches";
    }
    {
      mode = "n";
      key = "<leader>gf";
      action = "<cmd>lua Snacks.picker.git_log_file()<cr>";
      options.desc = "Git File History";
    }
    {
      mode = "n";
      key = "<leader>gd";
      action = "<cmd>DiffviewOpen<cr>";
      options.desc = "Git DiffView";
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
      action = "<cmd>lua Snacks.picker.diagnostics()<cr>";
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
    #   key = "<leader>cI";
    #   action = "<cmd>Telescope lsp_incoming_calls<cr>";
    #   options.desc = "LSP Incoming Calls";
    # }
    # {
    #   mode = "n";
    #   key = "<leader>cO";
    #   action = "<cmd>Telescope lsp_outgoing_calls<cr>";
    #   options.desc = "LSP Outgoing Calls";
    # }
    {
      mode = "n";
      key = "<leader>cc";
      action = "<cmd>Neogen<cr>";
      options.desc = "Generate Doc Comment";
    }

    # Toggles
    {
      mode = "n";
      key = "<leader>t";
      action = "+toggle";
    }
    {
      mode = "n";
      key = "<leader>td";
      action = "<cmd>ToggleInlineDiagnostics<cr>";
      options.desc = "Inline Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>tt";
      action = "<cmd>Trouble diagnostics toggle focus=false win.position=bottom<cr>";
      options.desc = "Trouble Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>tD";
      action = "<cmd>Trouble todo toggle focus=false win.position=bottom<cr>";
      options.desc = "Toggle TODOs";
    }
    {
      mode = "n";
      key = "<leader>ts";
      action = "<cmd>Trouble symbols toggle focus=false win.position=bottom<cr>";
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

    # GoTo
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
      action = "<cmd>lua Snacks.picker.lsp_references()<cr>";
      options.desc = "LSP References";
    }
    {
      mode = "n";
      key = "<leader>cgd";
      action = "<cmd>lua Snacks.picker.lsp_definitions()<cr>";
      options.desc = "LSP Definitions";
    }
    {
      mode = "n";
      key = "<leader>cgi";
      action = "<cmd>lua Snacks.picker.lsp_implementations()<cr>";
      options.desc = "LSP Implementations";
    }
    {
      mode = "n";
      key = "<leader>cgt";
      action = "<cmd>lua Snacks.picker.lsp_type_definitions()<cr>";
      options.desc = "LSP Type Definitions";
    }
    {
      mode = "n";
      key = "<leader>cge";
      action = "<cmd>lua vim.diagnostic.goto_next()<cr>";
      options.desc = "Next Diagnostic";
    }
    {
      mode = "n";
      key = "<C-e>";
      action = "<cmd>lua vim.diagnostic.goto_next()<cr>";
      options.desc = "Next Diagnostic";
    }
    {
      mode = "n";
      key = "<leader>cgE";
      action = "<cmd>lua vim.diagnostic.goto_prev()<cr>";
      options.desc = "Previous Diagnostic";
    }
    {
      mode = "n";
      key = "<C-S-e>";
      action = "<cmd>lua vim.diagnostic.goto_prev()<cr>";
      options.desc = "Previous Diagnostic";
    }
    {
      mode = "n";
      key = "<C-q>";
      action = "<cmd>cnext<cr>";
      options.desc = "Next Quickfix Item";
    }
    {
      mode = "n";
      key = "<leader>cgq";
      action = "<cmd>cnext<cr>";
      options.desc = "Next Quickfix Item";
    }
    {
      mode = "n";
      key = "<C-S-q>";
      action = "<cmd>cprevious<cr>";
      options.desc = "Previous Quickfix Item";
    }
    {
      mode = "n";
      key = "<leader>cgQ";
      action = "<cmd>cprevious<cr>";
      options.desc = "Previous Quickfix Item";
    }
  ];

  localleader-latex = [
  ];
in
  builtins.concatLists [
    disabled-mappings
    no-leader

    leader
    leader-file
    leader-help
    leader-quit
    leader-session
    leader-buffers
    leader-tabs
    leader-windows
    leader-git
    leader-code

    localleader-latex
  ]
