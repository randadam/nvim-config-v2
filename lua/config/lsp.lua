-- ~/.config/nvim/lua/config/lsp.lua
-- Native LSP setup using vim.lsp.config() + vim.lsp.enable() — no lspconfig needed.
--
-- How it works in 0.12:
--   vim.lsp.config('server_name', { ...settings... })  → define the server config
--   vim.lsp.enable('server_name')                       → activate it for matching filetypes
--
-- You still need the server binaries installed. Use :Mason to install them:
--   ts_ls         → :MasonInstall typescript-language-server
--   gopls         → go install golang.org/x/tools/gopls@latest
--   rust_analyzer → rustup component add rust-analyzer
--   lua_ls        → :MasonInstall lua-language-server
--   pyright       → :MasonInstall pyright
--
-- Inspect status with :checkhealth vim.lsp or :lsp

-- ── Shared on_attach: runs when LSP attaches to a buffer ───────────────────
-- This is where you bind LSP actions to keys.
local function on_attach(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  -- Navigation
  map("n", "gd",  vim.lsp.buf.definition,      "Go to Definition")
  map("n", "gD",  vim.lsp.buf.declaration,     "Go to Declaration")
  map("n", "gi",  vim.lsp.buf.implementation,  "Go to Implementation")
  map("n", "gr",  vim.lsp.buf.references,      "Go to References")
  map("n", "gt",  vim.lsp.buf.type_definition, "Go to Type Definition")

  -- Docs & Signature
  map("n", "K",     vim.lsp.buf.hover,          "Hover Docs")
  map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

  -- Edits
  map("n", "<leader>rn", vim.lsp.buf.rename,      "Rename Symbol")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Actions")
  map("v", "<leader>ca", vim.lsp.buf.code_action, "Code Actions (visual)")

  -- Diagnostics
  map("n", "[d", vim.diagnostic.goto_prev,       "Previous Diagnostic")
  map("n", "]d", vim.diagnostic.goto_next,       "Next Diagnostic")
  map("n", "<leader>d", vim.diagnostic.open_float, "Show Diagnostic Float")

  -- Trouble (quickfix-style diagnostic list)
  map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Toggle Trouble")
  map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer Diagnostics")
end

-- ── Diagnostic display config ──────────────────────────────────────────────
vim.diagnostic.config({
  virtual_text  = true,
  signs         = true,
  update_in_insert = false,   -- don't show diagnostics while typing (noisy)
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",        -- show which server reported the diagnostic
  },
})

-- ── TypeScript / JavaScript ────────────────────────────────────────────────
-- ts_ls is the official TS language server (was tsserver, renamed)
vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  on_attach = on_attach,
  filetypes = {
    "javascript", "javascriptreact",
    "typescript", "typescriptreact",
  },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints        = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints          = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints  = true,
      },
      preferences = {
        importModuleSpecifier = "non-relative",  -- prefer absolute paths
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "literals",
        includeInlayFunctionLikeReturnTypeHints = true,
      },
    },
  },
})

-- ── Go ─────────────────────────────────────────────────────────────────────
-- gopls is the official Go language server from the Go team.
-- Install: go install golang.org/x/tools/gopls@latest
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  on_attach = on_attach,
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow       = true,
        fieldalignment = true,
      },
      staticcheck    = true,         -- runs staticcheck analyses
      gofumpt        = true,         -- stricter gofmt (pairs with gofumpt formatter)
      usePlaceholders = true,        -- adds placeholders to function completions
      completeUnimported = true,     -- complete symbols from unimported packages
      hints = {
        assignVariableTypes     = true,
        compositeLiteralFields  = true,
        constantValues          = true,
        functionTypeParameters  = true,
        parameterNames          = true,
        rangeVariableTypes      = true,
      },
    },
  },
})

-- ── Rust ───────────────────────────────────────────────────────────────────
-- rust-analyzer is the standard. Install via rustup:
--   rustup component add rust-analyzer
-- OR let mason manage it (:MasonInstall rust-analyzer)
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  on_attach = on_attach,
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "Cargo.lock", ".git" },
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",          -- run clippy instead of check — catches more issues
      },
      cargo = {
        allFeatures = true,          -- enable all cargo features for analysis
      },
      procMacro = {
        enable = true,               -- enable proc macro expansion (needed for many crates)
      },
      inlayHints = {
        bindingModeHints       = { enable = true },
        chainingHints          = { enable = true },
        closingBraceHints      = { enable = true, minLines = 25 },
        closureReturnTypeHints = { enable = "with_block" },
        lifetimeElisionHints   = { enable = "skip_trivial" },
        parameterHints         = { enable = true },
        typeHints              = { enable = true },
      },
    },
  },
})

-- ── SQL ─────────────────────────────────────────────────────────────────────
-- sqls provides completion and basic diagnostics for SQL files.
-- Install via Mason: :MasonInstall sqls
-- Note: sqls is useful for completion/hover but limited for Snowflake-specific
-- syntax. It works best as a general SQL helper alongside dadbod for execution.
vim.lsp.config("sqls", {
  on_attach = on_attach,
  filetypes = { "sql", "mysql" },
  root_markers = { ".sqls.yml", ".git" },
  settings = {
    sqls = {
      -- Optional: point at a config file for connection info
      -- configPath = vim.fn.expand("~/.config/sqls/config.yml"),
    },
  },
})

-- ── Python ─────────────────────────────────────────────────────────────────
-- pyright is the best Python LSP for type-checking accuracy (same engine as
-- VS Code's Pylance). Install via Mason: :MasonInstall pyright
-- Also consider: basedpyright (stricter fork) via :MasonInstall basedpyright
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  on_attach = on_attach,
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml", "setup.py", "setup.cfg",
    "requirements.txt", ".python-version",
    "pyrightconfig.json", ".git",
  },
  settings = {
    python = {
      analysis = {
        typeCheckingMode      = "standard",  -- "off" | "basic" | "standard" | "strict"
        autoSearchPaths       = true,
        useLibraryCodeForTypes = true,
        diagnosticMode        = "workspace", -- analyze whole workspace, not just open files
        inlayHints = {
          variableTypes         = true,
          functionReturnTypes   = true,
          callArgumentNames     = true,
          pytestParameters      = true,
        },
      },
    },
  },
})

-- ── Lua ────────────────────────────────────────────────────────────────────
-- lua_ls understands vim.* APIs when told we're in a Neovim context.
-- Install via Mason: :MasonInstall lua-language-server
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  on_attach = on_attach,
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },     -- Neovim uses LuaJIT
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),  -- expose nvim runtime
      },
      diagnostics = {
        globals = { "vim" },                -- suppress "undefined global vim" warnings
      },
      telemetry = { enable = false },
    },
  },
})

-- ── Enable all configured servers ──────────────────────────────────────────
-- This is the activation step. vim.lsp.config defines; vim.lsp.enable starts.
vim.lsp.enable({
  "ts_ls",
  "gopls",
  "rust_analyzer",
  "lua_ls",
  "pyright",
  "sqls",
})
