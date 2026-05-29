-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- General Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.g.mapleader = " " -- Set leader to space

-- Setup plugins
require("lazy").setup({
  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "eslint", "tailwindcss" },
      })
      vim.lsp.enable({ "ts_ls", "eslint", "tailwindcss" })
    end
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require'cmp'
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'obsidian' },
          { name = 'obsidian_new' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local status, configs = pcall(require, "nvim-treesitter.configs")
      if status then
        configs.setup {
          ensure_installed = { "typescript", "tsx", "javascript", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
          highlight = { enable = true },
        }
      end
    end
  },

  -- Telescope (Fuzzy Finder)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    end
  },

  -- File Tree (Neo-tree)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = "Toggle Explorer" })
    end
  },

  -- Obsidian Integration
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    cmd = { "ObsidianSearch", "ObsidianQuickSwitch", "ObsidianToday", "ObsidianNew" },
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        {
          name = "vault",
          path = "~/dev/AI_Assitant_Vault",
        },
      },
      notes_subdir = "00_Inbox",
      daily_notes = {
        folder = "20_Areas/Journal",
        date_format = "%Y-%m-%d",
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      ui = {
        enable = true,
      },
    },
  },

  -- Themes
  { 
    "catppuccin/nvim", 
    name = "catppuccin", 
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "catppuccin"
    end
  },
})

-- Modern LspAttach
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
  end,
})
