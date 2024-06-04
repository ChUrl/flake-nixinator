function(props)

	-- local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
	-- if filename == "" then
	-- 	filename = "[No Name]"
	-- end

	-- local helpers = require("incline.helpers")
	-- local devicons = require("nvim-web-devicons")

	-- local ft_icon, ft_color = devicons.get_icon_color(filename)
	-- local modified = vim.bo[props.buf].modified
	-- local result = {
	-- 	ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
	-- 	" ",
	-- 	{ filename, gui = modified and "bold,italic" or "bold" },
	-- 	guibg = "#44406e",
	-- }

	-- Just print the breadcrumbs, skip the filename for now
	local result = {}

	-- TODO: This code doesn't respect navic's max_depth, because get_data is used
	if props.focused then
		local navic = require("nvim-navic")
		local bgColor = "Black"
		for _, item in ipairs(navic.get_data(props.buf) or {}) do
			table.insert(result, {
				{ " > ", group = "NavicSeparator", guibg = bgColor },
				{ item.icon, group = "NavicIcons" .. item.type, guibg = bgColor },
				{ item.name, group = "NavicText", guibg = bgColor },
			})
		end
	end

	table.insert(result, " ")
	return result
end
