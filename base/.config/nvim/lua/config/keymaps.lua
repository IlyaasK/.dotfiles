-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("n", "J", "mzJ`z", { desc = "Join line without moving cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "Page down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Page up centered" })
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result centered" })

map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking selection" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

map("n", "Q", "<nop>", { desc = "Disable Ex mode" })
map("n", "<leader>qj", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
map("n", "<leader>qk", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })
map("n", "<leader>lj", "<cmd>lnext<CR>zz", { desc = "Next location item" })
map("n", "<leader>lk", "<cmd>lprev<CR>zz", { desc = "Previous location item" })

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })
map("n", "<leader><leader>", "<cmd>source %<CR>", { desc = "Source current file" })
