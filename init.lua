-- ~/.config/nvim/init.lua
-- Neovim 0.12+ config — from scratch, fully annotated
-- Load order matters: options → plugins → LSP → keymaps → autocmds

-- ── Leader ─────────────────────────────────────────────────────────────────
-- Set leader early (before any plugin loads that might use it)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.pack") -- vim.pack plugin declarations
require("config.lsp") -- native LSP via vim.lsp.config / vim.lsp.enable
require("config.keymaps")
require("config.autocmds")
