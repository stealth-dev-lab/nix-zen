-- LSP (Language Server Protocol) configuration

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- Auto-completion
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      -- Snippets (required by nvim-cmp)
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local using_new_api = vim.fn.has("nvim-0.11") == 1 and vim.lsp and vim.lsp.config ~= nil

      -- Configure diagnostics
      vim.diagnostic.config({
        update_in_insert = false,  -- Don't update diagnostics in insert mode
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })

      -- Add LSP capabilities to completion
      local capabilities = cmp_nvim_lsp.default_capabilities()

      local setup_server = function(name, config)
        local merged = vim.tbl_deep_extend("force", {
          on_attach = on_attach,
          capabilities = capabilities,
        }, config or {})

        if using_new_api then
          vim.lsp.config(name, merged)
          vim.lsp.enable(name)
        else
          lspconfig[name].setup(merged)
        end
      end

      -- Keybindings when LSP attaches to buffer
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, silent = true }

        -- Navigation
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)           -- Go to definition
        vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, opts)      -- Ctrl-] to use LSP definition
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)          -- Go to declaration
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)           -- Find references
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)       -- Go to implementation

        -- Information
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)                 -- Hover documentation
        vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, opts) -- Signature help

        -- Code actions
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)       -- Rename symbol
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)  -- Code action
        vim.keymap.set("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, opts)                                                         -- Format code

        -- Diagnostics
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)         -- Previous diagnostic
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)         -- Next diagnostic
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- Show diagnostic
      end

      -- Python LSP (pylsp)
      setup_server("pylsp", {
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = { enabled = false },  -- Disable style warnings
              mccabe = { enabled = false },
              pyflakes = { enabled = true },
              pylint = { enabled = false },
            },
          },
        },
      })

      -- Rust LSP (rust-analyzer)
      setup_server("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = true,
            check = {
              command = "clippy",  -- Use clippy for linting
            },
          },
        },
      })

      -- C++ LSP (clangd)
      setup_server("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
        },
      })

      -- Kotlin LSP (kotlin-language-server)
      setup_server("kotlin_language_server", {
        root_dir = util.root_pattern(
          "settings.gradle",
          "build.gradle",
          "build.gradle.kts",
          "gradle.properties",
          ".git"
        ),
        init_options = {
          storagePath = vim.fn.stdpath("cache") .. "/kotlin-language-server",
        },
        single_file_support = true,
      })

      -- Configure diagnostics display
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })

      -- Diagnostic signs in the gutter
      local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "»" }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
    end,
  },

  -- Formatting + linting (none-ls)
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.ktlint,
          null_ls.builtins.diagnostics.ktlint,
        },
      })
    end,
  },

  -- Auto-completion configuration
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept completion
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },  -- LSP
          { name = "luasnip" },   -- Snippets
          { name = "buffer" },    -- Buffer words
          { name = "path" },      -- File paths
        }),
        formatting = {
          format = function(entry, vim_item)
            -- Show source of completion
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })
    end,
  },
}
