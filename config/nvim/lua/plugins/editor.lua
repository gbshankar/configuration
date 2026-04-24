return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        view_options = { show_hidden = true },
      })
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    end,
  },
  {
    "echasnovski/mini.surround",
    version = "*",
    config = function() require("mini.surround").setup() end,
  },
  {
    "echasnovski/mini.comment",
    version = "*",
    config = function() require("mini.comment").setup() end,
  },
}
