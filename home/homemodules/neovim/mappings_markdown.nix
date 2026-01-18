{...}: [
  {
    mode = "n";
    key = "<localleader>t";
    action = "<cmd>Markview toggle<cr>";
    options.desc = "Toggle Conceal";
    options.buffer = true;
  }
  {
    mode = "n";
    key = "<localleader>s";
    action = "<cmd>Markview splitToggle<cr>";
    options.desc = "Toggle Split";
    options.buffer = true;
  }
]
