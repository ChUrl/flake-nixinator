-- Toggle inline diagnostics and show border
vim.g.enable_inline_diagnostics = false
vim.diagnostic.config({
	virtual_text = vim.g.enable_inline_diagnostics,
	float = { border = "rounded" },
})
vim.api.nvim_create_user_command("ToggleInlineDiagnostics", function()
	vim.g.enable_inline_diagnostics = not vim.g.enable_inline_diagnostics
	vim.diagnostic.config({ virtual_text = vim.g.enable_inline_diagnostics })
	require("notify")((vim.g.enable_inline_diagnostics and "Enabled" or "Disabled") .. " inline diagnostics")
end, {
	desc = "Toggle inline diagnostics",
})

-- Toggle conform format_on_save
vim.g.disable_autoformat = false
vim.api.nvim_create_user_command("ToggleAutoformat", function()
	vim.g.disable_autoformat = not vim.g.disable_autoformat
	require("notify")((vim.g.disable_autoformat and "Disabled" or "Enabled") .. " autoformat-on-save")
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
	require("notify")(vim.inspect(vim.lsp.get_active_clients()))
end, {
	desc = "Print LSP server configuration",
})
