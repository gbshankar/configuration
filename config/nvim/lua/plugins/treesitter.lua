return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "go", "python", "lua", "yaml", "json", "hcl",
          "dockerfile", "bash", "markdown", "markdown_inline",
          "toml", "vim", "vimdoc", "terraform",
        },
        auto_install  = true,
        highlight     = { enable = true },
        indent        = { enable = true },
      })
    end,
  },
}
