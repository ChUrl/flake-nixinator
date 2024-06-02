-- Set up globals {{{
do
    local nixvim_globals = { ["mallocalleader"] = " ", ["mapleader"] = " " }

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
        ["foldlevel"] = 99,
        ["foldlevelstart"] = 99,
        ["formatexpr"] = "v:lua.require('conform').formatexpr()",
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
        ["undodir"] = "/home/lab/smchurla/.vim/undo",
        ["undofile"] = true,
    }

    for k, v in pairs(nixvim_options) do
        vim.opt[k] = v
    end
end
-- }}}

vim.loader.enable()

vim.cmd([[
  
]])
require("lazy").setup({
    dev = {
        path = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins",
        patterns = { "." },
        fallback = false,
    },
    spec = {
        {
            "catppuccin",
            ["config"] = function(_, opts)
                require("catppuccin").setup(opts)

                vim.cmd([[
    let $BAT_THEME = "catppuccin"
    colorscheme catppuccin
  ]])
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/catppuccin-nvim",
            ["lazy"] = false,
            ["name"] = "catppuccin",
            ["opts"] = { ["background"] = { ["dark"] = "mocha", ["light"] = "latte" }, ["flavour"] = "mocha" },
            ["priority"] = 1000,
        },
        {
            "web-devicons",
            ["config"] = function(_, opts)
                require("nvim-web-devicons").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-web-devicons",
            ["lazy"] = false,
            ["name"] = "web-devicons",
        },
        {
            "autopairs",
            ["config"] = function(_, opts)
                require("nvim-autopairs").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-autopairs",
            ["lazy"] = false,
            ["name"] = "autopairs",
        },
        {
            "bbye",
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/vim-bbye",
            ["lazy"] = false,
            ["name"] = "bbye",
        },
        {
            "better-escape",
            ["config"] = function(_, opts)
                require("better_escape").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/better-escape.nvim",
            ["lazy"] = false,
            ["name"] = "better-escape",
            ["opts"] = { ["mapping"] = { "jk" }, ["timeout"] = 200 },
        },
        {
            "chadtree",
            ["config"] = function(_, opts)
                vim.api.nvim_set_var("chadtree_settings", opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/chadtree",
            ["lazy"] = false,
            ["name"] = "chadtree",
            ["opts"] = { ["theme"] = { ["text_colour_set"] = "nord" }, ["xdg"] = true },
        },
        {
            "clangd-extensions",
            ["config"] = function(_, opts)
                require("clangd_extensions").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/clangd_extensions.nvim",
            ["lazy"] = false,
            ["name"] = "clangd-extensions",
        },
        {
            "cmp",
            ["config"] = function(_, opts)
                require("cmp").setup(opts)
            end,
            ["dependencies"] = {
                {
                    "cmp-async-path",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/cmp-async-path",
                    ["lazy"] = false,
                    ["name"] = "cmp-async-path",
                },
                {
                    "cmp-buffer",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/cmp-buffer",
                    ["enabled"] = false,
                    ["lazy"] = false,
                    ["name"] = "cmp-buffer",
                },
                {
                    "cmp-cmdline",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/cmp-cmdline",
                    ["enabled"] = false,
                    ["lazy"] = false,
                    ["name"] = "cmp-cmdline",
                },
                {
                    "cmp-emoji",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/cmp-emoji",
                    ["lazy"] = false,
                    ["name"] = "cmp-emoji",
                },
                {
                    "cmp-nvim-lsp",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/cmp-nvim-lsp",
                    ["lazy"] = false,
                    ["name"] = "cmp-nvim-lsp",
                },
                {
                    "cmp-nvim-lsp-signature-help",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/cmp-nvim-lsp-signature-help",
                    ["lazy"] = false,
                    ["name"] = "cmp-nvim-lsp-signature-help",
                },
                {
                    "cmp-luasnip",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/cmp_luasnip",
                    ["lazy"] = false,
                    ["name"] = "cmp-luasnip",
                },
            },
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-cmp",
            ["lazy"] = false,
            ["name"] = "cmp",
            ["opts"] = function()
                local cmp = require("cmp")
                local luasnip = require("luasnip")

                local has_words_before = function()
                    unpack = unpack or table.unpack
                    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                    return col ~= 0
                        and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
                end

                return {
                    sources = cmp.config.sources({
                        { ["name"] = "async_path" },
                        { ["name"] = "emoji" },
                        { ["name"] = "nvim_lsp" },
                        { ["name"] = "nvim_lsp_signature_help" },
                        { ["name"] = "luasnip" },
                    }),

                    snippet = {
                        expand = function(args)
                            require("luasnip").lsp_expand(args.body)
                        end,
                    },

                    window = {
                        completion = cmp.config.window.bordered(),
                        documentation = cmp.config.window.bordered(),
                        -- completion.border = "rounded",
                        -- documentation.border = "rounded",
                    },

                    mapping = cmp.mapping.preset.insert({
                        ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                        ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                        ["<C-e>"] = cmp.mapping.abort(),
                        ["<Esc>"] = cmp.mapping.abort(),
                        ["<C-Up>"] = cmp.mapping.scroll_docs(-4),
                        ["<C-Down>"] = cmp.mapping.scroll_docs(4),
                        ["<C-Space>"] = cmp.mapping.complete({}),

                        ["<CR>"] = cmp.mapping.confirm({ select = true }),

                        ["<Tab>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            elseif require("luasnip").expand_or_jumpable() then
                                require("luasnip").expand_or_jump()
                            elseif has_words_before() then
                                cmp.complete()
                            else
                                fallback()
                            end
                        end, { "i", "s" }),

                        ["<S-Tab>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif luasnip.jumpable(-1) then
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                    }),
                }
            end,
        },
        {
            "colorizer",
            ["config"] = function(_, opts)
                require("colorizer").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-colorizer.lua",
            ["lazy"] = false,
            ["name"] = "colorizer",
        },
        {
            "comment",
            ["config"] = function(_, opts)
                require("Comment").setup(opts)
            end,
            ["dependencies"] = {
                {
                    "ts-context-commentstring",
                    ["config"] = function(_, opts)
                        vim.g.skip_ts_context_commentstring_module = true -- Skip compatibility checks

                        require("ts_context_commentstring").setup(opts)
                    end,
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-ts-context-commentstring",
                    ["lazy"] = false,
                    ["name"] = "ts-context-commentstring",
                },
            },
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/comment.nvim",
            ["lazy"] = false,
            ["name"] = "comment",
            ["opts"] = {
                ["mappings"] = { ["basic"] = true, ["extra"] = false },
                ["opleader"] = { ["block"] = "<C-b>", ["line"] = "<C-c>" },
                ["pre_hook"] = function()
                    require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
                end,
                ["toggler"] = { ["block"] = "<C-b>", ["line"] = "<C-c>" },
            },
        },
        {
            "conform",
            ["config"] = function(_, opts)
                require("conform").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/conform.nvim",
            ["lazy"] = false,
            ["name"] = "conform",
            ["opts"] = {
                ["formatters_by_ft"] = {
                    ["c"] = { "clang-format" },
                    ["cpp"] = { "clang-format" },
                    ["css"] = { { "prettierd", "prettier" } },
                    ["h"] = { "clang-format" },
                    ["hpp"] = { "clang-format" },
                    ["html"] = { { "prettierd", "prettier" } },
                    ["java"] = { "google-java-format" },
                    ["javascript"] = { { "prettierd", "prettier" } },
                    ["lua"] = { "stylua" },
                    ["markdown"] = { { "prettierd", "prettier" } },
                    ["nix"] = { "alejandra" },
                    ["python"] = { "black" },
                    ["rust"] = { "rustfmt" },
                },
            },
        },
        {
            "flash",
            ["config"] = function(_, opts)
                require("flash").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/flash.nvim",
            ["lazy"] = false,
            ["name"] = "flash",
        },
        {
            "gitmessenger",
            ["config"] = function(_, opts)
                for k, v in pairs(opts) do
                    vim.g[k] = v
                end
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/git-messenger.vim",
            ["lazy"] = false,
            ["name"] = "gitmessenger",
            ["opts"] = {
                ["git_messenger_floating_win_opts"] = { ["border"] = "rounded" },
                ["git_messenger_no_default_mappings"] = true,
            },
        },
        {
            "gitsigns",
            ["config"] = function(_, opts)
                require("gitsigns").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/gitsigns.nvim",
            ["lazy"] = false,
            ["name"] = "gitsigns",
            ["opts"] = { ["current_line_blame"] = false },
        },
        {
            "haskell-tools",
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/haskell-tools.nvim",
            ["lazy"] = false,
            ["name"] = "haskell-tools",
        },
        {
            "illuminate",
            ["config"] = function(_, opts)
                require("illuminate").configure(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/vim-illuminate",
            ["lazy"] = false,
            ["name"] = "illuminate",
            ["opts"] = {
                ["filetypesDenylist"] = {
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
            },
        },
        {
            "intellitab",
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/intellitab.nvim",
            ["lazy"] = false,
            ["name"] = "intellitab",
        },
        {
            "lastplace",
            ["config"] = function(_, opts)
                require("nvim-lastplace").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-lastplace",
            ["lazy"] = false,
            ["name"] = "lastplace",
        },
        {
            "lazygit",
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/lazygit.nvim",
            ["lazy"] = false,
            ["name"] = "lazygit",
        },
        {
            "lint",
            ["config"] = function(_, opts)
                local lint = require("lint")

                for k, v in pairs(opts) do
                    lint[k] = v
                end
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-lint",
            ["lazy"] = false,
            ["name"] = "lint",
            ["opts"] = {
                ["linters_by_ft"] = {
                    ["c"] = { "clang-tidy" },
                    ["clojure"] = { "clj-kondo" },
                    ["cpp"] = { "clang-tidy" },
                    ["h"] = { "clang-tidy" },
                    ["hpp"] = { "clang-tidy" },
                    ["java"] = { "checkstyle" },
                    ["javascript"] = { "eslint_d" },
                    ["lua"] = { "luacheck" },
                    ["markdown"] = { "vale" },
                    ["nix"] = { "statix" },
                    ["python"] = { "flake8" },
                    ["rust"] = { "clippy" },
                    ["text"] = { "vale" },
                },
            },
        },
        {
            "lspconfig",
            ["config"] = function(_, opts)
                local __lspOnAttach = function(client, bufnr) end

                local __lspCapabilities = function()
                    capabilities = vim.lsp.protocol.make_client_capabilities()
                    capabilities =
                        vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
                    return capabilities
                end

                local __setup = {
                    on_attach = __lspOnAttach,
                    capabilities = __lspCapabilities(),
                }

                for i, server in ipairs({
                    { ["name"] = "clangd" },
                    { ["name"] = "clojure_lsp" },
                    { ["name"] = "cmake" },
                    { ["name"] = "lua_ls" },
                    { ["name"] = "nil_ls" },
                    { ["name"] = "pyright" },
                    { ["name"] = "texlab" },
                }) do
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
            end,
            ["dependencies"] = {
                {
                    "neodev",
                    ["config"] = function(_, opts)
                        require("neodev").setup(opts)
                    end,
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/neodev.nvim",
                    ["lazy"] = false,
                    ["name"] = "neodev",
                },
            },
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-lspconfig",
            ["lazy"] = false,
            ["name"] = "lspconfig",
        },
        {
            "lualine",
            ["config"] = function(_, opts)
                require("lualine").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/lualine.nvim",
            ["lazy"] = false,
            ["name"] = "lualine",
            ["opts"] = {
                ["extensions"] = { "fzf", "chadtree", "neo-tree", "toggleterm", "trouble" },
                ["options"] = {
                    ["always_divide_middle"] = true,
                    ["component_separators"] = { ["left"] = "", ["right"] = "" },
                    ["globalstatus"] = true,
                    ["ignore_focus"] = { "neo-tree", "chadtree" },
                    ["section_separators"] = { ["left"] = "", ["right"] = "" },
                },
                ["sections"] = {
                    ["lualine_a"] = { "mode" },
                    ["lualine_b"] = { "branch", "diff", "diagnostics" },
                    ["lualine_c"] = { { ["extraConfig"] = { ["path"] = 1 }, ["name"] = "filename" } },
                    ["lualine_x"] = { "filetype", "encoding", "fileformat" },
                    ["lualine_y"] = { "progress", "searchcount", "selectioncount" },
                    ["lualine_z"] = { "location" },
                },
                ["tabline"] = { ["lualine_a"] = { "buffers" }, ["lualine_z"] = { "tabs" } },
            },
        },
        {
            "luasnip",
            ["config"] = function(_, opts)
                require("luasnip").config.set_config(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/luasnip",
            ["lazy"] = false,
            ["name"] = "luasnip",
        },
        {
            "navbuddy",
            ["config"] = function(_, opts)
                local actions = require("nvim-navbuddy.actions") -- ?
                require("nvim-navbuddy").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-navbuddy",
            ["lazy"] = false,
            ["name"] = "navbuddy",
            ["opts"] = { ["lsp"] = { ["auto_attach"] = true }, ["window"] = { ["border"] = "rounded" } },
        },
        {
            "navic",
            ["config"] = function(_, opts)
                require("nvim-navic").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-navic",
            ["lazy"] = false,
            ["name"] = "navic",
            ["opts"] = { ["click"] = true, ["highlight"] = true, ["lsp"] = { ["auto_attach"] = true } },
        },
        {
            "noice",
            ["config"] = function(_, opts)
                require("noice").setup(opts)
            end,
            ["dependencies"] = {
                {
                    "nui",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nui.nvim",
                    ["lazy"] = false,
                    ["name"] = "nui",
                },
            },
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/noice.nvim",
            ["lazy"] = false,
            ["name"] = "noice",
            ["opts"] = {
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
                ["routes"] = {
                    { ["filter"] = { ["event"] = "msg_show", ["kind"] = "search_count" }, ["opts"] = { ["skip"] = true } },
                },
            },
        },
        {
            "notify",
            ["config"] = function(_, opts)
                vim.notify = require("notify")
                require("notify").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-notify",
            ["lazy"] = false,
            ["name"] = "notify",
        },
        {
            "rainbow-delimiters",
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/rainbow-delimiters.nvim",
            ["lazy"] = false,
            ["name"] = "rainbow-delimiters",
        },
        {
            "rustaceanvim",
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/rustaceanvim",
            ["lazy"] = false,
            ["name"] = "rustaceanvim",
        },
        {
            "sandwich",
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/vim-sandwich",
            ["lazy"] = false,
            ["name"] = "sandwich",
        },
        {
            "sleuth",
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/vim-sleuth",
            ["lazy"] = false,
            ["name"] = "sleuth",
        },
        {
            "telescope",
            ["config"] = function(_, opts)
                local telescope = require("telescope")
                telescope.setup(opts)

                for i, extension in ipairs({ "undo", "ui-select", "fzf" }) do
                    telescope.load_extension(extension)
                end
            end,
            ["dependencies"] = {
                {
                    "plenary",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/plenary.nvim",
                    ["lazy"] = false,
                    ["name"] = "plenary",
                },
                {
                    "telescope-undo",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/telescope-undo.nvim",
                    ["lazy"] = false,
                    ["name"] = "telescope-undo",
                },
                {
                    "telescope-ui-select",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/telescope-ui-select.nvim",
                    ["lazy"] = false,
                    ["name"] = "telescope-ui-select",
                },
                {
                    "telescope-fzf-native",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/telescope-fzf-native.nvim",
                    ["lazy"] = false,
                    ["name"] = "telescope-fzf-native",
                },
            },
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/telescope.nvim",
            ["lazy"] = false,
            ["name"] = "telescope",
            ["opts"] = {
                ["defaults"] = {
                    ["mappings"] = {
                        ["i"] = {
                            ["<Esc>"] = function(...)
                                return require("telescope.actions").close(...)
                            end,
                        },
                    },
                },
            },
        },
        {
            "todo-comments",
            ["dependencies"] = {
                {
                    "plenary",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/plenary.nvim",
                    ["lazy"] = false,
                    ["name"] = "plenary",
                },
            },
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/todo-comments.nvim",
            ["lazy"] = false,
            ["name"] = "todo-comments",
        },
        {
            "toggleterm",
            ["config"] = function(_, opts)
                require("toggleterm").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/toggleterm.nvim",
            ["lazy"] = false,
            ["name"] = "toggleterm",
            ["opts"] = {
                ["auto_scroll"] = true,
                ["close_on_exit"] = true,
                ["direction"] = "horizontal",
                ["float_opts"] = { ["border"] = "curved", ["height"] = 20, ["width"] = 80, ["winblend"] = 0 },
                ["hide_numbers"] = true,
                ["insert_mappings"] = true,
                ["open_mapping"] = [[<C-/>]],
                ["persist_mode"] = true,
                ["shade_terminals"] = true,
                ["shell"] = "fish",
                ["start_in_insert"] = true,
                ["terminal_mappings"] = true,
            },
        },
        {
            "treesitter",
            ["config"] = function(_, opts)
                -- Fix treesitter grammars/parsers on nix
                vim.opt.runtimepath:append(
                    "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/nvim-treesitter"
                )
                vim.opt.runtimepath:append("/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/treesitter-parsers")

                require("nvim-treesitter.configs").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-treesitter",
            ["lazy"] = false,
            ["name"] = "treesitter",
            ["opts"] = {
                ["auto_install"] = false,
                ["highlight"] = { ["additional_vim_regex_highlighting"] = false, ["enable"] = true },
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
                ["parser_install_dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/treesitter-parsers",
            },
        },
        {
            "trim",
            ["config"] = function(_, opts)
                require("trim").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/trim.nvim",
            ["lazy"] = false,
            ["name"] = "trim",
        },
        {
            "trouble",
            ["config"] = function(_, opts)
                require("trouble").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/trouble.nvim",
            ["lazy"] = false,
            ["name"] = "trouble",
        },
        {
            "ufo",
            ["config"] = function(_, opts)
                require("ufo").setup(opts)
            end,
            ["dependencies"] = {
                {
                    "promise",
                    ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/promise-async",
                    ["lazy"] = false,
                    ["name"] = "promise",
                },
            },
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/nvim-ufo",
            ["lazy"] = false,
            ["name"] = "ufo",
        },
        {
            "which-key",
            ["config"] = function(_, opts)
                require("which-key").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/which-key.nvim",
            ["lazy"] = false,
            ["name"] = "which-key",
            ["priority"] = 500,
        },
        {
            "yanky",
            ["config"] = function(_, opts)
                require("yanky").setup(opts)
            end,
            ["dir"] = "/home/lab/smchurla/Downloads/flake-nixinator/config/neovim/store/lazy-plugins/yanky.nvim",
            ["lazy"] = false,
            ["name"] = "yanky",
        },
    },
})

-- Set up keybinds {{{
do
    local __nixvim_binds = {
        { ["action"] = "<cmd>w<CR>", ["key"] = "<C-s>", ["mode"] = "n", ["options"] = {
            ["desc"] = "Save current buffer",
        } },
        { ["action"] = "<cmd>wa<CR>", ["key"] = "<C-S-s>", ["mode"] = "n", ["options"] = {
            ["desc"] = "Save all buffers",
        } },
        { ["action"] = "<gv", ["key"] = "<", ["mode"] = "v", ["options"] = { ["desc"] = "Outdent" } },
        { ["action"] = ">gv", ["key"] = ">", ["mode"] = "v", ["options"] = { ["desc"] = "Indent" } },
        { ["action"] = "v<<Esc>", ["key"] = "<", ["mode"] = "n", ["options"] = { ["desc"] = "Outdent" } },
        { ["action"] = "v><Esc>", ["key"] = ">", ["mode"] = "n", ["options"] = { ["desc"] = "Indent" } },
        { ["action"] = "<C-d>zz", ["key"] = "<C-d>", ["mode"] = "n", ["options"] = { ["desc"] = "Jump down" } },
        { ["action"] = "<C-u>zz", ["key"] = "<C-u>", ["mode"] = "n", ["options"] = { ["desc"] = "Jump up" } },
        { ["action"] = "nzzzv", ["key"] = "n", ["mode"] = "n", ["options"] = { ["desc"] = "Next match" } },
        { ["action"] = "Nzzzv", ["key"] = "N", ["mode"] = "n", ["options"] = { ["desc"] = "Previous match" } },
        {
            ["action"] = "<cmd>lua require('intellitab').indent()<CR>",
            ["key"] = "<Tab>",
            ["mode"] = "i",
            ["options"] = { ["desc"] = "Indent" },
        },
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
        {
            ["action"] = "<cmd>lua vim.lsp.buf.hover()<CR>",
            ["key"] = "K",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show LSP hover" },
        },
        { ["action"] = "<cmd>quitall<CR>", ["key"] = "<leader>qq", ["mode"] = "n", ["options"] = { ["desc"] = "Quit" } },
        {
            ["action"] = "<cmd>quitall!<CR>",
            ["key"] = "<leader>q!",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Forceful quit" },
        },
        { ["action"] = "<cmd>Lazy<CR>", ["key"] = "<leader>L", ["mode"] = "n", ["options"] = { ["desc"] = "Show Lazy" } },
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
        { ["action"] = "+quit", ["key"] = "<leader>q", ["mode"] = "n" },
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
        {
            ["action"] = "<cmd>lua vim.lsp.buf.rename()<CR>",
            ["key"] = "<leader>cr",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Rename LSP symbol" },
        },
        {
            ["action"] = "<cmd>lua vim.lsp.buf.code_action()<CR>",
            ["key"] = "<leader>ca",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show LSP code actions" },
        },
        {
            ["action"] = "<cmd>lua vim.diagnostic.open_float()<CR>",
            ["key"] = "<leader>cD",
            ["mode"] = "n",
            ["options"] = { ["desc"] = "Show LSP line diagnostics" },
        },
    }
    for i, map in ipairs(__nixvim_binds) do
        vim.keymap.set(map.mode, map.key, map.action, map.options)
    end
end
-- }}}

vim.filetype.add({ ["extension"] = { ["v"] = "vlang" } })

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

-- Set up autocommands {{
do
    local __nixvim_autocommands = {
        {
            ["callback"] = function()
                require("lint").try_lint()
            end,
            ["event"] = { "BufWritePost" },
        },
        {
            ["callback"] = function()
                require("conform").format()
            end,
            ["event"] = { "BufWritePre" },
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

local opt = vim.opt
local g = vim.g
local o = vim.o

-- Neovide
if g.neovide then
    -- require("notify").notify("Running in NeoVide")

    g.neovide_cursor_animate_command_line = true
    g.neovide_cursor_animate_in_insert_mode = true
    -- g.neovide_fullscreen = false
    g.neovide_hide_mouse_when_typing = true
    g.neovide_padding_top = 0
    g.neovide_padding_bottom = 0
    g.neovide_padding_right = 0
    g.neovide_padding_left = 0
    g.neovide_refresh_rate = 144
    -- g.neovide_theme = "light"

    -- Neovide Fonts
    o.guifont = "JetBrainsMono Nerd Font:h13:Medium"
else
    -- require("notify").notify("Not running in NeoVide")
end
