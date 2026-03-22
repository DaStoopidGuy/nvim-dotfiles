-- Bootstrap Paq
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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.o

opt.relativenumber = true
opt.number = true

-- empty string for disabling mouse
-- opt.mouse = "a"
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

-- clear highlights on search when <Esc> is pressed
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- exit terminal mode with <Esc><Esc>-pine
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- split navigation
vim.keymap.set("n", "<leader>q", "<cmd>wincmd q<CR>", { desc = "Quit window" })

vim.keymap.set('n', '<leader>x', '<cmd>split<CR>'   , { desc = "Split window Horizontally" })
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

bootstrap_paq {
    "savq/paq-nvim", -- Let Paq manage itself
    -- colorscheme / theme
    -- { "kepano/flexoki-neovim", as = "flexoki" },
    { "rose-pine/neovim", as = "rose-pine" },

    -- LSP
    "neovim/nvim-lspconfig",

    -- Mason
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",

    -- mini plugins
    { "echasnovski/mini.nvim",       branch = "stable" },

    -- file browser
    "stevearc/oil.nvim",

    -- terminal
    "akinsho/toggleterm.nvim",

    -- telescope
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "nvim-telescope/telescope.nvim",
}

--
-- setup of said plugins
--

-- colorscheme config
-- vim.cmd.colorscheme "flexoki-dark"
-- vim.cmd.hi 'Comment gui=none'
vim.cmd.colorscheme "rose-pine"

-- mason setup
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls"
    }
})

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
  end,
})

-- Lua (Neovim-aware)
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
    },
  },
})

-- lsp diagnostics
vim.diagnostic.config({
  virtual_text = false, -- inline diagnostic messages
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- mini config
require("mini.icons").setup()
require("mini.align").setup()
require("mini.pairs").setup()
require("mini.ai").setup()
require("mini.surround").setup()
require("mini.git").setup()
local statusline = require('mini.statusline')
statusline.setup({ use_icons = vim.g.have_nerd_font })
statusline.section_location = function()
    return "%2l:%-2v"
end
-- require("mini.snippets").setup()
require("mini.completion").setup()

-- file browser - oil
require("oil").setup()
vim.keymap.set('n', '-', "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- terminal
require("toggleterm").setup()
vim.keymap.set("n", "<C-_>", function()
    vim.cmd("ToggleTerm")
end)
vim.keymap.set("t", "<C-_>", function()
    vim.cmd("ToggleTerm")
end)

-- telescope config
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = "Find files"})
vim.keymap.set('n', '<leader>g', builtin.live_grep , { desc = "Live Grep"})
vim.keymap.set('n', '<leader>b', builtin.buffers   , { desc = "Buffers"})
vim.keymap.set('n', '<leader>.', builtin.oldfiles  , { desc = "Recent files"})
vim.keymap.set('n', '<leader>p', builtin.builtin   , { desc = "Select Telescope" })
vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in Current Buffer"})

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

