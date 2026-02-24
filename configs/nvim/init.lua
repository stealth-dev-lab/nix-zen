vim.notify("init.lua loaded", vim.log.levels.INFO)

-- Suppress deprecation warnings from lspconfig
vim.deprecate = function() end

-- Filter out __GLIBC_USE diagnostics at LSP handler level
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  function(_, result, ctx, config)
    -- Filter diagnostics
    if result and result.diagnostics then
      result.diagnostics = vim.tbl_filter(function(d)
        return not (d.message and d.message:match("__GLIBC_USE"))
      end, result.diagnostics)
    end
    -- Call original handler
    vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
  end,
  {}
)

-- ===== Basic options =====
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.scrolloff = 8

vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

-- Auto-reload files when changed externally (e.g., by Claude Code)
vim.opt.autoread = true

-- Check for external file changes more frequently
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "checktime",
})

-- Notify when file is reloaded
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File reloaded from disk", vim.log.levels.INFO)
  end,
})

-- ===== Search =====
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- ===== Keymaps =====
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>ww", ":w<CR>", { silent = true, desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true, desc = "Quit" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { silent = true, desc = "Clear search highlight" })

-- Window management
vim.keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wx", "<C-w>c", { desc = "Close current window" })
vim.keymap.set("n", "<leader>we", "<C-w>=", { desc = "Equalize window sizes" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Tab management
vim.keymap.set("n", "<leader>tn", ":tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader>tc", ":tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { desc = "Close other tabs" })

-- Markdown preview
vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { silent = true, desc = "Markdown Preview" })
vim.keymap.set("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { silent = true, desc = "Markdown Preview Stop" })


-- Codeium AI (keybindings work in Insert mode)
-- <Tab>  : Accept suggestion
-- <C-n>  : Next suggestion
-- <C-p>  : Previous suggestion
-- <C-x>  : Clear suggestion

-- ===== Misc =====
vim.opt.clipboard = "unnamedplus"

require("plugins")
