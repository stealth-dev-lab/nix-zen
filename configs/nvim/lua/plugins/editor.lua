-- Editor enhancement plugins

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 500,
      preset = "modern",
    },
    config = function()
      local wk = require("which-key")
      wk.setup({
        delay = 500,
        preset = "modern",
      })

      -- Register keybinding groups
      wk.add({
        { "<leader>m", group = "Markdown" },
        { "<leader>w", group = "Window" },
        { "<leader>t", group = "Tab" },
        { "<leader>b", group = "Buffer" },
        { "<leader>f", group = "Find" },
      })
    end,
  },
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local oil = require("oil")

      local function find_oil_window()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "oil" then
            return win
          end
        end
        return nil
      end

      local function find_target_window()
        local target = vim.g.oil_target_win
        if target and vim.api.nvim_win_is_valid(target) then
          return target
        end
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype ~= "oil" then
            return win
          end
        end
        return nil
      end

      local function close_oil_window()
        local oil_win = find_oil_window()
        if oil_win and vim.api.nvim_win_is_valid(oil_win) then
          if #vim.api.nvim_tabpage_list_wins(0) > 1 then
            vim.api.nvim_win_close(oil_win, true)
          end
        end
      end

      local function is_directory_entry(entry)
        return entry and (entry.type == "directory" or entry.type == "dir")
      end

      local function open_in_target()
        local target = find_target_window()
        local entry = oil.get_cursor_entry()
        if is_directory_entry(entry) then
          oil.select({ close = false })
          return
        end
        oil.select({
          close = false,
          handle_buffer_callback = function(bufnr)
            if target and vim.api.nvim_win_is_valid(target) then
              vim.api.nvim_set_current_win(target)
              vim.api.nvim_set_current_buf(bufnr)
            else
              vim.api.nvim_set_current_buf(bufnr)
            end
            close_oil_window()
          end,
        })
      end

      local function open_in_target_split(opts)
        local target = find_target_window()
        local entry = oil.get_cursor_entry()
        if is_directory_entry(entry) then
          oil.select({ close = false })
          return
        end
        oil.select({
          close = false,
          handle_buffer_callback = function(bufnr)
            if target and vim.api.nvim_win_is_valid(target) then
              vim.api.nvim_set_current_win(target)
              if opts.vertical then
                vim.cmd("vsplit")
              else
                vim.cmd("split")
              end
            end
            vim.api.nvim_set_current_buf(bufnr)
            close_oil_window()
          end,
        })
      end

      local function open_in_new_tab()
        local entry = oil.get_cursor_entry()
        if is_directory_entry(entry) then
          oil.select({ close = false })
          return
        end
        oil.select({
          close = false,
          handle_buffer_callback = function(bufnr)
            vim.cmd("tabnew")
            vim.api.nvim_set_current_buf(bufnr)
            close_oil_window()
          end,
        })
      end

      local preview_state = {
        win = nil,
        buf = nil,
        active = false,
        path = nil,
      }

      local function close_preview_float()
        if preview_state.win and vim.api.nvim_win_is_valid(preview_state.win) then
          vim.api.nvim_win_close(preview_state.win, true)
        end
        if preview_state.buf and vim.api.nvim_buf_is_valid(preview_state.buf) then
          vim.api.nvim_buf_delete(preview_state.buf, { force = true })
        end
        preview_state.win = nil
        preview_state.buf = nil
        preview_state.active = false
        preview_state.path = nil
      end

      local function render_preview()
        local entry = oil.get_cursor_entry()
        if not entry or entry.type ~= "file" then
          return
        end

        local dir = oil.get_current_dir(0)
        if not dir then
          vim.notify("Unable to resolve directory", vim.log.levels.WARN)
          return
        end

        local path = vim.fs.joinpath(dir, entry.name)
        if preview_state.path == path then
          return
        end
        if not vim.loop.fs_stat(path) then
          return
        end

        local ok, lines = pcall(vim.fn.readfile, path, "", 2000)
        if not ok then
          vim.notify("Failed to read file: " .. path, vim.log.levels.WARN)
          return
        end

        local buf = preview_state.buf
        if not buf or not vim.api.nvim_buf_is_valid(buf) then
          buf = vim.api.nvim_create_buf(false, true)
          preview_state.buf = buf
          vim.bo[buf].bufhidden = "wipe"
        end

        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        vim.bo[buf].filetype = vim.filetype.match({ filename = path }) or ""
        preview_state.path = path
      end

      local function ensure_preview_window()
        if preview_state.win and vim.api.nvim_win_is_valid(preview_state.win) then
          return
        end

        local width = math.max(60, math.floor(vim.o.columns * 0.6))
        local height = math.max(10, math.floor(vim.o.lines * 0.6))
        local row = math.floor((vim.o.lines - height) / 2 - 1)
        local col = math.floor((vim.o.columns - width) / 2)

        preview_state.win = vim.api.nvim_open_win(preview_state.buf, false, {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          border = "rounded",
        })
      end

      local function update_preview_float()
        if not preview_state.active then
          return
        end
        render_preview()
        if preview_state.buf and vim.api.nvim_buf_is_valid(preview_state.buf) then
          ensure_preview_window()
        end
      end

      local function open_preview_float()
        if preview_state.active then
          close_preview_float()
          return
        end

        preview_state.active = true
        update_preview_float()
      end

      local function toggle_oil_sidebar()
        if find_oil_window() then
          close_oil_window()
          return
        end

        vim.g.oil_target_win = vim.api.nvim_get_current_win()
        vim.cmd("topleft vsplit")
        local new_oil_win = vim.api.nvim_get_current_win()
        local width = math.max(20, math.floor(vim.o.columns * 0.2))
        vim.api.nvim_win_set_width(new_oil_win, width)
        vim.wo[new_oil_win].winfixwidth = true
        oil.open()
      end

      oil.setup({
        -- Show hidden files by default
        view_options = {
          show_hidden = true,
        },
        -- Columns to display
        columns = {
          "icon",
        },
        -- Keymaps in oil buffer
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = { callback = open_in_target, desc = "Open in target window" },
          ["t"] = { callback = open_in_new_tab, desc = "Open in new tab" },
          ["s"] = { callback = function() open_in_target_split({ vertical = false }) end, desc = "Open in horizontal split" },
          ["v"] = { callback = function() open_in_target_split({ vertical = true }) end, desc = "Open in vertical split" },
          ["p"] = { callback = open_preview_float, desc = "Preview in floating window" },
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["g."] = "actions.toggle_hidden",
        },
      })

      -- Toggle oil in a left sidebar
      vim.keymap.set("n", "<leader>e", toggle_oil_sidebar, { desc = "Toggle file explorer" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "oil",
        callback = function(args)
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = args.buf,
            callback = update_preview_float,
          })
          vim.api.nvim_create_autocmd("BufLeave", {
            buffer = args.buf,
            callback = close_preview_float,
          })
        end,
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
      })

      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
    end,
  },
}
