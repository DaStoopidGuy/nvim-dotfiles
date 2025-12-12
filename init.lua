-- -----------------------
-- Bootstrap Paq
-- -----------------------
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
    paq(packages)
    paq.install()
end

-- -----------------------
-- Options
-- -----------------------
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
opt.signcolumn = "yes"
opt.showmode = false
vim.schedule(function()
    opt.clipboard = "unnamedplus"
end)
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 10

-- -----------------------
-- Keymaps
-- -----------------------
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Split navigation
vim.keymap.set('n', '<leader>q', '<cmd>wincmd q<CR>', { desc = "Quit window" })
vim.keymap.set('n', '<leader>s', '<cmd>split<CR>', { desc = "Split window Horizontally" })
vim.keymap.set('n', '<leader>v', '<cmd>vsplit<CR>', { desc = "Split window Vertically" })

vim.keymap.set("n", "<leader>h", "<Cmd>wincmd h<CR>")
vim.keymap.set("n", "<leader>l", "<Cmd>wincmd l<CR>")
vim.keymap.set("n", "<leader>j", "<Cmd>wincmd j<CR>")
vim.keymap.set("n", "<leader>k", "<Cmd>wincmd k<CR>")

-- Move windows
vim.keymap.set("n", "<leader>H", "<Cmd>wincmd H<CR>")
vim.keymap.set("n", "<leader>L", "<Cmd>wincmd L<CR>")
vim.keymap.set("n", "<leader>J", "<Cmd>wincmd J<CR>")
vim.keymap.set("n", "<leader>K", "<Cmd>wincmd K<CR>")

-- -----------------------
-- Plugins
-- -----------------------
bootstrap_paq {
    "savq/paq-nvim",
    { "kepano/flexoki-neovim", as = "flexoki" },
    { "echasnovski/mini.nvim", branch = "stable" },
    "stevearc/oil.nvim",
    "akinsho/toggleterm.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "nvim-telescope/telescope.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/nvim-cmp",
    { "L3MON4D3/LuaSnip", build = (function()
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
        return 'make install_jsregexp'
    end)},
    "saadparwaiz1/cmp_luasnip",
}

-- -----------------------
-- Mini Setup
-- -----------------------
require("mini.icons").setup()
require("mini.align").setup()
require("mini.pairs").setup()
require("mini.ai").setup()
require("mini.surround").setup()
require("mini.git").setup()
local statusline = require('mini.statusline')
statusline.setup({ use_icons = vim.g.have_nerd_font })
statusline.section_location = function() return "%2l:%-2v" end

-- -----------------------
-- Telescope / Oil / Terminal
-- -----------------------
require("oil").setup()
vim.keymap.set('n', '-', "<CMD>Oil<CR>")

require("toggleterm").setup()
vim.keymap.set({"n","t"}, "<C-_>", "<CMD>ToggleTerm<CR>")

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files)
vim.keymap.set('n', '<leader>g', builtin.live_grep)
vim.keymap.set('n', '<leader>b', builtin.buffers)
vim.keymap.set('n', '<leader>.', builtin.oldfiles)
vim.keymap.set('n', '<leader>p', builtin.builtin)
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find)

-- -----------------------
-- nvim-cmp
-- -----------------------
local cmp = require("cmp")
local luasnip = require("luasnip")
luasnip.config.setup {}

cmp.setup({
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-y>'] = cmp.mapping.confirm { select = true },
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<C-l>'] = cmp.mapping(function() if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function() if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end end, { 'i', 's' }),
    },
    sources = cmp.config.sources { { name = "nvim_lsp" }, { name = "luasnip" }, { name = "path" } }
})

-- -----------------------
-- LSP Setup
-- -----------------------
local on_attach = function(_, _)
    local lsp_builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
    vim.keymap.set('n', '<leader>ds', lsp_builtin.lsp_document_symbols)
    vim.keymap.set('n', '<leader>ws', lsp_builtin.lsp_dynamic_workspace_symbols)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)
    vim.keymap.set('n', 'gr', lsp_builtin.lsp_references)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover)
end

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local handlers = {
    function(server_name)
        lspconfig[server_name].setup {
            on_attach = on_attach,
            capabilities = capabilities,
        }
    end,
    ["lua_ls"] = function()
        lspconfig.lua_ls.setup({
            on_attach = on_attach,
            settings = { Lua = { diagnostics = { globals = {"vim"} } } },
            capabilities = capabilities,
        })
    end
}

require("mason").setup()
require("mason-lspconfig").setup({
    automatic_installation = true,
    handlers = handlers,
})

-- -----------------------
-- Misc
-- -----------------------

-- highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function() vim.highlight.on_yank() end,
})

if vim.g.neovide then
    vim.o.guifont = "JetBrainsMono Nerd Font Mono:h12"
end

-- Colorscheme
vim.cmd.colorscheme "flexoki-dark"
vim.cmd.hi 'Comment gui=none'

