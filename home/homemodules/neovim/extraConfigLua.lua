-- Make Lazy window border rounded
require("lazy.core.config").options.ui.border = "rounded"

-- Disable rocks. For some reason, we still have to activate
-- "Install" in the Lazy menu once to disable rocks completely.
require("lazy.core.config").options.rocks.enabled = false

-- Work around diagnostics published past EOF (texlab emits one on the line
-- after the last line, e.g. line index 457 of a 457-line preamble.tex).
-- vim.diagnostic's underline handler then calls nvim_buf_get_lines out of
-- range and throws "Index out of bounds", which also sets BF_READERR on the
-- buffer and makes every :w prompt "Overwrite existing file ...?".
do
	local diagnostic = require("vim.diagnostic")
	local orig_set = diagnostic.set

	diagnostic.set = function(namespace, bufnr, diagnostics, opts)
		if bufnr == nil or bufnr == 0 then
			bufnr = vim.api.nvim_get_current_buf()
		end
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return orig_set(namespace, bufnr, diagnostics, opts)
		end

		local last = vim.api.nvim_buf_line_count(bufnr) - 1
		local filtered = {}

		for _, d in ipairs(diagnostics or {}) do
			local lnum = d.lnum
			if type(lnum) == "number" and lnum >= 0 and lnum <= last then
				local end_lnum = math.max(lnum, math.min(d.end_lnum or lnum, last))

				local start_line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, true)[1] or ""
				local end_line = start_line
				if end_lnum ~= lnum then
					end_line = vim.api.nvim_buf_get_lines(bufnr, end_lnum, end_lnum + 1, true)[1] or ""
				end

				d.lnum = lnum
				d.col = math.max(0, math.min(d.col or 0, #start_line))
				d.end_lnum = end_lnum
				d.end_col = math.max(d.col, math.min(d.end_col or d.col, #end_line))

				filtered[#filtered + 1] = d
			end
		end

		return orig_set(namespace, bufnr, filtered, opts)
	end
end

-- Default filetype to tex instead of plaintex
vim.g.tex_flavor = "latex"

-- Toggle inline diagnostics and show border
vim.g.enable_inline_diagnostics = false
vim.diagnostic.config({
	virtual_text = vim.g.enable_inline_diagnostics,
	float = { border = "rounded" },
})
vim.api.nvim_create_user_command("ToggleInlineDiagnostics", function()
	vim.g.enable_inline_diagnostics = not vim.g.enable_inline_diagnostics
	vim.diagnostic.config({ virtual_text = vim.g.enable_inline_diagnostics, float = { border = "rounded" } })
	vim.notify((vim.g.enable_inline_diagnostics and "Enabled" or "Disabled") .. " inline diagnostics")
end, {
	desc = "Toggle inline diagnostics",
})

-- Toggle conform format_on_save
vim.g.disable_autoformat = false
vim.api.nvim_create_user_command("ToggleAutoformat", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat
	vim.notify((vim.g.disable_autoformat and "Disabled" or "Enabled") .. " autoformat-on-save")
end, {
	desc = "Toggle autoformat-on-save",
})

-- Allow navigating popupmenu completion with Up/Down
vim.api.nvim_set_keymap("c", "<Down>", 'v:lua.get_wildmenu_key("<right>", "<down>")', { expr = true })
vim.api.nvim_set_keymap("c", "<Up>", 'v:lua.get_wildmenu_key("<left>", "<up>")', { expr = true })
function _G.get_wildmenu_key(key_wildmenu, key_regular)
	return vim.fn.wildmenumode() ~= 0 and key_wildmenu or key_regular
end

-- Check LSP server config
vim.api.nvim_create_user_command("LspInspect", function()
	vim.notify(vim.inspect(vim.lsp.get_active_clients()))
end, {
	desc = "Print LSP server configuration",
})

-- Toggle linting
vim.g.disable_autolint = false
vim.api.nvim_create_user_command("ToggleAutoLint", function()
	vim.g.disable_autolint = not vim.g.disable_autolint
	if vim.g.disable_autolint then
		-- vim.diagnostic.reset(vim.api.nvim_get_current_buf())
		vim.diagnostic.reset() -- Reset for all buffers
	end
	vim.notify((vim.g.disable_autolint and "Disabled" or "Enabled") .. " autolint-on-save")
end, {
	desc = "Toggle autolint-on-save",
})

-- Toggle Rmpc
local Terminal = require("toggleterm.terminal").Terminal
local rmpc = Terminal:new({
	cmd = "rmpc",
	hidden = true,
	close_on_exit = true,
	auto_scroll = false,
	direction = "float",
})

vim.g.toggle_rmpc = function()
	rmpc:toggle()
end

-- Toggle FailNix UI
local failnix = Terminal:new({
	cmd = "cd /home/christoph/Notes/TU/MastersThesis/FailNix && nix develop --command bash -c 'perl ./scripts/menu.pl'",
	hidden = true,
	close_on_exit = true,
	auto_scroll = false,
	direction = "float",
})

vim.g.toggle_failnix = function()
	failnix:toggle()
end
