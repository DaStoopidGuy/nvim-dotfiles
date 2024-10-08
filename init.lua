-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- -----------------------
-- Options
-- -----------------------

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.o

opt.relativenumber = true
opt.number = true

opt.mouse = ""

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

opt.wrap = true

opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

opt.termguicolors = true
opt.signcolumn = "yes" -- Keep signcolumn on by default

opt.showmode = false

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
    opt.clipboard = "unnamedplus"
end)

opt.splitright = true
opt.splitbelow = true

opt.scrolloff = 10

-- -----------------------
-- Keymaps
-- -----------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable arrow keys in insert mode
vim.keymap.set("i", "<left>" , '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("i", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("i", "<up>"   , '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("i", "<down>" , '<cmd>echo "Use j to move!!"<CR>')

-- clear highlights on search when <Esc> is pressed
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- exit terminal mode with <Esc><Esc>-pine
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- split navigation
vim.keymap.set("n", "<leader>q", "<cmd>wincmd q<CR>", { desc = "Quit window" })

vim.keymap.set('n', '<leader>s', '<cmd>split<CR>'   , { desc = "Split window Horizontally" })
vim.keymap.set('n', '<leader>v', '<cmd>vsplit<CR>'  , { desc = "Split window Vertically" })

vim.keymap.set("n", "<leader>h", "<Cmd>wincmd h<CR>", { desc = "Move focus to the left window"  })
vim.keymap.set("n", "<leader>l", "<Cmd>wincmd l<CR>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<leader>j", "<Cmd>wincmd j<CR>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<leader>k", "<Cmd>wincmd k<CR>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>H", "<Cmd>wincmd H<CR>", { desc = "Move window to the left"  })
vim.keymap.set("n", "<leader>L", "<Cmd>wincmd L<CR>", { desc = "Move window to the right" })
vim.keymap.set("n", "<leader>J", "<Cmd>wincmd J<CR>", { desc = "Move window to the lower" })
vim.keymap.set("n", "<leader>K", "<Cmd>wincmd K<CR>", { desc = "Move window to the upper" })

-- -----------------------
-- Plugins
-- -----------------------
require("lazy").setup({
    { "rose-pine/neovim", name="rose-pine" },
    {   -- colorscheme config
        "kepano/flexoki-neovim", name = "flexoki",
        priority = 1000,
        lazy = false,
        config = function()
            vim.cmd.colorscheme "flexoki-dark"
        end
    },
    {
        "folke/which-key.nvim",
        event = 'VimEnter',
        config = function()
            local wk = require('which-key')
            wk.setup()
            wk.add({
                {"<leader>r", group = "[R]ename"},
                {"<leader>c", group = "[C]ode Actions"},
                {"<leader>d", group = "[D]ocument"},
                {"<leader>w", group = "[W]orkspace"},
                {"<leader>w", proxy = "<c-w>", group = "[W]indow"},
            })
        end
    },
    {   -- mini plugins :3
        "echasnovski/mini.nvim",
        dependencies = {
            { 'echasnovski/mini.align'   , branch = "stable", opts = {} },
            { 'echasnovski/mini.pairs'   , branch = "stable", opts = {} },
            { 'echasnovski/mini.ai'      , branch = "stable", opts = {} },
            { 'echasnovski/mini.surround', branch = "stable", opts = {} },
            {
                'echasnovski/mini.statusline', branch = "stable",
                config = function()
                    local statusline = require('mini.statusline')
                    statusline.setup({ use_icons = vim.g.have_nerd_font })
                    statusline.section_location = function()
                        return "%2l:%-2v"
                    end
                end
            },
            -- for minimal autocompletion :3
            { 'echasnovski/mini.completion', branch = "stable", opts = {} },
            { 'echasnovski/mini-git', name = "mini.git", branch = "stable", opts = {} },
        },
    },
    {   -- telescope config
        'nvim-telescope/telescope.nvim',
        event = "VimEnter",
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
        },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = "Find files"})
            vim.keymap.set('n', '<leader>g', builtin.live_grep , { desc = "Live Grep"})
            vim.keymap.set('n', '<leader>b', builtin.buffers   , { desc = "Buffers"})
            vim.keymap.set('n', '<leader>.', builtin.oldfiles  , { desc = "Recent files"})
            vim.keymap.set('n', '<leader>p', builtin.builtin   , { desc = "Select Telescope" })
        end
    },
    {   -- lsp config
        "neovim/nvim-lspconfig",
        dependencies = {
            { "williamboman/mason.nvim", config = true },
            { "williamboman/mason-lspconfig.nvim", opts = { ensure_installed = { "lua_ls" } }},
        },
        config = function()
            local builtin = require("telescope.builtin")
            local on_attach = function(_, _)
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename               , { desc = "Rename symbol" })
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action          , { desc = "Code Actions" })
                vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols         , { desc = "Find Document Symbols" })
                vim.keymap.set('n', '<leader>ws', builtin.lsp_dynamic_workspace_symbols, { desc = "Find Workspace Symbols" })
                vim.keymap.set('n', 'gd'        , vim.lsp.buf.definition           , { desc = "Goto Definition" })
                vim.keymap.set('n', 'gD'        , vim.lsp.buf.declaration          , { desc = "Goto Declaration" })
                vim.keymap.set('n', 'gi'        , vim.lsp.buf.implementation       , { desc = "Goto Implementation" })
                vim.keymap.set('n', 'gr'        , builtin.lsp_references           , { desc = "Goto References" })
                vim.keymap.set('n', 'gt'        , builtin.lsp_type_definitions     , { desc = "Goto Type Definition" })
                vim.keymap.set('n', 'K'         , vim.lsp.buf.hover                , { desc = "Show documentation" })
            end

            local lspconfig = require("lspconfig")
            local handlers = {
                function (server_name) -- default handler
                    lspconfig[server_name].setup { on_attach = on_attach }
                end,

                -- targeted overrides for specific servers
                ["lua_ls"] = function()
                    lspconfig.lua_ls.setup({
                        on_attach = on_attach,
                        settings = { Lua = { diagnostics = { globals = {"vim"}, } } }
                    })
                end
            }
            require("mason-lspconfig").setup_handlers(handlers)
        end
    },
    {   -- file browser
        'stevearc/oil.nvim',
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup()
            vim.keymap.set('n', '-', "<CMD>Oil<CR>", { desc = "Open parent directory" })
        end
    },
    { 'folke/todo-comments.nvim', config = true },
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup()
            vim.keymap.set("n", "<C-x>", function()
                vim.cmd("ToggleTerm")
            end)
            vim.keymap.set("t", "<C-x>", function()
                vim.cmd("ToggleTerm")
            end)
        end
    },
})

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('stinky-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- neovide specific config >:3
if vim.g.neovide then
    vim.o.guifont = "JetBrainsMono Nerd Font Mono:h12"
end

