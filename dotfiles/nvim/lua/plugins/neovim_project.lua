return {
  "coffebar/neovim-project",
  opts = {
    projects = { -- define project roots
      "~/Documents/GitHub/*",
      "~/projects/*",
      "~/.config/*",
    },
  },
  init = function()
    -- enable saving the state of plugins in the session
    local map = vim.keymap.set
    vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
    map("n", "<leader>fp", "<cmd> Telescope neovim-project discover <CR>", { desc = "Find Projects", remap = true })
    map("n", "<leader>fh", "<cmd> Telescope neovim-project history <CR>", { desc = "Projects History", remap = true })
  end,
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim", tag = "0.1.4" },
    { "Shatur/neovim-session-manager" },
  },
  lazy = false,
  priority = 100,
}
