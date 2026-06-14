-- ~/.config/nvim/lua/config/options.lua
-- Core vim options. These are the ones that actually matter day-to-day.

local opt = vim.opt

-- ── Appearance ─────────────────────────────────────────────────────────────
opt.number = true -- absolute line number on current line
opt.relativenumber = true -- relative numbers everywhere else (great for jump motions)
opt.signcolumn = "yes" -- always show sign column so LSP diagnostics don't shift text
opt.cursorline = true -- highlight the current line
opt.termguicolors = true -- true 24-bit color (required by most colorschemes)
opt.showmode = false -- mode is shown in statusline already
opt.scrolloff = 8 -- keep 8 lines visible above/below cursor when scrolling

-- ── Indentation ────────────────────────────────────────────────────────────
opt.expandtab = true -- spaces, not tabs
opt.tabstop = 2 -- how wide a tab character looks
opt.shiftwidth = 2 -- indent size for >> and auto-indent
opt.smartindent = true -- language-aware auto-indent

-- ── Search ─────────────────────────────────────────────────────────────────
opt.ignorecase = true -- case-insensitive search...
opt.smartcase = true -- ...unless pattern has uppercase
opt.hlsearch = false -- don't leave search highlights after done (toggle with <leader>nh if needed)
opt.incsearch = true -- show match as you type

-- ── Splits ─────────────────────────────────────────────────────────────────
opt.splitright = true -- vsplit opens to the right
opt.splitbelow = true -- split opens below

-- ── Files & Undo ───────────────────────────────────────────────────────────
opt.swapfile = false -- swap files are mostly annoyances
opt.backup = false
opt.undofile = true -- persistent undo across sessions — genuinely useful
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- ── Misc ───────────────────────────────────────────────────────────────────
opt.wrap = false -- no line wrapping
opt.clipboard = "unnamedplus" -- sync with system clipboard
opt.updatetime = 250 -- faster CursorHold events (used by LSP hover, gitsigns)
opt.timeoutlen = 300 -- faster which-key popup
opt.mouse = "a" -- mouse support (useful for resizing splits)
opt.list = true -- show invisible characters
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.g.loaded_matchit = 1 -- disable default matchit so '%' works in oil buffers

-- ── Path ───────────────────────────────────────────────────────────────────
vim.env.PATH = vim.env.PATH .. ":" .. vim.env.HOME .. "/.local/share/go/bin"
