-- Coding assistance plugins (AI, syntax highlighting, etc.)

return {
  {
    "nvim-lua/plenary.nvim",
  },
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function()
      -- Disable default keybindings
      vim.g.codeium_disable_bindings = 1

      -- Custom keybindings (Insert mode only)
      vim.keymap.set("i", "<Tab>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true })
      vim.keymap.set("i", "<C-n>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true, silent = true })
      vim.keymap.set("i", "<C-p>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true, silent = true })
      vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true, silent = true })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local status_ok, configs = pcall(require, "nvim-treesitter.configs")
      if not status_ok then
        return
      end

      configs.setup({
        ensure_installed = { "lua", "vim", "vimdoc", "markdown", "python", "javascript", "typescript" },
        highlight = {
          enable = true,
        },
      })
    end,
  },
}
