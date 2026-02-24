-- Markdown-related plugins

return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      -- Server listens on all interfaces (required for SSH forwarding)
      vim.g.mkdp_open_to_the_world = 1
      -- Custom port (default is 8080)
      vim.g.mkdp_port = 8080
      -- Don't auto-open browser on the server side
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      -- Don't echo the default URL (we'll show localhost version)
      vim.g.mkdp_echo_preview_url = 0

      -- Custom function to show localhost URL
      vim.g.mkdp_browserfunc = "OpenMarkdownPreview"

      -- Custom function to display localhost URL
      vim.cmd([[
        function! OpenMarkdownPreview(url)
          " Replace IP address with localhost
          let localhost_url = substitute(a:url, 'http://[0-9.]\+:', 'http://localhost:', '')
          " Display the localhost URL
          echohl WarningMsg
          echo 'Preview page: ' . localhost_url
          echohl None
          " Copy to clipboard (optional)
          let @+ = localhost_url
        endfunction
      ]])
    end,
  },
}
