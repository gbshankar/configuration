-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- Options (mirrors your .vimrc settings)
-- ============================================================
vim.g.mapleader      = ","
vim.g.maplocalleader = ","

vim.opt.number        = true
vim.opt.autoindent    = true
vim.opt.smartindent   = true
vim.opt.expandtab     = true
vim.opt.shiftwidth    = 4
vim.opt.softtabstop   = 4
vim.opt.wrap          = true
vim.opt.scrolloff     = 999
vim.opt.sidescrolloff = 15
vim.opt.sidescroll    = 1
vim.opt.incsearch     = true
vim.opt.ignorecase    = true
vim.opt.smartcase     = true
vim.opt.hlsearch      = true
vim.opt.mouse         = "a"
vim.opt.mousehide     = true
vim.opt.clipboard     = "unnamed"
vim.opt.cursorline    = true
vim.opt.colorcolumn   = "+1"
vim.opt.textwidth     = 0
vim.opt.list          = true
vim.opt.listchars     = { tab = "  ", trail = "·" }
vim.opt.undofile      = true
vim.opt.undolevels    = 5000
vim.opt.undoreload    = 5000
vim.opt.confirm       = true
vim.opt.ruler         = true
vim.opt.showcmd       = true
vim.opt.showmatch     = true
vim.opt.wildmenu      = true
vim.opt.history       = 500
vim.opt.foldmethod    = "indent"
vim.opt.foldnestmax   = 3
vim.opt.foldenable    = false
vim.opt.termguicolors = true
vim.opt.background    = "dark"
vim.opt.ttimeoutlen   = 10
vim.opt.timeoutlen    = 1000
vim.opt.laststatus    = 2
vim.opt.cmdheight     = 2
vim.opt.shortmess:append("I")
vim.opt.autoread      = true
vim.opt.title         = true

-- Spelling
vim.opt.spelllang = "en"

-- ============================================================
-- Keymaps
-- ============================================================
-- Clear search highlight (Space, same as .vimrc)
vim.keymap.set("n", "<Space>", ":silent noh<Bar>echo<CR>", { silent = true })

-- Shift-Enter exits insert mode (same as .vimrc)
vim.keymap.set("i", "<S-CR>", "<Esc>")

-- Toggle spell check (same as .vimrc)
vim.keymap.set("n", "<leader>s", ":set spell!<CR>", { silent = true })

-- Toggle line numbers (F1, same as .vimrc)
vim.keymap.set("n", "<F1>", ":set nu! nu?<CR>")

-- Toggle paste mode (F2, same as .vimrc)
vim.keymap.set("n", "<F2>", ":set invpaste paste?<CR>")

-- CamelCase to snake_case (same as .vimrc)
vim.keymap.set("n", "<leader>sc", ":%s/\\([a-z]\\)\\([A-Z]\\)/\\1_\\l\\2/g<CR>")

-- ============================================================
-- Autocmds
-- ============================================================
-- Equalize splits on resize
vim.api.nvim_create_autocmd("VimResized", {
  callback = function() vim.cmd("wincmd =") end,
})

-- Restore cursor position on open (same as .vimrc ResCur)
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    local last_pos = vim.fn.line("'\"")
    if last_pos > 0 and last_pos <= vim.fn.line("$") then
      vim.cmd('normal! g`"')
    end
  end,
})

-- Python colorcolumn
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*/server/*.py",
  callback = function() vim.opt_local.colorcolumn = "100" end,
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*/client/*.py",
  callback = function() vim.opt_local.colorcolumn = "120" end,
})

-- ============================================================
-- Load plugins via lazy.nvim
-- ============================================================
require("lazy").setup("plugins", {
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})
