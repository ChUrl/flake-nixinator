local opt = vim.opt
local g = vim.g
local o = vim.o

-- Neovide
if g.neovide then
  -- require("notify").notify("Running in NeoVide")

  g.neovide_cursor_animate_command_line = true
  g.neovide_cursor_animate_in_insert_mode = true
  g.neovide_fullscreen = false
  g.neovide_hide_mouse_when_typing = false
  g.neovide_padding_top = 0
  g.neovide_padding_bottom = 0
  g.neovide_padding_right = 0
  g.neovide_padding_left = 0
  g.neovide_refresh_rate = 144
  g.neovide_theme = 'light'

  -- Neovide Fonts
  o.guifont = "JetBrainsMono Nerd Font:h13:Medium"
else
  -- require("notify").notify("Not running in NeoVide")
end