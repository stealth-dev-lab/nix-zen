-- lua/plugins.lua
-- Main plugin loader - imports plugins from separate files

-- lazy.nvim bootstrap
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

-- Load plugins from separate files
require("lazy").setup({
  { import = "plugins.ui" },
  { import = "plugins.editor" },
  { import = "plugins.coding" },
  { import = "plugins.lsp" },
  { import = "plugins.markdown" },
  { import = "plugins.git" },
}, {
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})
