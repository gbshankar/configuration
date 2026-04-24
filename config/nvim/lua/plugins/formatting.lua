return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd   = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          go        = { "goimports", "gofmt" },
          python    = { "ruff_format" },
          lua       = { "stylua" },
          yaml      = { "prettier" },
          json      = { "prettier" },
          markdown  = { "prettier" },
          terraform = { "terraform_fmt" },
          ["*"]     = { "trim_whitespace" },
        },
        format_on_save = {
          timeout_ms = 3000,
          lsp_format = "fallback",
        },
      })
    end,
  },
}
