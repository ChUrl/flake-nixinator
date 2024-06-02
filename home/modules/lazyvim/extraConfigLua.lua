-- Package manager setup
require("lazy").setup({
	defaults = {
		lazy = true,
	},

	dev = {
		-- reuse files from pkgs.vimPlugins.*
		path = "@lazyPath@", -- NOTE: Will be replaced by the nix path
		patterns = { "." },
		-- fallback to download
		fallback = true,
	},

	spec = {
		-- { "LazyVim/LazyVim", import = "lazyvim.plugins" },
		-- The following configs are needed for fixing lazyvim on nix
		-- force enable telescope-fzf-native.nvim
		{ "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
		-- disable mason.nvim, use config.extraPackages
		{ "williamboman/mason-lspconfig.nvim", enabled = false },
		{ "williamboman/mason.nvim", enabled = false },
		-- uncomment to import/override with your plugins
		-- { import = "plugins" },
		-- put this line at the end of spec to clear ensure_installed
		{ "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
	},
})

-- Hide inline diagnostics and show border
vim.diagnostic.config({
	virtual_text = false,
	float = { border = "rounded" },
})

-- Allow navigating popupmenu completion with Up/Down
vim.api.nvim_set_keymap("c", "<Down>", 'v:lua.get_wildmenu_key("<right>", "<down>")', { expr = true })
vim.api.nvim_set_keymap("c", "<Up>", 'v:lua.get_wildmenu_key("<left>", "<up>")', { expr = true })
function _G.get_wildmenu_key(key_wildmenu, key_regular)
	return vim.fn.wildmenumode() ~= 0 and key_wildmenu or key_regular
end
