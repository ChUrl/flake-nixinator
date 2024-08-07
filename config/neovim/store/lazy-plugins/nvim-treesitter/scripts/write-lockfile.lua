#!/nix/store/i7qhgc0bs725qw3wdanznfkdna4z2ns2-coreutils-9.5/bin/env -S  -l

---@type string|any[]
local skip_langs = vim.fn.getenv "SKIP_LOCKFILE_UPDATE_FOR_LANGS"

if skip_langs == vim.NIL then
  skip_langs = {}
else
  ---@diagnostic disable-next-line: param-type-mismatch
  skip_langs = vim.fn.split(skip_langs, ",")
end

require("nvim-treesitter.install").write_lockfile("verbose", skip_langs)
vim.cmd "q"
