-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("n", "J", "mzJ`z")

-- Move selected line / block of text in visual mode
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("x", "<leader>p", [["_dP]])

map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

map({ "n", "v" }, "<leader>d", [["_d]])

map("n", "Q", "<nop>")

-- Tmux navigation using the <Ctrl> hjkl keys
map("n", "<C-h>", "<cmd> TmuxNavigateLeft <CR>")
map("n", "<C-l>", "<cmd> TmuxNavigateRight <CR>")
map("n", "<C-j>", "<cmd> TmuxNavigateDown <CR>")
map("n", "<C-k>", "<cmd> TmuxNavigateUp <CR>")
