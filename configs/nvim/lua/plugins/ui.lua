-- UI-related plugins (colorscheme, statusline, etc.)

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup()
    end,
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "tabs",
          diagnostics = "nvim_lsp",
          separator_style = "slant",
          show_close_icon = false,
        },
      })

      vim.keymap.set("n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
      vim.keymap.set("n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
      vim.keymap.set("n", "<leader>bm", "<Cmd>BufferLineMovePrev<CR>", { desc = "Move buffer left" })
      vim.keymap.set("n", "<leader>bM", "<Cmd>BufferLineMoveNext<CR>", { desc = "Move buffer right" })
      vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
      vim.keymap.set("n", "<leader>ba", "<Cmd>BufferLineTogglePin<CR>", { desc = "Pin buffer" })
      vim.keymap.set("n", "<leader>bc", "<Cmd>bdelete<CR>", { desc = "Close buffer" })
    end,
  },
}
