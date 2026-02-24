-- Git integration plugins

return {
  -- Git signs in the gutter (show changes, blame, etc.)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = '│' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signcolumn = true,  -- Show signs in the gutter
        numhl      = false, -- Highlight line numbers
        linehl     = false, -- Highlight lines
        word_diff  = false, -- Highlight changed words

        -- Keymaps
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation between hunks
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = 'Next git hunk' })

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = 'Previous git hunk' })

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
          map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
          map('v', '<leader>hs', function() gs.stage_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, { desc = 'Stage hunk' })
          map('v', '<leader>hr', function() gs.reset_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, { desc = 'Reset hunk' })
          map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage buffer' })
          map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
          map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset buffer' })
          map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
          map('n', '<leader>hb', function() gs.blame_line({full=true}) end, { desc = 'Blame line' })
          map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'Toggle line blame' })
          map('n', '<leader>hd', gs.diffthis, { desc = 'Diff this' })
          map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = 'Diff this ~' })
          map('n', '<leader>td', gs.toggle_deleted, { desc = 'Toggle deleted' })

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select hunk' })
        end,
      })
    end,
  },

  -- Neogit - Magit-like git interface for Neovim
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- Required dependency
      "sindrets/diffview.nvim",        -- Optional: diff view
      "nvim-telescope/telescope.nvim", -- Optional: telescope integration
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Git commit" },
      { "<leader>gp", "<cmd>Neogit push<cr>", desc = "Git push" },
    },
    config = function()
      require("neogit").setup({
        -- Use telescope for branch selection, etc.
        integrations = {
          telescope = true,
          diffview = true,
        },
        -- Disable built-in commit popup in favor of a simple commit message
        disable_commit_confirmation = false,
        -- Signs in the status buffer
        signs = {
          section = { "", "" },  -- Folded, unfolded section markers
          item = { "", "" },     -- Folded, unfolded item markers
          hunk = { "", "" },     -- Folded, unfolded hunk markers
        },
      })
    end,
  },

  -- Diffview - Enhanced diff and merge conflict viewer
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Repo history" },
    },
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true, -- Better diff highlighting
        use_icons = true,        -- Use file icons
      })
    end,
  },

  -- Fugitive - Classic git plugin (optional, but powerful)
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gedit", "Gsplit" },
    keys = {
      { "<leader>gB", "<cmd>Git blame<cr>", desc = "Git blame" },
    },
  },
}
