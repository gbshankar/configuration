return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      local builtin   = require("telescope.builtin")

      telescope.setup({
        defaults = {
          file_ignore_patterns = { ".git/", "node_modules/", "__pycache__/" },
          layout_config        = { horizontal = { preview_width = 0.55 } },
        },
      })
      telescope.load_extension("fzf")

      vim.keymap.set("n", "<leader>ff", builtin.find_files,  { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep,   { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers,     { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags,   { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles,    { desc = "Recent files" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
    end,
  },
}
