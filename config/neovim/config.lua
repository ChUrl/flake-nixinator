require("catppuccin").setup({})

-- Set up globals {{{
do
    local nixvim_globals = {
        ["git_messenger_no_default_mappings"] = true,
        ["mallocalleader"] = " ",
        ["mapleader"] = " ",
        ["skip_ts_context_commentstring_module"] = true,
    }

    for k, v in pairs(nixvim_globals) do
        vim.g[k] = v
    end
end
-- }}}

-- Set up options {{{
do
    local nixvim_options = {
        ["autoindent"] = false,
        ["backspace"] = { "indent", "eol", "start" },
        ["cindent"] = true,
        ["cinkeys"] = "0{,0},0),0],:,!^F,o,O,e",
        ["completeopt"] = { "menuone", "noselect", "noinsert" },
        ["cursorline"] = true,
        ["encoding"] = "utf-8",
        ["expandtab"] = true,
        ["fileencoding"] = "utf-8",
        ["foldcolumn"] = "0",
        ["foldenable"] = true,
        ["foldexpr"] = "nvim_treesitter#foldexpr()",
        ["foldlevel"] = 99,
        ["foldlevelstart"] = 99,
        ["foldmethod"] = "expr",
        ["formatexpr"] = "v:lua.require'conform'.formatexpr()",
        ["grepformat"] = "%f:%l:%c:%m",
        ["grepprg"] = "rg --vimgrep",
        ["hidden"] = true,
        ["hlsearch"] = true,
        ["ignorecase"] = true,
        ["incsearch"] = true,
        ["laststatus"] = 3,
        ["mouse"] = "a",
        ["number"] = true,
        ["pumheight"] = 0,
        ["relativenumber"] = true,
        ["ruler"] = true,
        ["scrolloff"] = 10,
        ["shiftwidth"] = 4,
        ["showmode"] = false,
        ["signcolumn"] = "yes",
        ["smartcase"] = true,
        ["smartindent"] = false,
        ["smarttab"] = true,
        ["softtabstop"] = 4,
        ["splitbelow"] = true,
        ["splitright"] = true,
        ["tabstop"] = 4,
        ["termguicolors"] = true,
        ["timeoutlen"] = 50,
        ["undodir"] = "/home/christoph/.vim/undo",
        ["undofile"] = true,
    }

    for k, v in pairs(nixvim_options) do
        vim.opt[k] = v
    end
end
-- }}}

vim.loader.disable()

vim.cmd([[
  let $BAT_THEME = 'catppuccin'

colorscheme catppuccin

]])
require("yanky").setup({})

require("which-key").setup({})

require("trim").setup({})

require("toggleterm").setup({
    ["auto_scroll"] = true,
    ["close_on_exit"] = true,
    ["direction"] = "horizontal",
    ["float_opts"] = { ["border"] = "curved", ["height"] = 20, ["width"] = 80, ["winblend"] = 0 },
    ["hide_numbers"] = true,
    ["insert_mappings"] = true,
    ["open_mapping"] = [[<C-t>]],
    ["persist_mode"] = true,
    ["shade_terminals"] = true,
    ["shell"] = "fish",
    ["start_in_insert"] = true,
    ["terminal_mappings"] = true,
})

require("ufo").setup({})

require("colorizer").setup({
    filetypes = nil,
    user_default_options = nil,
    buftypes = nil,
})

require("nvim-autopairs").setup({})

vim.notify = require("notify")
require("notify").setup({})

local actions = require("nvim-navbuddy.actions")
require("nvim-navbuddy").setup({ ["lsp"] = { ["auto_attach"] = true }, ["window"] = { ["border"] = "rounded" } })

require("nvim-lastplace").setup({})

require("illuminate").configure({
    ["filetypes_denylist"] = {
        "DressingSelect",
        "Outline",
        "TelescopePrompt",
        "alpha",
        "harpoon",
        "toggleterm",
        "neo-tree",
        "Spectre",
        "reason",
    },
})

require("flash").setup({})

