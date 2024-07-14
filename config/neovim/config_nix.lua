-- Set up globals {{{
do
    local nixvim_globals = { mallocalleader = " ", mapleader = " " }

    for k, v in pairs(nixvim_globals) do
        vim.g[k] = v
    end
end
-- }}}

-- Set up options {{{
do
    local nixvim_options = {
        autoindent = false,
        backspace = { "indent", "eol", "start" },
        cindent = true,
        cinkeys = "0{,0},0),0],:,!^F,o,O,e",
        completeopt = { "menuone", "noselect", "noinsert" },
        confirm = true,
        cursorline = true,
        encoding = "utf-8",
        expandtab = true,
        fileencoding = "utf-8",
        foldcolumn = "0",
        foldenable = true,
        foldlevel = 99,
        foldlevelstart = 99,
        formatexpr = "v:lua.require('conform').formatexpr()",
        grepformat = "%f:%l:%c:%m",
        grepprg = "rg --vimgrep",
        hidden = true,
        hlsearch = true,
        ignorecase = true,
        incsearch = true,
        laststatus = 3,
        mouse = "a",
        number = true,
        pumheight = 0,
        relativenumber = true,
        ruler = true,
        scrolloff = 10,
        sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
        shiftwidth = 4,
        showmode = false,
        showtabline = 0,
        signcolumn = "yes",
        smartcase = true,
        smartindent = false,
        smarttab = true,
        softtabstop = 4,
        splitbelow = true,
        splitright = true,
        tabstop = 4,
        termguicolors = true,
        timeoutlen = 50,
        undodir = "/home/christoph/.vim/undo",
        undofile = true,
        undolevels = 10000,
        winblend = 30,
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
        path = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins",
        patterns = { "." },
        fallback = false,
    },
    spec = {
        {
            "catppuccin",
            config = function(_, opts)
                require("catppuccin").setup(opts)

                vim.cmd([[
    let $BAT_THEME = "catppuccin"
    colorscheme catppuccin
  ]])
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/catppuccin-nvim",
            lazy = false,
            name = "catppuccin",
            opts = { background = { dark = "mocha", light = "latte" }, flavour = "mocha" },
            priority = 1000,
        },
        {
            "nvim-web-devicons",
            config = function(_, opts)
                require("nvim-web-devicons").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-web-devicons",
            lazy = true,
            name = "nvim-web-devicons",
        },
        {
            "nvim-autopairs",
            config = function(_, opts)
                require("nvim-autopairs").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-autopairs",
            event = { "InsertEnter" },
            lazy = true,
            name = "nvim-autopairs",
            opts = { check_ts = true },
        },
        {
            "vim-bbye",
            cmd = { "Bdelete", "Bwipeout" },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/vim-bbye",
            lazy = true,
            name = "vim-bbye",
        },
        {
            "better_escape",
            config = function(_, opts)
                require("better_escape").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/better-escape.nvim",
            event = { "InsertEnter" },
            lazy = true,
            name = "better_escape",
            opts = { mapping = { "jk" }, timeout = 200 },
        },
        {
            "clangd_extensions",
            config = function(_, opts)
                require("clangd_extensions").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/clangd_extensions.nvim",
            lazy = true,
            name = "clangd_extensions",
            opts = { inlay_hints = { inline = false } },
        },
        {
            "cmp",
            config = function(_, opts)
                require("cmp").setup(opts)
            end,
            dependencies = {
                {
                    "cmp-async-path",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/cmp-async-path",
                    lazy = true,
                    name = "cmp-async-path",
                },
                {
                    "cmp-buffer",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/cmp-buffer",
                    enabled = false,
                    lazy = true,
                    name = "cmp-buffer",
                },
                {
                    "cmp-cmdline",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/cmp-cmdline",
                    enabled = false,
                    lazy = true,
                    name = "cmp-cmdline",
                },
                {
                    "cmp-emoji",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/cmp-emoji",
                    lazy = true,
                    name = "cmp-emoji",
                },
                {
                    "cmp-nvim-lsp",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/cmp-nvim-lsp",
                    lazy = true,
                    name = "cmp-nvim-lsp",
                },
                {
                    "cmp-nvim-lsp-signature-help",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/cmp-nvim-lsp-signature-help",
                    lazy = true,
                    name = "cmp-nvim-lsp-signature-help",
                },
                {
                    "cmp_luasnip",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/cmp_luasnip",
                    lazy = true,
                    name = "cmp_luasnip",
                },
            },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-cmp",
            event = { "InsertEnter" },
            lazy = true,
            name = "cmp",
            opts = function()
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
                        ["<C-Down>"] = cmp.mapping.scroll_docs(4),
                        ["<C-Space>"] = cmp.mapping.complete({}),
                        ["<C-Up>"] = cmp.mapping.scroll_docs(-4),
                        ["<C-e>"] = cmp.mapping.abort(),
                        ["<CR>"] = cmp.mapping.confirm({ select = true }),
                        ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                        ["<Esc>"] = cmp.mapping.abort(),
                        ["<S-Tab>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif luasnip.jumpable(-1) then
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                        ["<Tab>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            elseif require("luasnip").expand_or_jumpable() then
                                require("luasnip").expand_or_jump()
                            elseif has_words_before() then
                                cmp.complete()
                            else
                                fallback() -- This will call the intellitab <Tab> binding
                            end
                        end, { "i", "s" }),
                        ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                    }),
                }
            end,
        },
        {
            "Comment",
            config = function(_, opts)
                require("Comment").setup(opts)
            end,
            dependencies = {
                {
                    "ts_context_commentstring",
                    config = function(_, opts)
                        require("ts_context_commentstring").setup(opts)
                    end,
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-ts-context-commentstring",
                    init = function()
                        -- Skip compatibility checks
                        vim.g.skip_ts_context_commentstring_module = true
                    end,
                    lazy = true,
                    name = "ts_context_commentstring",
                },
            },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/comment.nvim",
            lazy = false,
            name = "Comment",
            opts = {
                mappings = { basic = true, extra = false },
                opleader = { block = "<C-b>", line = "<C-c>" },
                pre_hook = function()
                    require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
                end,
                toggler = { block = "<C-b>", line = "<C-c>" },
            },
        },
        {
            "conform",
            config = function(_, opts)
                require("conform").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/conform.nvim",
            event = { "BufReadPost", "BufNewFile" },
            lazy = true,
            name = "conform",
            opts = {
                format_on_save = function(bufnr)
                    -- Disable with a global or buffer-local variable
                    if vim.g.disable_autoformat then
                        return
                    end
                    return { timeout_ms = 500, lsp_fallback = true }
                end,
                formatters_by_ft = {
                    c = { "clang-format" },
                    cpp = { "clang-format" },
                    css = { { "prettierd", "prettier" } },
                    h = { "clang-format" },
                    hpp = { "clang-format" },
                    html = { { "prettierd", "prettier" } },
                    java = { "google-java-format" },
                    javascript = { { "prettierd", "prettier" } },
                    lua = { "stylua" },
                    markdown = { { "prettierd", "prettier" } },
                    nix = { "alejandra" },
                    python = { "black" },
                    rust = { "rustfmt" },
                },
            },
        },
        {
            "dashboard",
            config = function(_, opts)
                require("dashboard").setup(opts)
            end,
            dependencies = {
                {
                    "nvim-web-devicons",
                    config = function(_, opts)
                        require("nvim-web-devicons").setup(opts)
                    end,
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-web-devicons",
                    lazy = true,
                    name = "nvim-web-devicons",
                },
                {
                    "persisted",
                    cmd = { "SessionSave", "SessionDelete", "Telescope persisted" },
                    config = function(_, opts)
                        require("persisted").setup(opts)

                        require("telescope").load_extension("persisted")
                    end,
                    dependencies = {
                        {
                            "telescope",
                            cmd = { "Telescope" },
                            config = function(_, opts)
                                local telescope = require("telescope")
                                telescope.setup(opts)

                                for i, extension in ipairs({ "undo", "ui-select", "fzf" }) do
                                    telescope.load_extension(extension)
                                end
                            end,
                            dependencies = {
                                {
                                    "plenary",
                                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/plenary.nvim",
                                    lazy = true,
                                    name = "plenary",
                                },
                                {
                                    "telescope-fzf-native",
                                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/telescope-fzf-native.nvim",
                                    lazy = true,
                                    name = "telescope-fzf-native",
                                },
                                {
                                    "telescope-undo",
                                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/telescope-undo.nvim",
                                    lazy = true,
                                    name = "telescope-undo",
                                },
                                {
                                    "telescope-ui-select",
                                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/telescope-ui-select.nvim",
                                    lazy = true,
                                    name = "telescope-ui-select",
                                },
                            },
                            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/telescope.nvim",
                            lazy = true,
                            name = "telescope",
                            opts = {
                                defaults = {
                                    mappings = {
                                        i = {
                                            ["<Esc>"] = function(...)
                                                return require("telescope.actions").close(...)
                                            end,
                                        },
                                    },
                                },
                            },
                        },
                    },
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/persisted.nvim",
                    lazy = true,
                    name = "persisted",
                    opts = {
                        autoload = false,
                        autosave = false,
                        follow_cwd = true,
                        ignored_dirs = { "/", "~/", "~/Projects/" },
                        silent = false,
                        use_git_branch = false,
                    },
                },
            },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/dashboard-nvim",
            lazy = false,
            name = "dashboard",
            opts = {
                config = {
                    center = {
                        { action = "Telescope persisted", desc = " Restore Session", icon = " ", key = "s" },
                        { action = "Telescope find_files", desc = " Find File", icon = " ", key = "f" },
                        { action = "Telescope oldfiles", desc = " Recent Files", icon = " ", key = "r" },
                        { action = "ene | startinsert", desc = " New File", icon = " ", key = "n" },
                        { action = "Telescope live_grep", desc = " Find Text", icon = " ", key = "g" },
                        { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
                        { action = "quitall", desc = " Quit", icon = " ", key = "q" },
                    },
                    footer = function()
                        local stats = require("lazy").stats()
                        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                        return {
                            "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
                        }
                    end,
                },
                disable_move = true,
                shortcut_type = "number",
                theme = "doom",
            },
        },
        {
            "diffview",
            cmd = { "DiffviewOpen" },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/diffview.nvim",
            lazy = true,
            name = "diffview",
        },
        {
            "direnv",
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/direnv.vim",
            lazy = false,
            name = "direnv",
        },
        {
            "flash",
            config = function(_, opts)
                require("flash").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/flash.nvim",
            keys = { "s", "S", "f", "F", "t", "T" },
            lazy = true,
            name = "flash",
        },
        {
            "gitmessenger",
            cmd = { "GitMessenger" },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/git-messenger.vim",
            init = function()
                for k, v in pairs({
                    ["git_messenger_floating_win_opts"] = { ["border"] = "rounded" },
                    ["git_messenger_no_default_mappings"] = true,
                }) do
                    vim.g[k] = v
                end
            end,
            lazy = true,
            name = "gitmessenger",
        },
        {
            "gitsigns",
            config = function(_, opts)
                require("gitsigns").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/gitsigns.nvim",
            event = { "BufReadPost", "BufNewFile" },
            lazy = true,
            name = "gitsigns",
            opts = { current_line_blame = false },
        },
        {
            "haskell-tools",
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/haskell-tools.nvim",
            lazy = false,
            name = "haskell-tools",
        },
        {
            "illuminate",
            config = function(_, opts)
                require("illuminate").configure(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/vim-illuminate",
            event = { "BufreadPost", "BufNewFile" },
            lazy = true,
            name = "illuminate",
            opts = {
                filetypesDenylist = {
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
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/intellitab.nvim",
            event = { "InsertEnter" },
            lazy = true,
            name = "intellitab",
        },
        {
            "jdtls",
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-jdtls",
            lazy = false,
            name = "jdtls",
        },
        {
            "nvim-lastplace",
            config = function(_, opts)
                require("nvim-lastplace").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-lastplace",
            lazy = false,
            name = "nvim-lastplace",
        },
        {
            "lazygit",
            cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
            dependencies = {
                {
                    "plenary",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/plenary.nvim",
                    lazy = true,
                    name = "plenary",
                },
            },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/lazygit.nvim",
            lazy = true,
            name = "lazygit",
        },
        {
            "lint",
            config = function(_, opts)
                local lint = require("lint")

                for k, v in pairs(opts) do
                    lint[k] = v
                end
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-lint",
            event = { "BufReadPost", "BufNewFile" },
            lazy = true,
            name = "lint",
            opts = {
                linters_by_ft = {
                    c = { "clangtidy" },
                    clojure = { "clj-kondo" },
                    cpp = { "clangtidy" },
                    h = { "clangtidy" },
                    hpp = { "clangtidy" },
                    java = { "checkstyle" },
                    javascript = { "eslint_d" },
                    lua = { "luacheck" },
                    markdown = { "vale" },
                    nix = { "statix" },
                    python = { "flake8" },
                    text = { "vale" },
                },
            },
        },
        {
            "lspconfig",
            cmd = { "LspInfo" },
            config = function(_, opts)
                -- Make LspInfo window border rounded
                require("lspconfig.ui.windows").default_options.border = "rounded"

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
                    {
                        ["extraOptions"] = {
                            ["capabilities"] = { ["offsetEncoding"] = { "utf-16" } },
                            ["cmd"] = {
                                "clangd",
                                "--background-index",
                                "--clang-tidy",
                                "--header-insertion=iwyu",
                                "--completion-style=detailed",
                                "--function-arg-placeholders",
                                "--fallback-style=llvm",
                            },
                            ["init_options"] = {
                                ["clangdFileStatus"] = true,
                                ["completeUnimported"] = true,
                                ["usePlaceholders"] = true,
                            },
                            ["root_dir"] = function(fname)
                                return require("lspconfig.util").root_pattern(
                                    "Makefile",
                                    "CMakeLists.txt",
                                    ".clang-format",
                                    ".clang-tidy"
                                )(fname) or require("lspconfig.util").root_pattern(
                                    "compile_commands.json"
                                )(fname) or require("lspconfig.util").find_git_ancestor(
                                    fname
                                )
                            end,
                        },
                        ["name"] = "clangd",
                    },
                    { ["name"] = "clojure_lsp" },
                    { ["name"] = "cmake" },
                    { ["name"] = "lua_ls" },
                    { ["name"] = "nil_ls" },
                    {
                        ["extraOptions"] = {
                            ["nixd"] = {
                                ["diagnostic"] = {
                                    ["suppress"] = { "sema-escaping-with", "var-bind-to-this", "escaping-this-with" },
                                },
                            },
                        },
                        ["name"] = "nixd",
                    },
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
            dependencies = {
                {
                    "lazydev",
                    config = function(_, opts)
                        require("lazydev").setup(opts)
                    end,
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/vimplugin-nvim-lazydev",
                    ft = { "lua" },
                    name = "lazydev",
                },
            },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-lspconfig",
            event = { "BufReadPost", "BufNewFile" },
            lazy = true,
            name = "lspconfig",
        },
        {
            "lualine",
            config = function(_, opts)
                local lualine = require("lualine")

                lualine.setup(opts)

                -- Disable tabline/winbar sections
                lualine.hide({
                    place = { "tabline", "winbar" },
                    unhide = false,
                })
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/lualine.nvim",
            event = { "BufReadPost", "BufNewFile" },
            lazy = true,
            name = "lualine",
            opts = {
                extensions = { "fzf", "chadtree", "neo-tree", "toggleterm", "trouble" },
                options = {
                    always_divide_middle = true,
                    component_separators = { left = "", right = "" },
                    globalstatus = true,
                    ignore_focus = { "neo-tree", "chadtree" },
                    section_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "filetype", "encoding", "fileformat" },
                    lualine_y = { "progress", "searchcount", "selectioncount" },
                    lualine_z = { "location" },
                },
            },
        },
        {
            "luasnip",
            config = function(_, opts)
                require("luasnip").config.set_config(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/luasnip",
            lazy = false,
            name = "luasnip",
        },
        {
            "narrow-region",
            cmd = { "NR" },
            config = function(_, opts)
                vim.keymap.del("x", "<space>Nr")
                vim.keymap.del("x", "<space>nr")
                vim.keymap.del("n", "<space>nr")
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/NrrwRgn",
            lazy = true,
            name = "narrow-region",
        },
        {
            "navbuddy",
            cmd = { "Navbuddy" },
            config = function(_, opts)
                local actions = require("nvim-navbuddy.actions") -- ?
                require("nvim-navbuddy").setup(opts)
            end,
            dependencies = {
                {
                    "navic",
                    config = function(_, opts)
                        navic = require("nvim-navic")
                        navic.setup(opts)

                        -- NOTE: Use incline, because the default winbar isn't floating and disappears
                        --       when leavin the split, which makes the buffer jump
                        -- Register navic with lualine's winbar
                        -- TODO: The setup function should only be ran once
                        -- require("lualine").setup({
                        --   winbar = {
                        --     lualine_c = {
                        --       {
                        --         function()
                        --           return navic.get_location()
                        --         end,
                        --         cond = function()
                        --           return navic.is_available()
                        --         end
                        --       }
                        --     }
                        --   }
                        -- })
                    end,
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-navic",
                    lazy = true,
                    name = "navic",
                    opts = { click = true, depth_limit = 5, highlight = true, lsp = { auto_attach = true } },
                },
            },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-navbuddy",
            lazy = true,
            name = "navbuddy",
            opts = { lsp = { auto_attach = true }, window = { border = "rounded" } },
        },
        {
            "neo-tree",
            cmd = { "Neotree" },
            config = function(_, opts)
                require("neo-tree").setup(opts)
            end,
            dependencies = {
                {
                    "plenary",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/plenary.nvim",
                    lazy = true,
                    name = "plenary",
                },
                {
                    "nvim-web-devicons",
                    config = function(_, opts)
                        require("nvim-web-devicons").setup(opts)
                    end,
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-web-devicons",
                    lazy = true,
                    name = "nvim-web-devicons",
                },
                {
                    "nui",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nui.nvim",
                    lazy = true,
                    name = "nui",
                },
            },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/neo-tree.nvim",
            lazy = true,
            name = "neo-tree",
            opts = {
                buffers = { follow_current_file = { enabled = true, leave_dirs_open = false } },
                default_component_configs = { container = { enable_character_fade = true } },
                enable_diagnostics = false,
                enable_git_status = true,
                filesystem = {
                    bind_to_cwd = true,
                    cwd_target = { sidebar = "global" },
                    filtered_items = { visible = false },
                    follow_current_file = { enabled = true, leave_dirs_open = false },
                },
                open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
                popup_border_style = "rounded",
                use_default_mappings = false,
                window = {
                    mappings = {
                        ["."] = "set_root",
                        ["/"] = "fuzzy_finder",
                        ["<CR>"] = "open",
                        ["<Esc>"] = "cancel",
                        [">"] = "navigate_up",
                        ["?"] = "show_help",
                        H = "toggle_hidden",
                        R = "refresh",
                        a = "add",
                        c = "close_node",
                        d = "delete",
                        i = "show_file_details",
                        p = "paste_from_clipboard",
                        q = "close_window",
                        r = "rename",
                        x = "cut_to_clipboard",
                        y = "copy_to_clipboard",
                    },
                    position = "left",
                },
            },
        },
        {
            "noice",
            config = function(_, opts)
                require("noice").setup(opts)
            end,
            dependencies = {
                {
                    "notify",
                    config = function(_, opts)
                        local notify = require("notify")

                        notify.setup(opts)
                        vim.notify = notify -- Vim uses notify by default
                    end,
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-notify",
                    lazy = true,
                    name = "notify",
                },
                {
                    "nui",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nui.nvim",
                    lazy = true,
                    name = "nui",
                },
            },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/noice.nvim",
            lazy = false,
            name = "noice",
            opts = {
                lsp = {
                    documentation = {
                        opts = {
                            border = "rounded",
                            format = { "{message}" },
                            lang = "markdown",
                            render = "plain",
                            replace = true,
                            win_options = { concealcursor = "n", conceallevel = 3 },
                        },
                        view = "hover",
                    },
                    override = {
                        ["cmp.entry.get_documentation"] = true,
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                    },
                },
                notify = { enabled = true },
                popupmenu = { backend = "nui", enabled = true },
                presets = {
                    bottom_search = false,
                    command_palette = true,
                    inc_rename = true,
                    long_message_to_split = true,
                    lsp_doc_border = true,
                },
                routes = { { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } } },
            },
        },
        {
            "rainbow-delimiters",
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/rainbow-delimiters.nvim",
            lazy = false,
            name = "rainbow-delimiters",
        },
        {
            "rustaceanvim",
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/rustaceanvim",
            init = function()
                vim.g.rustaceanvim = {
                    tools = {
                        enable_clippy = true,
                        float_win_config = {
                            border = "rounded",
                        },
                    },

                    server = {
                        default_settings = {
                            ["rust-analyzer"] = {
                                cargo = {
                                    allFeatures = true,
                                    -- features = "all",
                                    -- loadOutDirsFromCheck = true,
                                    -- runBuildScripts = true,
                                },

                                -- lint-nvim doesn't support clippy
                                checkOnSave = {
                                    allFeatures = true,
                                    allTargets = true,
                                    command = "clippy",
                                    extraArgs = {
                                        "--",
                                        "--no-deps",
                                        "-Dclippy::pedantic",
                                        "-Dclippy::nursery",
                                        "-Dclippy::unwrap_used",
                                        "-Dclippy::enum_glob_use",
                                        "-Dclippy::complexity",
                                        "-Dclippy::perf",
                                    },
                                },
                            },
                        },
                    },
                }
            end,
            lazy = false,
            name = "rustaceanvim",
        },
        {
            "sandwich",
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/vim-sandwich",
            init = function()
                -- Disable default keymaps
                vim.g.sandwich_no_default_key_mappings = 1
                vim.g.operator_sandwich_no_default_key_mappings = 1
                vim.g.textobj_sandwich_no_default_key_mappings = 1
            end,
            lazy = false,
            name = "sandwich",
        },
        {
            "sleuth",
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/vim-sleuth",
            lazy = false,
            name = "sleuth",
        },
        {
            "telescope",
            cmd = { "Telescope" },
            config = function(_, opts)
                local telescope = require("telescope")
                telescope.setup(opts)

                for i, extension in ipairs({ "undo", "ui-select", "fzf" }) do
                    telescope.load_extension(extension)
                end
            end,
            dependencies = {
                {
                    "plenary",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/plenary.nvim",
                    lazy = true,
                    name = "plenary",
                },
                {
                    "telescope-fzf-native",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/telescope-fzf-native.nvim",
                    lazy = true,
                    name = "telescope-fzf-native",
                },
                {
                    "telescope-undo",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/telescope-undo.nvim",
                    lazy = true,
                    name = "telescope-undo",
                },
                {
                    "telescope-ui-select",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/telescope-ui-select.nvim",
                    lazy = true,
                    name = "telescope-ui-select",
                },
            },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/telescope.nvim",
            lazy = true,
            name = "telescope",
            opts = {
                defaults = {
                    mappings = { i = {
                        ["<Esc>"] = function(...)
                            return require("telescope.actions").close(...)
                        end,
                    } },
                },
            },
        },
        {
            "todo-comments",
            config = function(_, opts)
                require("todo-comments").setup(opts)
            end,
            dependencies = {
                {
                    "plenary",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/plenary.nvim",
                    lazy = true,
                    name = "plenary",
                },
            },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/todo-comments.nvim",
            event = { "BufReadPost", "BufNewFile" },
            lazy = true,
            name = "todo-comments",
            opts = {
                keywords = {
                    FIX = { alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, color = "error", icon = " " },
                    HACK = { color = "warning", icon = " " },
                    NOTE = { alt = { "INFO" }, color = "hint", icon = " " },
                    PERF = { alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" }, icon = " " },
                    TEST = { alt = { "TESTING", "PASSED", "FAILED" }, color = "test", icon = "⏲ " },
                    TODO = { color = "info", icon = " " },
                    WARN = { alt = { "WARNING", "XXX" }, color = "warning", icon = " " },
                },
                signs = true,
            },
        },
        {
            "toggleterm",
            cmd = { "ToggleTerm" },
            config = function(_, opts)
                require("toggleterm").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/toggleterm.nvim",
            keys = { "<C-/>" },
            lazy = true,
            name = "toggleterm",
            opts = {
                auto_scroll = true,
                autochdir = true,
                close_on_exit = true,
                direction = "horizontal",
                float_opts = { border = "curved", height = 35, width = 80, winblend = 0 },
                hide_numbers = true,
                insert_mappings = true,
                open_mapping = [[<C-/>]],
                persist_mode = true,
                shade_terminals = false,
                shading_factor = 30,
                shell = "fish",
                start_in_insert = true,
                terminal_mappings = true,
            },
        },
        {
            "treesitter",
            cmd = { "TSModuleInfo" },
            config = function(_, opts)
                require("nvim-treesitter.configs").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-treesitter",
            event = { "BufReadPost", "BufNewFile" },
            init = function()
                -- Fix treesitter grammars/parsers on nix
                vim.opt.runtimepath:append(
                    "/nix/store/mijdgvgykavkdkyfvhcrd5vh808ijmk0-vimplugin-nvim-treesitter-2024-06-19"
                )
                vim.opt.runtimepath:append("/nix/store/0h2cb1dzf10jm1m643k43xkk6lpl4vk6-treesitter-parsers")
            end,
            lazy = true,
            name = "treesitter",
            opts = {
                auto_install = false,
                highlight = { additional_vim_regex_highlighting = false, enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_decremental = "grm",
                        node_incremental = "grn",
                        scope_incremental = "grc",
                    },
                },
                indent = { enable = true },
                parser_install_dir = "/nix/store/0h2cb1dzf10jm1m643k43xkk6lpl4vk6-treesitter-parsers",
            },
        },
        {
            "trim",
            config = function(_, opts)
                require("trim").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/trim.nvim",
            lazy = false,
            name = "trim",
        },
        {
            "trouble",
            cmd = { "Trouble", "TroubleToggle" },
            config = function(_, opts)
                require("trouble").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/trouble.nvim",
            lazy = true,
            name = "trouble",
        },
        {
            "ufo",
            config = function(_, opts)
                require("ufo").setup(opts)
            end,
            dependencies = {
                {
                    "promise",
                    dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/promise-async",
                    lazy = true,
                    name = "promise",
                },
            },
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/nvim-ufo",
            lazy = false,
            name = "ufo",
        },
        {
            "vimtex",
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/vimtex",
            init = function()
                vim.g.vimtex_view_method = "zathura"
            end,
            name = "vimtex",
        },
        {
            "which-key",
            config = function(_, opts)
                require("which-key").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/which-key.nvim",
            lazy = false,
            name = "which-key",
            priority = 500,
        },
        {
            "winshift",
            cmd = { "WinShift" },
            config = function(_, opts)
                require("winshift").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/winshift.nvim",
            lazy = true,
            name = "winshift",
            opts = {
                highlight_moving_win = true,
                keymaps = { disable_defaults = true, win_move_mode = { h = "left", j = "down", k = "up", l = "right" } },
            },
        },
        {
            "yanky",
            cmd = { "YankyClearHistory", "YankyRingHistory" },
            config = function(_, opts)
                require("yanky").setup(opts)
            end,
            dir = "/nix/store/qxjygssw1r6xbpsrk1fyk9f0qfp5nnsh-lazy-plugins/yanky.nvim",
            lazy = true,
            name = "yanky",
        },
    },
})

-- Set up keybinds {{{
do
    local __nixvim_binds = {
        {
            action = "v:count == 0 ? 'gj' : 'j'",
            key = "j",
            mode = "n",
            options = { desc = "Move cursor down", expr = true },
        },
        {
            action = "v:count == 0 ? 'gj' : 'j'",
            key = "<Down>",
            mode = "n",
            options = { desc = "Move cursor down", expr = true },
        },
        {
            action = "v:count == 0 ? 'gk' : 'k'",
            key = "k",
            mode = "n",
            options = { desc = "Move cursor up", expr = true },
        },
        {
            action = "v:count == 0 ? 'gk' : 'k'",
            key = "<Up>",
            mode = "n",
            options = { desc = "Move cursor up", expr = true },
        },
        {
            action = "<cmd>vertical resize -2<cr>",
            key = "<C-h>",
            mode = "n",
            options = { desc = "Decrease window width" },
        },
        {
            action = "<cmd>vertical resize +2<cr>",
            key = "<C-l>",
            mode = "n",
            options = { desc = "Increase window width" },
        },
        { action = "<cmd>resize -2<cr>", key = "<C-j>", mode = "n", options = { desc = "Decrease window height" } },
        { action = "<cmd>resize +2<cr>", key = "<C-k>", mode = "n", options = { desc = "Increase window height" } },
        { action = "<cmd>m .+1<cr>==", key = "<M-j>", mode = "n", options = { desc = "Move line down" } },
        { action = "<Esc><cmd>m .+1<cr>==gi", key = "<M-j>", mode = "i", options = { desc = "Move line down" } },
        { action = ":m '>+1<cr>gv=gv", key = "<M-j>", mode = "v", options = { desc = "Move line down" } },
        { action = "<cmd>m .-2<cr>==", key = "<M-k>", mode = "n", options = { desc = "Move line up" } },
        { action = "<Esc><cmd>m .-2<cr>==gi", key = "<M-k>", mode = "i", options = { desc = "Move line up" } },
        { action = ":m '<-2<cr>gv=gv", key = "<M-k>", mode = "v", options = { desc = "Move line up" } },
        { action = "<cmd>w<cr>", key = "<C-s>", mode = { "n", "i", "v" }, options = { desc = "Save current buffer" } },
        { action = "<cmd>wa<cr>", key = "<C-S-s>", mode = { "n", "i", "v" }, options = { desc = "Save all buffers" } },
        { action = "<gv", key = "<", mode = "v", options = { desc = "Outdent" } },
        { action = "v<<Esc>", key = "<", mode = "n", options = { desc = "Outdent" } },
        { action = ">gv", key = ">", mode = "v", options = { desc = "Indent" } },
        { action = "v><Esc>", key = ">", mode = "n", options = { desc = "Indent" } },
        {
            action = "<cmd>lua require('intellitab').indent()<cr>",
            key = "<Tab>",
            mode = "i",
            options = { desc = "Indent (IntelliTab)" },
        },
        { action = "<C-d>zz", key = "<C-d>", mode = "n", options = { desc = "Jump down (centered)" } },
        { action = "<C-u>zz", key = "<C-u>", mode = "n", options = { desc = "Jump up (centered)" } },
        { action = "nzzzv", key = "n", mode = "n", options = { desc = "Next match (centered)" } },
        { action = "Nzzzv", key = "N", mode = "n", options = { desc = "Previous match (centered)" } },
        { action = "<C-w>", key = "<C-BS>", mode = "i", options = { desc = "Delete previous word" } },
        { action = "<C-w>", key = "<M-BS>", mode = "i", options = { desc = "Delete previous word" } },
        { action = '<Esc>"+pi', key = "<C-S-v>", mode = "i", options = { desc = "Paste from clipboard" } },
        { action = '<Esc>"+pi', key = "<C-v>", mode = "i", options = { desc = "Paste from clipboard" } },
        { action = '"+y', key = "<C-S-c>", mode = "v", options = { desc = "Copy to clipboard" } },
        { action = "<cmd>lua require('flash').jump()<cr>", key = "s", mode = "n", options = { desc = "Flash jump" } },
        {
            action = "<cmd>lua require('flash').treesitter()<cr>",
            key = "S",
            mode = "n",
            options = { desc = "Flash treesitter" },
        },
        { action = "<cmd>nohlsearch<cr>", key = "<C-S-h>", mode = "n", options = { desc = "Clear search highlights" } },
        { action = "<cmd>lua vim.lsp.buf.hover()<cr>", key = "K", mode = "n", options = { desc = "Show LSP hover" } },
        {
            action = "<cmd>Telescope current_buffer_fuzzy_find<cr>",
            key = "/",
            mode = "n",
            options = { desc = "Find in current buffer" },
        },
        { action = "<Esc>", key = ";", mode = "v", options = { desc = "Exit visual mode" } },
        { action = "<cmd>Lazy<cr>", key = "<leader>L", mode = "n", options = { desc = "Show Lazy" } },
        { action = "<cmd>edit!<cr>", key = "<leader>R", mode = "n", options = { desc = "Reload current buffer" } },
        {
            action = "<cmd>Telescope buffers<cr>",
            key = "<leader><Space>",
            mode = "n",
            options = { desc = "Show open buffers" },
        },
        { action = "<cmd>Telescope find_files<cr>", key = "<leader>f", mode = "n", options = { desc = "Find file" } },
        { action = "<cmd>Telescope projects<cr>", key = "<leader>p", mode = "n", options = { desc = "Open project" } },
        {
            action = "<cmd>Telescope vim_options<cr>",
            key = "<leader>o",
            mode = "n",
            options = { desc = "Show Vim options" },
        },
        { action = "<cmd>Telescope undo<cr>", key = "<leader>u", mode = "n", options = { desc = "Show undo history" } },
        {
            action = "<cmd>Telescope live_grep<cr>",
            key = "<leader>/",
            mode = "n",
            options = { desc = "Find in working directory" },
        },
        { action = ":NR!<cr>", key = "<leader>n", mode = "v", options = { desc = "Narrow region" } },
        {
            action = "<cmd>Telescope notify<cr>",
            key = "<leader>N",
            mode = "n",
            options = { desc = "Show notify history" },
        },
        {
            action = "<cmd>Telescope resume<cr>",
            key = "<leader>r",
            mode = "n",
            options = { desc = "Show last telescope picker" },
        },
        { action = "<cmd>Telescope keymaps<cr>", key = "<leader>?", mode = "n", options = { desc = "Show keymaps" } },
        {
            action = "<cmd>Telescope commands<cr>",
            key = "<leader>:",
            mode = "n",
            options = { desc = "Execute command" },
        },
        { action = "<cmd>Telescope marks<cr>", key = "<leader>M", mode = "n", options = { desc = "Show marks" } },
        { action = "<cmd>Telescope jumplist<cr>", key = "<leader>J", mode = "n", options = { desc = "Show jumplist" } },
        { action = "<cmd>Telescope man_pages<cr>", key = "<leader>m", mode = "n", options = { desc = "Show manpages" } },
        {
            action = "<cmd>Telescope help_tags<cr>",
            key = "<leader>h",
            mode = "n",
            options = { desc = "Show help tags" },
        },
        { action = "<cmd>TodoTelescope<cr>", key = "<leader>T", mode = "n", options = { desc = "Show TODOs" } },
        { action = "+quit", key = "<leader>q", mode = "n" },
        { action = "<cmd>quitall<cr>", key = "<leader>qq", mode = "n", options = { desc = "Quit" } },
        { action = "<cmd>quitall!<cr>", key = "<leader>q!", mode = "n", options = { desc = "Quit forcefully" } },
        { action = "+session", key = "<leader>s", mode = "n" },
        {
            action = "<cmd>Telescope persisted<cr>",
            key = "<leader>sl",
            mode = "n",
            options = { desc = "Restore session" },
        },
        { action = "<cmd>SessionSave<cr>", key = "<leader>ss", mode = "n", options = { desc = "Save session" } },
        {
            action = "<cmd>SessionDelete<cr>",
            key = "<leader>sd",
            mode = "n",
            options = { desc = "Delete current session" },
        },
        { action = "+buffers", key = "<leader>b", mode = "n" },
        {
            action = "<cmd>Telescope buffers<cr>",
            key = "<leader>bb",
            mode = "n",
            options = { desc = "Show open buffers" },
        },
        { action = "<cmd>bnext<cr>", key = "<leader>bn", mode = "n", options = { desc = "Goto next buffer" } },
        { action = "<cmd>bprevious<cr>", key = "<leader>bp", mode = "n", options = { desc = "Goto previous buffer" } },
        { action = "<cmd>Bdelete<cr>", key = "<leader>bd", mode = "n", options = { desc = "Close current buffer" } },
        { action = "+windows", key = "<leader>w", mode = "n" },
        { action = "<C-w>c", key = "<leader>wd", mode = "n", options = { desc = "Close current window" } },
        { action = "<C-w>s", key = "<leader>ws", mode = "n", options = { desc = "Split window horizontally" } },
        { action = "<C-w>v", key = "<leader>wv", mode = "n", options = { desc = "Split window vertically" } },
        { action = "<C-w>=", key = "<leader>w=", mode = "n", options = { desc = "Balance windows" } },
        { action = "<C-w>h", key = "<leader>wh", mode = "n", options = { desc = "Goto left window" } },
        { action = "<C-w>l", key = "<leader>wl", mode = "n", options = { desc = "Goto right window" } },
        { action = "<C-w>j", key = "<leader>wj", mode = "n", options = { desc = "Goto bottom window" } },
        { action = "<C-w>k", key = "<leader>wk", mode = "n", options = { desc = "Goto top window" } },
        { action = "<C-w>p", key = "<leader>ww", mode = "n", options = { desc = "Goto other window" } },
        { action = "<cmd>WinShift<cr>", key = "<leader>wm", mode = "n", options = { desc = "Move window" } },
        { action = "+toggle", key = "<leader>t", mode = "n" },
        {
            action = "<cmd>Neotree action=show toggle=true<cr><C-w>=",
            key = "<leader>tt",
            mode = "n",
            options = { desc = "Toggle NeoTree" },
        },
        { action = "<cmd>Navbuddy<cr>", key = "<leader>tn", mode = "n", options = { desc = "Toggle NavBuddy" } },
        {
            action = "<cmd>TroubleToggle workspace_diagnostics focus=false<cr>",
            key = "<leader>td",
            mode = "n",
            options = { desc = "Toggle Trouble diagnostics" },
        },
        {
            action = "<cmd>TroubleToggle todo focus=false<cr>",
            key = "<leader>tT",
            mode = "n",
            options = { desc = "Toggle Trouble TODOs" },
        },
        {
            action = "<cmd>ToggleAutoformat<cr>",
            key = "<leader>tf",
            mode = "n",
            options = { desc = "Toggle autoformat-on-save" },
        },
        {
            action = "<cmd>ToggleAutoLint<cr>",
            key = "<leader>tl",
            mode = "n",
            options = { desc = "Toggle autolint-on-save" },
        },
        {
            action = "<cmd>ToggleInlineDiagnostics<cr>",
            key = "<leader>tD",
            mode = "n",
            options = { desc = "Toggle inline diagnostics" },
        },
        { action = "<cmd>:set wrap!<cr>", key = "<leader>tw", mode = "n", options = { desc = "Toggle word-wrap" } },
        { action = "+git", key = "<leader>g", mode = "n" },
        { action = "<cmd>LazyGit<cr>", key = "<leader>gg", mode = "n", options = { desc = "Show LazyGit" } },
        { action = "<cmd>GitMessenger<cr>", key = "<leader>gm", mode = "n", options = { desc = "Show GitMessenger" } },
        {
            action = "<cmd>Telescope git_status<cr>",
            key = "<leader>gs",
            mode = "n",
            options = { desc = "Show Git status" },
        },
        {
            action = "<cmd>Telescope git_commits<cr>",
            key = "<leader>gc",
            mode = "n",
            options = { desc = "Show Git log" },
        },
        {
            action = "<cmd>Telescope git_branches<cr>",
            key = "<leader>gb",
            mode = "n",
            options = { desc = "Show Git branches" },
        },
        {
            action = "<cmd>Telescope git_bcommits<cr>",
            key = "<leader>gf",
            mode = "n",
            options = { desc = "Show Git log for current file" },
        },
        {
            action = "<cmd>DiffviewOpen<cr>",
            key = "<leader>gd",
            mode = "n",
            options = { desc = "Show Git diff for current worktree" },
        },
        { action = "+lsp", key = "<leader>l", mode = "n" },
        {
            action = "<cmd>Telescope lsp_references<cr>",
            key = "<leader>lr",
            mode = "n",
            options = { desc = "Goto references" },
        },
        {
            action = "<cmd>Telescope lsp_definitions<cr>",
            key = "<leader>ld",
            mode = "n",
            options = { desc = "Goto definition" },
        },
        {
            action = "<cmd>Telescope lsp_implementations<cr>",
            key = "<leader>li",
            mode = "n",
            options = { desc = "Goto implementation" },
        },
        {
            action = "<cmd>Telescope lsp_type_definitions<cr>",
            key = "<leader>lt",
            mode = "n",
            options = { desc = "Goto type definition" },
        },
        {
            action = "<cmd>Telescope lsp_incoming_calls<cr>",
            key = "<leader>lI",
            mode = "n",
            options = { desc = "Show incoming calls" },
        },
        {
            action = "<cmd>Telescope lsp_outgoing_calls<cr>",
            key = "<leader>lO",
            mode = "n",
            options = { desc = "Show outgoing calls" },
        },
        { action = "+code", key = "<leader>c", mode = "n" },
        {
            action = "<cmd>lua require('conform').format()<cr>",
            key = "<leader>cf",
            mode = "n",
            options = { desc = "Format current buffer" },
        },
        {
            action = "<cmd>lua vim.diagnostic.open_float()<cr>",
            key = "<leader>cd",
            mode = "n",
            options = { desc = "Show LSP line diagnostics" },
        },
        {
            action = "<cmd>Telescope diagnostics<cr>",
            key = "<leader>cD",
            mode = "n",
            options = { desc = "Show diagnostics" },
        },
        {
            action = "<cmd>lua vim.lsp.buf.rename()<cr>",
            key = "<leader>cr",
            mode = "n",
            options = { desc = "Rename LSP symbol" },
        },
        {
            action = "<cmd>lua vim.lsp.buf.code_action()<cr>",
            key = "<leader>ca",
            mode = "n",
            options = { desc = "Show LSP code actions" },
        },
        {
            action = "<cmd>ClangdSwitchSourceHeader<cr>",
            key = "<leader>ch",
            mode = "n",
            options = { desc = "Switch C/C++ source/header" },
        },
    }
    for i, map in ipairs(__nixvim_binds) do
        vim.keymap.set(map.mode, map.key, map.action, map.options)
    end
end
-- }}}

vim.filetype.add({ extension = { v = "vlang" } })

-- Make Lazy window border rounded
require("lazy.core.config").options.ui.border = "rounded"

-- Toggle inline diagnostics and show border
vim.g.enable_inline_diagnostics = false
vim.diagnostic.config({
    virtual_text = vim.g.enable_inline_diagnostics,
    float = { border = "rounded" },
})
vim.api.nvim_create_user_command("ToggleInlineDiagnostics", function()
    vim.g.enable_inline_diagnostics = not vim.g.enable_inline_diagnostics
    vim.diagnostic.config({ virtual_text = vim.g.enable_inline_diagnostics, float = { border = "rounded" } })
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

-- Toggle linting
vim.g.disable_autolint = false
vim.api.nvim_create_user_command("ToggleAutoLint", function()
    vim.g.disable_autolint = not vim.g.disable_autolint
    if vim.g.disable_autolint then
        -- vim.diagnostic.reset(vim.api.nvim_get_current_buf())
        vim.diagnostic.reset() -- Reset for all buffers
    end
    require("notify")((vim.g.disable_autolint and "Disabled" or "Enabled") .. " autolint-on-save")
end, {
    desc = "Toggle autolint-on-save",
})

-- Set up autocommands {{
do
    local __nixvim_autocommands = {
        {
            callback = function()
                if not vim.g.disable_autolint then
                    require("lint").try_lint()
                end
            end,
            event = { "BufWritePost" },
        },
        {
            callback = function()
                vim.highlight.on_yank()
            end,
            event = { "TextYankPost" },
        },
        {
            callback = function()
                local current_tab = vim.fn.tabpagenr()
                vim.cmd("tabdo wincmd =")
                vim.cmd("tabnext " .. current_tab)
            end,
            event = { "VimResized" },
        },
        {
            callback = function()
                vim.opt_local.conceallevel = 0
            end,
            event = { "FileType" },
            pattern = { "json", "jsonc", "json5" },
        },
        {
            callback = function()
                local workspace = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1])

                local opts = {
                    root_dir = workspace,
                    cmd = {
                        "jdtls",
                        "-data",
                        "/home/christoph/.local/share/eclipse/" .. vim.fn.fnamemodify(workspace, ":p:h:t"),
                    },
                }

                require("jdtls").start_or_attach(opts)
            end,
            event = { "FileType" },
            pattern = { "Java", "java" },
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
