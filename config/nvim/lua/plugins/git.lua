return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "+" },
          change       = { text = "~" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs   = package.loaded.gitsigns
          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "]c", gs.next_hunk, opts)
          vim.keymap.set("n", "[c", gs.prev_hunk, opts)
          vim.keymap.set("n", "<leader>gb", function() gs.blame_line({ full = true }) end, opts)
          vim.keymap.set("n", "<leader>gd", gs.diffthis,    opts)
          vim.keymap.set("n", "<leader>gs", gs.stage_hunk,  opts)
          vim.keymap.set("n", "<leader>gr", gs.reset_hunk,  opts)
        end,
      })
    end,
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gblame", "Gpush", "Gpull", "Gdiffsplit" },
  },
}
