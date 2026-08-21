-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    vim.keymap.set(
      "n",
      "<C-LeftMouse>",
      "<LeftMouse><cmd>lua vim.lsp.buf.definition()<cr>",
      { buffer = event.buf, desc = "Go to definition" }
    )
  end,
})
