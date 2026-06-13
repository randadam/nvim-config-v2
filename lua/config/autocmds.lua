-- ~/.config/nvim/lua/config/autocmds.lua

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Highlight on yank ──────────────────────────────────────────────────────
-- Briefly flashes the yanked region. Small QoL that confirms what you copied.
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- ── Trim trailing whitespace on save ──────────────────────────────────────
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- ── Restore cursor position on file open ──────────────────────────────────
-- Opens the file at the last known cursor position instead of line 1.
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- ── Go: organize imports on save ──────────────────────────────────────────
-- gopls can organize imports via a code action. This fires it automatically.
-- Works in conjunction with the goimports formatter in conform.nvim.
augroup("GoImports", { clear = true })
autocmd("BufWritePre", {
  group = "GoImports",
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.code_action({
      context = { only = { "source.organizeImports" } },
      apply = true,
    })
  end,
})

-- ── Rust: enable inlay hints ──────────────────────────────────────────────
-- Inlay hints are the inline type annotations rust-analyzer shows.
-- Enable them for Rust buffers only (they can be noisy in other languages).
-- augroup("RustInlayHints", { clear = true })
-- autocmd("LspAttach", {
--   group = "RustInlayHints",
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     if client and client.name == "rust_analyzer" then
--       vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
--     end
--   end,
-- })

-- ── TypeScript: enable inlay hints ────────────────────────────────────────
-- augroup("TSInlayHints", { clear = true })
-- autocmd("LspAttach", {
--   group = "TSInlayHints",
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     if client and client.name == "ts_ls" then
--       vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
--     end
--   end,
-- })

-- ── Python: enable inlay hints ────────────────────────────────────────────
-- augroup("PyrightInlayHints", { clear = true })
-- autocmd("LspAttach", {
--   group = "PyrightInlayHints",
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     if client and client.name == "pyright" then
--       vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
--     end
--   end,
-- })

-- ── Close certain windows with just 'q' ───────────────────────────────────
-- Quickfix, help, man pages, etc. are easier to close without :q
augroup("QuickClose", { clear = true })
autocmd("FileType", {
  group = "QuickClose",
  pattern = { "qf", "help", "man", "lspinfo", "trouble", "fugitive" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
