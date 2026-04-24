return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {},       -- Go
        clangd = {},      -- C/C++
        pyright = {},     -- Python
        ts_ls = {},       -- TypeScript
        tinymist = {},    -- Typst
        texlab = {},      -- LaTeX
        sqlls = {},       -- SQL
      },
    },
  },
}
