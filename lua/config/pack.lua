-- ~/.config/nvim/lua/config/pack.lua
-- Plugin management via vim.pack — the built-in manager added in 0.12.
-- vim.pack.add() clones from GitHub and adds to runtimepath.
-- Run :Pack install to fetch, :Pack update to update.
-- Lock file lives at ~/.config/nvim/nvim-pack-lock.json

local add = vim.pack.add
local gh = function(repo)
  return "https://github.com/" .. repo
end

-- ── Colorscheme ────────────────────────────────────────────────────────────
add({ gh("rebelot/kanagawa.nvim") })
vim.cmd.colorscheme("kanagawa-wave")

-- ── Fuzzy Finder ───────────────────────────────────────────────────────────
-- fzf-lua is faster than Telescope and simpler to configure.
-- Requires: ripgrep (rg) for live_grep, fd for file search
add({ gh("ibhagwan/fzf-lua") })
require("fzf-lua").setup({
  winopts = {
    height = 0.85,
    width = 0.80,
    preview = { layout = "vertical", vertical = "down:45%" },
  },
  actions = {
    files = {
      ["default"] = require("fzf-lua.actions").file_edit,
      ["ctrl-q"] = { fn = require("fzf-lua.actions").file_sel_to_qf, prefix = "select-all" },
    },
  },
})

-- ── File Explorer ──────────────────────────────────────────────────────────
-- oil.nvim lets you edit your filesystem like a buffer (mv, rm, mkdir, etc.)
-- Much more powerful than a tree view once you're used to it.
vim.pack.add({ gh("nvim-tree/nvim-web-devicons") })
add({ gh("stevearc/oil.nvim") })
require("oil").setup({
  default_file_explorer = true,
  view_options = { show_hidden = true },
})

-- ── Git ────────────────────────────────────────────────────────────────────
-- gitsigns: inline git blame, hunk navigation, stage/reset hunks
add({ gh("lewis6991/gitsigns.nvim") })
require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
  },
  current_line_blame = true,
  current_line_blame_opts = { delay = 500 },
})

-- fugitive
vim.pack.add({ gh("tpope/vim-fugitive") })

-- ── Statusline ─────────────────────────────────────────────────────────────
-- lualine is the standard. The default statusline in 0.12 is improved,
-- but lualine gives you LSP progress, diagnostics, and branch cleanly.
add({ gh("nvim-lualine/lualine.nvim") })
require("lualine").setup({
  options = {
    component_separators = "|",
    section_separators = "",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { { "filename", path = 1 } }, -- relative path
    lualine_x = { "lsp_progress", "filetype" }, -- lsp_progress requires lualine-lsp-progress
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})

-- ── Keybinding helper ──────────────────────────────────────────────────────
-- which-key shows available keymaps when you pause mid-sequence.
-- Saves a lot of :help lookups when you have a fresh config.
add({ gh("folke/which-key.nvim") })
require("which-key").setup({
  delay = 400,
})

-- ── Auto-pairs ─────────────────────────────────────────────────────────────
-- Automatically close (), [], {}, "", '', ``
add({ gh("windwp/nvim-autopairs") })
require("nvim-autopairs").setup({})

-- ── Surround ───────────────────────────────────────────────────────────────
-- cs"' changes surrounding " to ', ds" deletes surrounding ", ysiw" wraps word
add({ gh("kylechui/nvim-surround") })
require("nvim-surround").setup({})

-- ── Comment ────────────────────────────────────────────────────────────────
-- gcc to toggle line comment, gc in visual mode for block
add({ gh("numToStr/Comment.nvim") })
require("Comment").setup({})

-- ── LSP UI enhancements ────────────────────────────────────────────────────
-- Adds VS Code-style pictograms to native completion popup
add({ gh("onsails/lspkind.nvim") })

-- Nicer LSP diagnostics and hover UI
add({ gh("folke/trouble.nvim") })
require("trouble").setup({})

-- ── Formatting ─────────────────────────────────────────────────────────────
-- conform.nvim handles format-on-save cleanly without touching LSP formatting.
-- Install formatters separately: prettierd (npm), gofmt (go toolchain),
-- rustfmt (rustup), stylua (cargo install stylua)
add({ gh("stevearc/conform.nvim") })
require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    javascriptreact = { "prettierd" },
    json = { "prettierd" },
    html = { "prettierd" },
    css = { "prettierd" },
    go = { "gofmt", "goimports" }, -- goimports also manages imports
    rust = { "rustfmt" },
    python = { "ruff_format" }, -- ruff is fast, replaces black+isort
    sql = { "sqlfmt" }, -- pip install shandy-sqlfmt
    lua = { "stylua" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true, -- fall back to LSP formatting if no formatter found
  },
})

-- ── LSP server installer ───────────────────────────────────────────────────
-- mason.nvim manages LSP server, linter, and formatter binaries.
-- :Mason opens the UI. :MasonInstall <server> installs on demand.
-- You still configure servers via vim.lsp.config (see lsp.lua).
add({ gh("williamboman/mason.nvim") })
require("mason").setup({
  ui = { border = "rounded" },
})
local mason_registry = require("mason-registry")
local ensure_installed = {
  "typescript-language-server",
  "lua-language-server",
  "pyright",
  "sqls",
  "stylua",
}
for _, pkg in ipairs(ensure_installed) do
  if not mason_registry.is_installed(pkg) then
    mason_registry.get_package(pkg):install()
  end
end

-- ── SQL: dadbod stack ──────────────────────────────────────────────────────
-- dadbod is tpope's database interface. Drives queries via :DB.
-- dadbod-ui adds a sidebar with saved connections, query buffers, and results.
-- dadbod-completion adds table/column name completion in SQL buffers.
--
-- Connection URL format: adapter://user:password@host:port/database
-- Examples:
--   postgresql://localhost/mydb
--   sqlite:/path/to/file.db
--   mysql://user:pass@localhost/mydb
add({ gh("tpope/vim-dadbod") })

add({ gh("kristijanhusak/vim-dadbod-ui") })
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod" -- saves queries here
vim.g.db_ui_auto_execute_table_helpers = 1 -- auto-run table info queries in the UI

add({ gh("kristijanhusak/vim-dadbod-completion") })
-- Wire dadbod completion into the native completion for sql filetypes.
-- This adds table/column names from the active connection.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plsql" },
  callback = function()
    vim.opt_local.omnifunc = "vim_dadbod_completion#omni"
    -- Trigger completion with <C-x><C-o> or just <C-Space> if you prefer
    vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { buffer = true, silent = true })
  end,
})

-- ── Syntax Highlighting ──────────────────────────────────────────────────────
vim.pack.add({
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
})

if pcall(require, "nvim-treesitter") then
  require("nvim-treesitter").install({
    "typescript",
    "javascript",
    "tsx",
    "go",
    "rust",
    "python",
    "sql",
    "bash",
    "json",
    "yaml",
  })
end

-- ── JSX/HTML Auto-tagging ──────────────────────────────────────────────────────
vim.pack.add({
  { src = gh("windwp/nvim-ts-autotag") },
})
require("nvim-ts-autotag").setup({
  opts = {
    enable_close = true,
    enable_rename = true,
    enable_close_on_slash = false,
  },
})
