{...}: [
  {
    mode = "n";
    key = "<localleader>t";
    action = "<cmd>VimtexTocToggle<cr>";
    options.desc = "Vimtex ToC";
  }
  {
    mode = "n";
    key = "<localleader>c";
    action = "<cmd>VimtexCompile<cr>";
    options.desc = "Vimtex Compile";
  }
  {
    mode = "n";
    key = "<localleader>C";
    action = "<cmd>VimtexClean!<cr>";
    options.desc = "Vimtex Clean";
  }
  {
    mode = "n";
    key = "<localleader>v";
    action = "<cmd>VimtexView<cr>";
    options.desc = "Vimtex View";
  }
  {
    mode = "n";
    key = "<localleader>I";
    action = "<cmd>VimtexInfo<cr>";
    options.desc = "Vimtex Info";
  }
  {
    mode = "n";
    key = "<localleader>,";
    action = "<cmd>VimtexContextMenu<cr>";
    options.desc = "Vimtex Context Menu";
  }
  {
    mode = "n";
    key = "<localleader>e";
    action = "<cmd>VimtexErrors<cr>";
    options.desc = "Vimtex Errors";
  }
  {
    mode = "n";
    key = "<localleader>p";
    action = "<cmd>VimtexDocPackage<cr>";
    options.desc = "Vimtex Package Docs";
  }
]
