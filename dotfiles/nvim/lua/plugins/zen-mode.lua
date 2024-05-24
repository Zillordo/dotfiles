return {
  "folke/zen-mode.nvim",
  opts = {
    window = {
      backdrop = 1,
    },
    plugins = {
      options = {
        enabled = true,
      },
      kitty = {
        enabled = true,
        font = "14"
      },
      twilight = { enabled = true },
    },
  },
  keys = { 
    { "<leader>uzz", "<cmd>ZenMode<CR>", desc = "Activate Zen mode" },
    { "<leader>uzq", "<cmd>quit<CR>", desc = "Quit Zen mode" }
  },
  dependencies = { "folke/twilight.nvim" },
}
