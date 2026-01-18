{...}: [
  {
    mode = "n";
    key = "<localleader>t";
    action = "<cmd>VimtexTocToggle<cr>";
    options.desc = "Vimtex ToC";
    options.buffer = true;
  }
  {
    mode = "n";
    key = "<localleader>c";
    action = "<cmd>VimtexCompile<cr>";
    options.desc = "Vimtex Compile";
    options.buffer = true;
  }
  {
    mode = "n";
    key = "<localleader>C";
    action = "<cmd>VimtexClean!<cr>";
    options.desc = "Vimtex Clean";
    options.buffer = true;
  }
  {
    mode = "n";
    key = "<localleader>v";
    action = "<cmd>VimtexView<cr>";
    options.desc = "Vimtex View";
    options.buffer = true;
  }
  {
    mode = "n";
    key = "<localleader>I";
    action = "<cmd>VimtexInfo<cr>";
    options.desc = "Vimtex Info";
    options.buffer = true;
  }
  {
    mode = "n";
    key = "<localleader>,";
    action = "<cmd>VimtexContextMenu<cr>";
    options.desc = "Vimtex Context Menu";
    options.buffer = true;
  }
  {
    mode = "n";
    key = "<localleader>e";
    action = "<cmd>VimtexErrors<cr>";
    options.desc = "Vimtex Errors";
    options.buffer = true;
  }
  {
    mode = "n";
    key = "<localleader>p";
    action = "<cmd>VimtexDocPackage<cr>";
    options.desc = "Vimtex Package Docs";
    options.buffer = true;
  }
]