require("Comment").setup({
    ["mappings"] = { ["basic"] = true, ["extra"] = false },
    ["opleader"] = { ["line"] = "<C-c>" },
    ["toggler"] = { ["line"] = "<C-c>" },
})

require("better_escape").setup({ ["mapping"] = { "jk" }, ["timeout"] = 200 })

require("noice").setup({
    ["lsp"] = {
        ["documentation"] = {
            ["opts"] = {
                ["border"] = "rounded",
                ["format"] = { "{message}" },
                ["lang"] = "markdown",
                ["render"] = "plain",
                ["replace"] = true,
                ["win_options"] = { ["concealcursor"] = "n", ["conceallevel"] = 3 },
            },
            ["view"] = "hover",
        },
        ["override"] = {
            ["cmp.entry.get_documentation"] = true,
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
        },
    },
    ["notify"] = { ["enabled"] = true },
    ["popupmenu"] = { ["backend"] = "nui", ["enabled"] = true },
    ["presets"] = {
        ["bottom_search"] = false,
        ["command_palette"] = true,
        ["inc_rename"] = true,
        ["long_message_to_split"] = true,
        ["lsp_doc_border"] = true,
    },
    ["routes"] = { { ["filter"] = { ["event"] = "msg_show", ["kind"] = "search_count" }, ["opts"] = { ["skip"] = true } } },
})

require("headlines").setup({})

require("telescope").setup({
    ["defaults"] = {
        ["mappings"] = { ["i"] = {
            ["<esc>"] = function(...)
                return require("telescope.actions").close(...)
            end,
        } },
    },
})

local __telescopeExtensions = { "undo", "ui-select", "fzf" }
for i, extension in ipairs(__telescopeExtensions) do
    require("telescope").load_extension(extension)
end

require("lualine").setup({
    ["extensions"] = { "fzf", "chadtree", "neo-tree", "toggleterm", "trouble" },
    ["options"] = {
        ["always_divide_middle"] = true,
        ["component_separators"] = { ["left"] = "", ["right"] = "" },
        ["globalstatus"] = true,
        ["icons_enabled"] = true,
        ["ignore_focus"] = { "neo-tree", "chadtree" },
        ["section_separators"] = { ["left"] = "", ["right"] = "" },
    },
    ["sections"] = {
        ["lualine_a"] = { { "mode" } },
        ["lualine_b"] = { "branch", "diff", "diagnostics" },
        ["lualine_c"] = { { "filename", ["path"] = 1 } },
        ["lualine_x"] = { "filetype", "encoding", "fileformat" },
        ["lualine_y"] = { "progress", "searchcount", "selectioncount" },
        ["lualine_z"] = { { "location" } },
    },
    ["tabline"] = { ["lualine_a"] = { "buffers" }, ["lualine_z"] = { "tabs" } },
})
require("luasnip").config.set_config({})

require("trouble").setup({})

require("inc_rename").setup({})

require("conform").setup({
    ["formatters_by_ft"] = {
        ["c"] = { "clang-format" },
        ["cpp"] = { "clang-format" },
        ["css"] = { { "prettierd", "prettier" } },
        ["h"] = { "clang-format" },
        ["hpp"] = { "clang-format" },
        ["html"] = { { "prettierd", "prettier" } },
        ["java"] = { "google-java-format" },
        ["javascript"] = { { "prettierd", "prettier" } },
        ["markdown"] = { { "prettierd", "prettier" } },
        ["nix"] = { "alejandra" },
        ["python"] = { "black" },
        ["rust"] = { "rustfmt" },
    },
})

