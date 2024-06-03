-- Skip loading LazyVim options
package.loaded["lazyvim.config.options"] = true

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
		{
			"LazyVim/LazyVim",
			import = "lazyvim.plugins",
			opts = {
				defaults = {
					autocmds = false, -- Skip loading LazyVim cmds
					keymaps = false, -- Skip loading LazyVim keymaps
				},
			},
		},

		-- force enable telescope-fzf-native.nvim on nix
		{ "nvim-telescope/telescope-fzf-native.nvim", enabled = true },

		-- disable mason.nvim, use config.extraPackages on nix
		{ "williamboman/mason-lspconfig.nvim", enabled = false },
		{ "williamboman/mason.nvim", enabled = false },

		-- uncomment to import/override with your plugins
		-- { import = "plugins" },

		-- put this line at the end of spec to clear ensure_installed on nix
		{ "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
	},
})
