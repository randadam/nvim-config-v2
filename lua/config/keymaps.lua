-- ~/.config/nvim/lua/config/keymaps.lua
-- General keymaps (LSP-specific keys live in lsp.lua's on_attach)

local map = vim.keymap.set

-- ── Window navigation ──────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- ── Splits ─────────────────────────────────────────────────────────────────
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close split" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })

-- ── Buffer navigation ──────────────────────────────────────────────────────
map("n", "<S-h>", "<cmd>bprev<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bl", "<cmd>b#<cr>", { desc = "Last buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- ── fzf-lua (fuzzy finder) ─────────────────────────────────────────────────
local fzf = require("fzf-lua")
map("n", "<leader>ff", fzf.files, { desc = "Find files" })
map("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
map("n", "<leader><space>", fzf.buffers, { desc = "Find buffer" })
map("n", "<leader>fh", fzf.help_tags, { desc = "Find help" })
map("n", "<leader>fR", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>fr", function()
  require("fzf-lua").resume()
end, { desc = "Resume last search" })
map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Document symbols" })
map("n", "<leader>fw", fzf.lsp_workspace_symbols, { desc = "Workspace symbols" })
map("n", "<leader>/", fzf.grep_curbuf, { desc = "Grep current buffer" })
map("n", "<leader>fd", function()
  fzf.live_grep({
    cwd = vim.fn.input("Directory: ", vim.fn.getcwd() .. "/", "dir"),
  })
end, { desc = "Grep in directory" })
map("n", "<leader>:", fzf.commands, { desc = "Find Command" })
map("n", "<leader>;", fzf.keymaps, { desc = "Find Keymap" })

-- ── File explorer (oil.nvim) ───────────────────────────────────────────────
map("n", "-", "<cmd>Oil<cr>", { desc = "Open file explorer (vim-vinegar style)" })
-- create file
map("n", "%", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname:match("^oil://") then
    local dir = require("oil").get_current_dir()
    local filename = vim.fn.input("New file: ", dir)
    if filename ~= "" then
      vim.cmd.edit(filename)
    end
  else
    vim.cmd("normal! %")
  end
end, { desc = "Jump to matching" })

-- ── Git (gitsigns) ─────────────────────────────────────────────────────────
-- Hunk navigation and staging — fast inline git workflow
local gs = require("gitsigns")
map("n", "<leader>gg", "<cmd>Git<cr>", { desc = "Open fugitive" })
map("n", "]h", function()
  gs.nav_hunk("next")
end, { desc = "Next hunk" })
map("n", "[h", function()
  gs.nav_hunk("prev")
end, { desc = "Previous hunk" })
map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
map("n", "<leader>hb", function()
  gs.blame_line({ full = true })
end, { desc = "Blame line" })

-- ── SQL / dadbod ───────────────────────────────────────────────────────────
map("n", "<leader>D", "<cmd>DBUIToggle<cr>", { desc = "Toggle DB UI" })
map("n", "<leader>Da", "<cmd>DBUIAddConnection<cr>", { desc = "Add DB connection" })
map("n", "<leader>Df", "<cmd>DBUIFindBuffer<cr>", { desc = "Find DB buffer" })
-- In a SQL buffer, <leader>S executes the current query (dadbod default is \e)
-- You can also visually select lines and hit \e to run just that selection.

-- ── Grug Far (Find and Replace) ───────────────────────────────────────────────────────────
vim.keymap.set({ "n", "v", "x" }, "<leader>sr", function()
  local grug = require("grug-far")
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  grug.open({
    transient = true,
    prefills = {
      -- scope the search to the current file's extension by default
      filesFilter = ext and ext ~= "" and "*." .. ext or nil,
    },
  })
end, { desc = "Search and Replace" })

-- ── Flash (navigation) ────────────────────────────────────────────────────────
local flash = require("flash")
map({ "n", "x", "o" }, "s", function()
  flash.jump()
end)
map({ "n", "x", "o" }, "S", function()
  flash.treesitter({
    actions = {
      ["<C-space>"] = "next",
      ["<BS>"] = "prev",
    },
  })
end)
map("o", "r", function()
  flash.remote()
end)
map({ "x", "o" }, "R", function()
  flash.treesitter_search()
end)

-- ── Quality of life ────────────────────────────────────────────────────────
-- Clear search highlight
map("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Paste without overwriting unnamed register (keep the yanked text)
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- Yank to system clipboard explicitly
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })

-- Format current buffer manually (complement to format-on-save)
map("n", "<leader>cf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })

-- Quick config reload
map("n", "<leader>rc", "<cmd>source $MYVIMRC<cr>", { desc = "Reload config" })
