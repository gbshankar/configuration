return {
  { "neovim/nvim-lspconfig" },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup({
        ensure_installed = {
          "gopls", "pyright", "ruff", "lua_ls",
          "terraformls", "yamlls", "dockerls",
        },
        automatic_installation = true,
      })

      local lspconfig    = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "<leader>ld",  vim.lsp.buf.definition,     opts)
        vim.keymap.set("n", "<leader>lr",  vim.lsp.buf.references,     opts)
        vim.keymap.set("n", "<leader>lrn", vim.lsp.buf.rename,         opts)
        vim.keymap.set("n", "<leader>la",  vim.lsp.buf.code_action,    opts)
        vim.keymap.set("n", "<leader>li",  vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "K",           vim.lsp.buf.hover,          opts)
        vim.keymap.set("n", "[d",          vim.diagnostic.goto_prev,   opts)
        vim.keymap.set("n", "]d",          vim.diagnostic.goto_next,   opts)
        vim.keymap.set("n", "<leader>le",  vim.diagnostic.open_float,  opts)
      end

      local servers = {
        gopls = {
          settings = {
            gopls = {
              analyses      = { unusedparams = true },
              staticcheck   = true,
              gofumpt       = true,
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = { typeCheckingMode = "basic" },
            },
          },
        },
        ruff       = {},
        lua_ls     = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace   = { checkThirdParty = false },
            },
          },
        },
        terraformls = {},
        yamlls      = {},
        dockerls    = {},
      }

      for server, config in pairs(servers) do
        config.on_attach    = on_attach
        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end
    end,
  },
}
