-- Functions for Bootstrapping Paq
local function clone_paq()
    local path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
    local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0
    if not is_installed then
        vim.fn.system { "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", path }
        return true
    end
end
local function bootstrap_paq(packages)
    local first_install = clone_paq()
    vim.cmd.packadd("paq-nvim")
    local paq = require("paq")
    if first_install then
        vim.notify("Installing plugins... If prompted, hit Enter to continue.")
    end

    -- Read and install packages
    paq(packages)
    paq.install()
end


-- -----------------------
-- Options
-- -----------------------

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
    vim.opt.clipboard = "unnamedplus"
end)

opt.splitright = true
opt.splitbelow = true

opt.scrolloff = 10

-- -----------------------
-- Keymaps
-- -----------------------

vim.g.mapleader = " "

-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>" , '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>"   , '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>" , '<cmd>echo "Use j to move!!"<CR>')

-- clear highlights on search when <Esc> is pressed
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- exit terminal mode with <Esc><Esc>
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left window"  })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move focus to the upper window" })

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- -----------------------
-- Plugins
-- -----------------------
bootstrap_paq {
    "savq/paq-nvim", -- Let Paq manage itself
    { "rose-pine/neovim", as = "rose-pine" },

    "folke/which-key.nvim",

    {'echasnovski/mini.nvim', branch = "stable"},
    {'echasnovski/mini.align', branch = "stable"},
    {'echasnovski/mini.pairs', branch = "stable"},
    {'echasnovski/mini.ai', branch = "stable"},
    {'echasnovski/mini.surround', branch = "stable"},
    {'echasnovski/mini.statusline', branch = "stable"},
    {'echasnovski/mini.completion', branch = "stable"},

    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',

    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",

    "akinsho/toggleterm.nvim",
}
-- setting up plugins
vim.cmd("colorscheme rose-pine")

-- which-key config
local wk = require('which-key')
wk.setup()
wk.add({
    {"<leader>f", group = "[F]ind"},
    {"<leader>r", group = "[R]ename"},
    {"<leader>c", group = "[C]ode Actions"},
})

-- mini config
require('mini.align').setup()
require('mini.pairs').setup()
require('mini.ai').setup()
require('mini.surround').setup()
local statusline = require('mini.statusline')
statusline.setup({ use_icons = vim.g.have_nerd_font })
statusline.section_location = function()
    return "%2l:%-2v"
end
require('mini.completion').setup()

-- telescope config
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files"})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live Grep"})
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Find buffers"})
vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = "Find recent files"})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Find help"})
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "Find keymaps"})

-- lsp config
local lspconfig = require("lspconfig")
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls" }
})
local on_attach = function(_, _)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename        , { desc = "Rename symbol" })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action   , { desc = "Code Actions" })
    vim.keymap.set('n', 'gd'        , vim.lsp.buf.definition    , { desc = "Goto Definition" })
    vim.keymap.set('n', 'gi'        , vim.lsp.buf.implementation, { desc = "Goto Implementation" })
    vim.keymap.set('n', 'gr'        , builtin.lsp_references    , { desc = "Goto References" })
    vim.keymap.set('n', 'K'         , vim.lsp.buf.hover         , { desc = "Show documentation" })
end

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

-- toggleterm config
require("toggleterm").setup()
vim.keymap.set("n", "<C-x>", function()
    vim.cmd("ToggleTerm")
end)
vim.keymap.set("t", "<C-x>", function()
    vim.cmd("ToggleTerm")
end)


-- neovide specific config >:3
if vim.g.neovide then
    vim.o.guifont = "JetBrainsMono Nerd Font Mono:h12"
end
