return {
  { "rebelot/kanagawa.nvim",
    opts = {
      transparent = true,
      terminalColors = true,
      colors = {
          theme = {
              all = {
                  ui = {
                      bg_gutter = "none"
                  }
              }
          }
      }
    }
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  }
}