-- LSP {{{
do
    local __lspServers = {
        { ["name"] = "texlab" },
        { ["name"] = "tailwindcss" },
        { ["name"] = "rust_analyzer" },
        { ["name"] = "pyright" },
        { ["name"] = "nil_ls" },
        { ["name"] = "marksman" },
        { ["extraOptions"] = { ["autostart"] = true }, ["name"] = "ltex" },
        {
            ["extraOptions"] = {
                ["cmd"] = {
                    "/nix/store/c1k19pbnplsnzh9ljcgkyj1p08wb0rdc-vscode-langservers-extracted-4.10.0/bin/vscode-json-language-server",
                    "--stdio",
                },
            },
            ["name"] = "jsonls",
        },
        {
            ["extraOptions"] = {
                ["cmd"] = {
                    "/nix/store/4ab3m037j0lkzsap5wh7683fdsv8m8na-java-language-server-0.2.46/bin/java-language-server",
                },
            },
            ["name"] = "java_language_server",
        },
        {
            ["extraOptions"] = {
                ["cmd"] = {
                    "/nix/store/c1k19pbnplsnzh9ljcgkyj1p08wb0rdc-vscode-langservers-extracted-4.10.0/bin/vscode-html-language-server",
                    "--stdio",
                },
            },
            ["name"] = "html",
        },
        { ["extraOptions"] = { ["cmd"] = { "haskell-language-server-wrapper", "--lsp" } }, ["name"] = "hls" },
        {
            ["extraOptions"] = {
                ["cmd"] = {
                    "/nix/store/c1k19pbnplsnzh9ljcgkyj1p08wb0rdc-vscode-langservers-extracted-4.10.0/bin/vscode-eslint-language-server",
                    "--stdio",
                },
            },
            ["name"] = "eslint",
        },
        {
            ["extraOptions"] = {
                ["cmd"] = {
                    "/nix/store/z8y5rlr53mzh0r0wj00kaprajs1hjib6-dockerfile-language-server-nodejs-0.11.0/bin/docker-langserver",
                    "--stdio",
                },
            },
            ["name"] = "dockerls",
        },
        {
            ["extraOptions"] = {
                ["cmd"] = {
                    "/nix/store/c1k19pbnplsnzh9ljcgkyj1p08wb0rdc-vscode-langservers-extracted-4.10.0/bin/vscode-css-language-server",
                    "--stdio",
                },
            },
            ["name"] = "cssls",
        },
        { ["name"] = "cmake" },
        { ["name"] = "clojure_lsp" },
        { ["name"] = "clangd" },
    }
    local __lspOnAttach = function(client, bufnr) end
    local __lspCapabilities = function()
        capabilities = vim.lsp.protocol.make_client_capabilities()

        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        return capabilities
    end

    local __setup = {
        on_attach = __lspOnAttach,
        capabilities = __lspCapabilities(),
    }

    for i, server in ipairs(__lspServers) do
        if type(server) == "string" then
            require("lspconfig")[server].setup(__setup)
        else
            local options = server.extraOptions

            if options == nil then
                options = __setup
            else
                options = vim.tbl_extend("keep", options, __setup)
            end

            require("lspconfig")[server.name].setup(options)
        end
    end
end
-- }}}

require("ts_context_commentstring").setup({})

require("nvim-treesitter.configs").setup({
    ["highlight"] = { ["enable"] = true },
    ["incremental_selection"] = {
        ["enable"] = true,
        ["keymaps"] = {
            ["init_selection"] = "gnn",
            ["node_decremental"] = "grm",
            ["node_incremental"] = "grn",
            ["scope_incremental"] = "grc",
        },
    },
    ["indent"] = { ["enable"] = true },
})

__lint = require("lint")
__lint.linters_by_ft = {
    ["c"] = { "clang-tidy" },
    ["clojure"] = { "clj-kondo" },
    ["cpp"] = { "clang-tidy" },
    ["h"] = { "clang-tidy" },
    ["hpp"] = { "clang-tidy" },
    ["java"] = { "checkstyle" },
    ["javascript"] = { "eslint_d" },
    ["markdown"] = { "vale" },
    ["nix"] = { "statix" },
    ["python"] = { "flake8" },
    ["rust"] = { "clippy" },
    ["text"] = { "vale" },
}

require("gitsigns").setup({ ["current_line_blame"] = false })

