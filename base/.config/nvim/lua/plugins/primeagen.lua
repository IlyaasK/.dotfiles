return {
  -- Harpoon (ThePrimeagen's signature file navigation)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon Add File" },
      { "<C-e>", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon Quick Menu" },
      { "<C-h>", function() require("harpoon"):list():select(1) end, desc = "Harpoon File 1" },
      { "<C-t>", function() require("harpoon"):list():select(2) end, desc = "Harpoon File 2" },
      { "<C-n>", function() require("harpoon"):list():select(3) end, desc = "Harpoon File 3" },
      { "<C-s>", function() require("harpoon"):list():select(4) end, desc = "Harpoon File 4" },
    },
    config = function()
      require("harpoon").setup({})
    end,
  },

  -- Undotree (ThePrimeagen uses this to visualize vim's undo tree)
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle UndoTree" },
    },
  },

  -- Vim Fugitive (ThePrimeagen's git plugin of choice)
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gs", vim.cmd.Git, desc = "Git Status (Fugitive)" },
    },
  },
}
