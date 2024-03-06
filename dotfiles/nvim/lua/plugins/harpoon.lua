return {
  "theprimeagen/harpoon",
  config = function()
    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

    vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "Add a mark to harpoon" })
    vim.keymap.set("n", "<leader>hh", ui.toggle_quick_menu, { desc = "Toggle harppon marks list" })

    vim.keymap.set("n", "<leader>h1", function()
      ui.nav_file(1)
    end, { desc = "Navigate to 1st mark" })

    vim.keymap.set("n", "<leader>h2", function()
      ui.nav_file(2)
    end, { desc = "Naviate to 2nd mark" })

    vim.keymap.set("n", "<leader>h3", function()
      ui.nav_file(3)
    end, { desc = "Navigate to 3rd mark" })

    vim.keymap.set("n", "<leader>h4", function()
      ui.nav_file(4)
    end, { desc = "Navigate to 4th mark" })

    vim.keymap.set("n", "<Tab>", function()
      ui.nav_next()
    end, { desc = "Navigate to next mark" })

    vim.keymap.set("n", "<S-Tab>", function()
      ui.nav_prev()
    end, { desc = "Naviate to previous mark" })
  end,
}