vim.api.nvim_set_var(
    "chadtree_settings",
    { ["theme"] = { ["text_colour_set"] = "nerdtree_syntax_dark" }, ["xdg"] = true }
)

local cmp = require("cmp")
cmp.setup({
    ["extraConfigLua"] = '-- local cmp = require(\'cmp\')\n\n-- Use buffer source for `/` (if you enabled `native_menu`, this won\'t work anymore).\n-- cmp.setup.cmdline({\'/\', "?" }, {\n--   sources = {\n--     { name = \'buffer\' }\n--   }\n-- })\n\n-- Set configuration for specific filetype.\n-- cmp.setup.filetype(\'gitcommit\', {\n--   sources = cmp.config.sources({\n--     { name = \'cmp_git\' }, -- You can specify the `cmp_git` source if you were installed it.\n--   }, {\n--     { name = \'buffer\' },\n--   })\n-- })\n\n-- Use cmdline & path source for \':\' (if you enabled `native_menu`, this won\'t work anymore).\n-- cmp.setup.cmdline(\':\', {\n--   sources = cmp.config.sources({\n--     { name = \'path\' }\n--   }, {\n--     { name = \'cmdline\' }\n--   }),\n-- })\n\nkind_icons = {\n  Text = "󰊄",\n  Method = "",\n  Function = "󰡱",\n  Constructor = "",\n  Field = "",\n  Variable = "󱀍",\n  Class = "",\n  Interface = "",\n  Module = "󰕳",\n  Property = "",\n  Unit = "",\n  Value = "",\n  Enum = "",\n  Keyword = "",\n  Snippet = "",\n  Color = "",\n  File = "",\n  Reference = "",\n  Folder = "",\n  EnumMember = "",\n  Constant = "",\n  Struct = "",\n  Event = "",\n  Operator = "",\n  TypeParameter = "",\n}\n',
    ["mapping"] = cmp.mapping.preset.insert({
        ["<Down>"] = cmp.mapping.select_next_item(),
        ["<Up>"] = cmp.mapping.select_prev_item(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<Esc>"] = cmp.mapping.abort(),
        ["<C-Up>"] = cmp.mapping.scroll_docs(-4),
        ["<C-Down>"] = cmp.mapping.scroll_docs(4),
        -- ['<C-Space>'] = cmp.complete(),

        ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                if require("luasnip").expandable() then
                    require("luasnip").expand()
                else
                    cmp.confirm({ select = true })
                end
            else
                fallback()
            end
        end),

        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif require("luasnip").locally_jumpable(1) then
                require("luasnip").jump(1)
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif require("luasnip").locally_jumpable(-1) then
                require("luasnip").jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    ["snippet"] = {
        ["expand"] = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    ["sources"] = {
        { ["name"] = "async_path" },
        { ["name"] = "emoji" },
        { ["name"] = "nvim_lsp" },
        { ["name"] = "nvim_lsp_signature_help" },
        { ["name"] = "luasnip" },
    },
    ["window"] = {
        ["completion"] = {
            ["border"] = "rounded",
            ["winhighlight"] = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        },
        ["documentation"] = { ["border"] = "rounded" },
    },
})

require("nvim-navic").setup({ ["click"] = true, ["highlight"] = true, ["lsp"] = { ["auto_attach"] = true } })

-- Set up keybinds {{{
do
    local __nixvim_binds = {
        { ["action"] = require("intellitab").indent, ["key"] = "<Tab>", ["mode"] = "i" },
        { ["action"] = "<gv", ["key"] = "<", ["mode"] = "v", ["options"] = { ["desc"] = "Outdent" } },
        { ["action"] = ">gv", ["key"] = ">", ["mode"] = "v", ["options"] = { ["desc"] = "Indent" } },
        { ["action"] = "v<<Esc>", ["key"] = "<", ["mode"] = "n", ["options"] = { ["desc"] = "Outdent" } },
        { ["action"] = "v><Esc>", ["key"] = ">", ["mode"] = "n", ["options"] = { ["desc"] = "Indent" } },
        { ["action"] = "<C-d>zz", ["key"] = "<C-d>", ["mode"] = "n", ["options"] = { ["desc"] = "Jump down" } },
        { ["action"] = "<C-u>zz", ["key"] = "<C-u>", ["mode"] = "n", ["options"] = { ["desc"] = "Jump up" } },
        { ["action"] = "nzzzv", ["key"] = "n", ["mode"] = "n", ["options"] = { ["desc"] = "Next match" } },
        { ["action"] = "Nzzzv", ["key"] = "N", ["mode"] = "n", ["options"] = { ["desc"] = "Previous match" } },
        { ["action"] = "<C-w>", ["key"] = "<C-BS>", ["mode"] = "i", ["options"] = { ["desc"] = "Delete previous word" } },
        { ["action"] = "<C-w>", ["key"] = "<M-BS>", ["mode"] = "i", ["options"] = { ["desc"] = "Delete previous word" } },
        {
            ["action"] = '<Esc>"+pi',
            ["key"] = "<C-S-v>",
            ["mode"] = "i",
            ["options"] = { ["desc"] = "Paste from clipboard" },
        },
        { ["action"] = '<Esc>"+pi', ["key"] = "<C-v>", ["mode"] = "i", ["options"] = {
            ["desc"] = "Paste from clipboard",
        } },
        { ["action"] = '"+y', ["key"] = "<C-S-c>", ["mode"] = "v", ["options"] = { ["desc"] = "Copy to clipboard" } },
        {
            ["action"] = "<cmd>nohlsearch<CR>",
            ["key"] = "<C-h>",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Clear search highlights" },
        },
        { ["action"] = "<cmd>quitall<CR>", ["key"] = "<leader>qq", ["mode"] = "n", ["options"] = { ["desc"] = "Quit" } },
        {
            ["action"] = "<cmd>Telescope buffers<CR>",
            ["key"] = "<leader><Space>",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show open buffers" },
        },
        {
            ["action"] = "<cmd>wa<CR>",
            ["key"] = "<leader>S",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Save all buffers" },
        },
        {
            ["action"] = "<cmd>Telescope find_files<CR>",
            ["key"] = "<leader>f",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Find file" },
        },
        {
            ["action"] = "<cmd>Telescope vim_options<CR>",
            ["key"] = "<leader>o",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show Vim options" },
        },
        {
            ["action"] = "<cmd>Telescope undo<CR>",
            ["key"] = "<leader>u",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show undo history" },
        },
        {
            ["action"] = "<cmd>Telescope current_buffer_fuzzy_find<CR>",
            ["key"] = "<leader>/",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Find in current buffer" },
        },
        {
            ["action"] = "<cmd>Telescope notify<CR>",
            ["key"] = "<leader>n",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show notify history" },
        },
        {
            ["action"] = "<cmd>Telescope live_grep<CR>",
            ["key"] = "<leader>s",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Find in working directory" },
        },
        {
            ["action"] = "<cmd>Telescope resume<CR>",
            ["key"] = "<leader>r",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show last telescope picker" },
        },
        {
            ["action"] = "<cmd>Telescope keymaps<CR>",
            ["key"] = "<leader>?",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show keymaps" },
        },
        {
            ["action"] = "<cmd>Telescope commands<CR>",
            ["key"] = "<leader>:",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Execute command" },
        },
        {
            ["action"] = "<cmd>Telescope marks<CR>",
            ["key"] = "<leader>M",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show marks" },
        },
        {
            ["action"] = "<cmd>Telescope jumplist<CR>",
            ["key"] = "<leader>J",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show jumplist" },
        },
        {
            ["action"] = "<cmd>Telescope man_pages<CR>",
            ["key"] = "<leader>m",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show manpages" },
        },
        {
            ["action"] = "<cmd>Telescope help_tags<CR>",
            ["key"] = "<leader>h",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show help tags" },
        },
        { ["action"] = "+buffers", ["key"] = "<leader>b", ["mode"] = "n" },
        {
            ["action"] = "<cmd>Telescope buffers<CR>",
            ["key"] = "<leader>bb",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show open buffers" },
        },
        {
            ["action"] = "<cmd>bnext<CR>",
            ["key"] = "<leader>bn",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Goto next buffer" },
        },
        {
            ["action"] = "<cmd>bprevious<CR>",
            ["key"] = "<leader>bp",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Goto previous buffer" },
        },
        {
            ["action"] = "<cmd>Bdelete<CR>",
            ["key"] = "<leader>bd",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Close current buffer" },
        },
        { ["action"] = "+windows", ["key"] = "<leader>w", ["mode"] = "n" },
        {
            ["action"] = "<C-w>s",
            ["key"] = "<leader>ws",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Split window horizontally" },
        },
        {
            ["action"] = "<C-w>v",
            ["key"] = "<leader>wv",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Split window vertically" },
        },
        {
            ["action"] = "<C-w>c",
            ["key"] = "<leader>wd",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Close current window" },
        },
        { ["action"] = "<C-w>h", ["key"] = "<leader>wh", ["mode"] = "n", ["options"] = { ["desc"] = "Goto left window" } },
        { ["action"] = "<C-w>l", ["key"] = "<leader>wl", ["mode"] = "n", ["options"] = {
            ["desc"] = "Goto right window",
        } },
        { ["action"] = "<C-w>j", ["key"] = "<leader>wj", ["mode"] = "n", ["options"] = {
            ["desc"] = "Goto bottom window",
        } },
        { ["action"] = "<C-w>k", ["key"] = "<leader>wk", ["mode"] = "n", ["options"] = { ["desc"] = "Goto top window" } },
        { ["action"] = "<C-w>p", ["key"] = "<leader>ww", ["mode"] = "n", ["options"] = {
            ["desc"] = "Goto other window",
        } },
        { ["action"] = "+toggle", ["key"] = "<leader>t", ["mode"] = "n" },
        {
            ["action"] = "<cmd>CHADopen --nofocus<CR>",
            ["key"] = "<leader>tt",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Toggle CHADtree" },
        },
        {
            ["action"] = "<cmd>Navbuddy<CR>",
            ["key"] = "<leader>tn",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Toggle NavBuddy" },
        },
        {
            ["action"] = "<cmd>TroubleToggle focus=false<CR>",
            ["key"] = "<leader>td",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Toggle Trouble" },
        },
        { ["action"] = "+git", ["key"] = "<leader>g", ["mode"] = "n" },
        {
            ["action"] = "<cmd>LazyGit<CR>",
            ["key"] = "<leader>gg",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show LazyGit" },
        },
        {
            ["action"] = "<cmd>GitMessenger<CR>",
            ["key"] = "<leader>gm",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show GitMessenger" },
        },
        {
            ["action"] = "<cmd>Telescope git_status<CR>",
            ["key"] = "<leader>gs",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show Git status" },
        },
        {
            ["action"] = "<cmd>Telescope git_commits<CR>",
            ["key"] = "<leader>gc",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show Git log" },
        },
        {
            ["action"] = "<cmd>Telescope git_branches<CR>",
            ["key"] = "<leader>gb",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show Git branches" },
        },
        {
            ["action"] = "<cmd>Telescope git_bcommits<CR>",
            ["key"] = "<leader>gf",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show Git log for current file" },
        },
        { ["action"] = "+lsp", ["key"] = "<leader>l", ["mode"] = "n" },
        {
            ["action"] = "<cmd>Telescope lsp_references<CR>",
            ["key"] = "<leader>lr",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Goto references" },
        },
        {
            ["action"] = "<cmd>Telescope lsp_definitions<CR>",
            ["key"] = "<leader>ld",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Goto definition" },
        },
        {
            ["action"] = "<cmd>Telescope lsp_implementations<CR>",
            ["key"] = "<leader>li",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Goto implementation" },
        },
        {
            ["action"] = "<cmd>Telescope lsp_type_definitions<CR>",
            ["key"] = "<leader>lt",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Goto type definition" },
        },
        {
            ["action"] = "<cmd>Telescope lsp_incoming_calls<CR>",
            ["key"] = "<leader>lI",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show incoming calls" },
        },
        {
            ["action"] = "<cmd>Telescope lsp_outgoing_calls<CR>",
            ["key"] = "<leader>lO",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show outgoing calls" },
        },
        { ["action"] = "+code", ["key"] = "<leader>c", ["mode"] = "n" },
        {
            ["action"] = "<cmd>lua require('conform').format()<CR>",
            ["key"] = "<leader>cf",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Format current buffer" },
        },
        {
            ["action"] = "<cmd>Telescope diagnostics<CR>",
            ["key"] = "<leader>cd",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show diagnostics" },
        },
    }
    for i, map in ipairs(__nixvim_binds) do
        vim.keymap.set(map.mode, map.key, map.action, map.options)
    end
end
-- }}}

vim.filetype.add({ ["extension"] = { ["v"] = "vlang" } })

local opt = vim.opt
local g = vim.g
local o = vim.o

-- Neovide
if g.neovide then
    require("notify").notify("Running in NeoVide")

    g.neovide_cursor_animate_command_line = true
    g.neovide_cursor_animate_in_insert_mode = true
    g.neovide_fullscreen = false
    g.neovide_hide_mouse_when_typing = false
    g.neovide_padding_top = 0
    g.neovide_padding_bottom = 0
    g.neovide_padding_right = 0
    g.neovide_padding_left = 0
    g.neovide_refresh_rate = 144
    g.neovide_theme = "light"

    -- Neovide Fonts
    o.guifont = "JetBrainsMono Nerd Font:h13:Medium"
else
    require("notify").notify("Not running in NeoVide")
end

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

-- Set up autogroups {{
do
    local __nixvim_autogroups = { ["nixvim_binds_LspAttach"] = { ["clear"] = true } }

    for group_name, options in pairs(__nixvim_autogroups) do
        vim.api.nvim_create_augroup(group_name, options)
    end
end
-- }}
-- Set up autocommands {{
do
    local __nixvim_autocommands = {
        {
            ["callback"] = function()
                require("lint").try_lint()
            end,
            ["event"] = "BufWritePost",
        },
        {
            ["callback"] = function()
                do
                    local __nixvim_binds = {
                        {
                            ["action"] = vim.diagnostic.open_float,
                            ["key"] = "<leader>cD",
                            ["mode"] = "n",
                            ["options"] = { ["desc"] = "Show line diagnostic", ["silent"] = false },
                        },
                        {
                            ["action"] = vim.lsp.buf.code_action,
                            ["key"] = "<leader>ca",
                            ["mode"] = "n",
                            ["options"] = { ["desc"] = "Show code actions", ["silent"] = false },
                        },
                        {
                            ["action"] = vim.lsp.buf.rename,
                            ["key"] = "<leader>cr",
                            ["mode"] = "n",
                            ["options"] = { ["desc"] = "Rename symbol", ["silent"] = false },
                        },
                        {
                            ["action"] = vim.lsp.buf.hover,
                            ["key"] = "K",
                            ["mode"] = "n",
                            ["options"] = { ["desc"] = "Hover information", ["silent"] = false },
                        },
                    }
                    for i, map in ipairs(__nixvim_binds) do
                        vim.keymap.set(map.mode, map.key, map.action, map.options)
                    end
                end
            end,
            ["desc"] = "Load keymaps for LspAttach",
            ["event"] = "LspAttach",
            ["group"] = "nixvim_binds_LspAttach",
        },
    }

    for _, autocmd in ipairs(__nixvim_autocommands) do
        vim.api.nvim_create_autocmd(autocmd.event, {
            group = autocmd.group,
            pattern = autocmd.pattern,
            buffer = autocmd.buffer,
            desc = autocmd.desc,
            callback = autocmd.callback,
            command = autocmd.command,
            once = autocmd.once,
            nested = autocmd.nested,
        })
    end
end
-- }}
