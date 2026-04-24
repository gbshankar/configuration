# Dotfiles Overhaul Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace zprezto+vim+pyenv/jenv/fnm with Starship+minimal-zsh+Neovim+mise, wire everything through the `~/personal/configuration` bare git repo with a symlink-based install script.

**Architecture:** All dotfiles live in `~/personal/configuration`, symlinked into `~` and `~/.config` by `install.sh`. New shell is framework-free zsh with cached compinit, Starship prompt, and mise for all runtime versions. Neovim replaces vim with lazy.nvim + LSP via mason + Treesitter.

**Tech Stack:** zsh, Starship, mise, Neovim (lazy.nvim, mason, nvim-lspconfig, nvim-cmp, telescope, conform, gitsigns, lualine), tmux (TPM), atuin, fzf, fd, ripgrep, delta

**Spec:** `docs/superpowers/specs/2026-04-23-dotfiles-overhaul-design.md`

---

## File Map

### Created
- `~/personal/configuration/install.sh` — idempotent symlink installer
- `~/personal/configuration/config/nvim/init.lua` — Neovim entry point (options, keymaps, lazy bootstrap)
- `~/personal/configuration/config/nvim/lua/plugins/lsp.lua` — mason + nvim-lspconfig
- `~/personal/configuration/config/nvim/lua/plugins/treesitter.lua` — nvim-treesitter
- `~/personal/configuration/config/nvim/lua/plugins/telescope.lua` — telescope + fzf-native
- `~/personal/configuration/config/nvim/lua/plugins/completion.lua` — nvim-cmp + LuaSnip
- `~/personal/configuration/config/nvim/lua/plugins/formatting.lua` — conform.nvim
- `~/personal/configuration/config/nvim/lua/plugins/git.lua` — gitsigns + vim-fugitive
- `~/personal/configuration/config/nvim/lua/plugins/ui.lua` — lualine + which-key + tokyonight
- `~/personal/configuration/config/nvim/lua/plugins/editor.lua` — oil.nvim + mini.surround + mini.comment
- `~/personal/configuration/config/starship.toml` — Starship prompt config
- `~/personal/configuration/config/mise/config.toml` — mise global tool versions
- `~/personal/configuration/config/atuin/config.toml` — atuin history config
- `~/.local/bin/tmux-sessionizer` — fzf project switcher script

### Rewritten
- `~/personal/configuration/zshrc` — framework-free, under 200ms startup
- `~/personal/configuration/tmux.conf` — tmux-256color, tmux-battery, sessionizer binding

### Updated
- `~/personal/configuration/gitconfig` — add commit.verbose, column.ui, init.defaultBranch; remove core.compression=-1
- `~/personal/configuration/Brewfile` — add neovim/starship/mise/atuin/zsh-autosuggestions; remove fnm/jenv/pyenv/nvm

---

## Task 1: Safety Snapshot — Sync Live Dotfiles to Repo

**Files:**
- Modify: `~/personal/configuration/zshrc`
- Modify: `~/personal/configuration/tmux.conf`

- [ ] **Step 1: Copy live dotfiles into repo**

```bash
cd ~/personal/configuration
cp ~/.zshrc zshrc
cp ~/.tmux.conf tmux.conf
cp ~/.gitconfig gitconfig
cp ~/.alias alias
cp ~/.ripgreprc ripgreprc 2>/dev/null || true
```

- [ ] **Step 2: Check what changed**

```bash
cd ~/personal/configuration
git diff --stat
```

Expected: shows modified files (zshrc will differ from repo version — the live one has pyenv, syntax-highlighting, etc.)

- [ ] **Step 3: Stage and commit**

```bash
cd ~/personal/configuration
git add zshrc tmux.conf gitconfig alias ripgreprc
git commit -m "snapshot: current dotfiles before overhaul"
```

- [ ] **Step 4: Push to GitHub**

```bash
cd ~/personal/configuration
git push origin master
```

Expected: `master -> master` pushed successfully. This is your rollback point.

---

## Task 2: Install New Tools via Homebrew

**Files:** none (system install)

- [ ] **Step 1: Install all new tools**

```bash
brew install neovim starship mise atuin zsh-autosuggestions
```

- [ ] **Step 2: Verify installs**

```bash
nvim --version | head -1
starship --version
mise --version
atuin --version
ls /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
```

Expected output (versions may differ):
```
NVIM v0.10.x
starship 1.x.x
mise 2025.x.x
atuin x.x.x
/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
```

---

## Task 3: Create Repo Directory Structure

**Files:**
- Create: `~/personal/configuration/config/nvim/lua/plugins/` (directory)
- Create: `~/personal/configuration/config/mise/` (directory)
- Create: `~/personal/configuration/config/atuin/` (directory)

- [ ] **Step 1: Create all directories**

```bash
cd ~/personal/configuration
mkdir -p config/nvim/lua/plugins
mkdir -p config/mise
mkdir -p config/atuin
mkdir -p ~/.local/bin
```

- [ ] **Step 2: Verify**

```bash
find ~/personal/configuration/config -type d
```

Expected:
```
~/personal/configuration/config
~/personal/configuration/config/nvim
~/personal/configuration/config/nvim/lua
~/personal/configuration/config/nvim/lua/plugins
~/personal/configuration/config/mise
~/personal/configuration/config/atuin
```

---

## Task 4: Write New zshrc

**Files:**
- Modify: `~/personal/configuration/zshrc`

- [ ] **Step 1: Write the new zshrc**

Write the following to `~/personal/configuration/zshrc` (completely replacing existing content):

```zsh
##############################################################################
# ~/.zshrc — framework-free zsh config
# Managed via ~/personal/configuration — edit there, not here
##############################################################################

##############################################################################
# 1. Homebrew (hardcoded prefix — avoids slow `brew --prefix` subshell)
##############################################################################
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_NO_AUTO_UPDATE=1
export FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"

##############################################################################
# 2. PATH — set once, no duplicates
##############################################################################
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$HOME/.local/bin:$HOME/.antigravity/antigravity/bin:$HOME/.rd/bin:$PATH"

##############################################################################
# 3. compinit with 24h cache (skips regeneration on every shell open)
##############################################################################
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

##############################################################################
# 4. Zsh options
##############################################################################
setopt autocd
setopt extended_glob
setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history
setopt hist_verify

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000

##############################################################################
# 5. cdpath — jump to project dirs without full path
##############################################################################
cdpath=($HOME/src $HOME/personal)

##############################################################################
# 6. Completion style
##############################################################################
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"
zstyle ':completion:*' menu select

##############################################################################
# 7. Go
##############################################################################
export GOPATH="$HOME/go"
export GOPROXY='http://athens.ingress.infra-prd.us-east-1.k8s.lyft.net,direct'
export GONOSUMDB='github.com/lyft/*,github.lyft.net/*'
export GONOSUM='github.com/lyft/*,github.lyft.net/*'
export PATH="$GOPATH/bin:$PATH"

##############################################################################
# 8. mise — single version manager (Python, Node, Java)
##############################################################################
eval "$(mise activate zsh)"

##############################################################################
# 9. atuin — searchable shell history (replaces Ctrl-R)
##############################################################################
eval "$(atuin init zsh)"

##############################################################################
# 10. fzf
##############################################################################
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='-m --height 50% --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

##############################################################################
# 11. ripgrep config
##############################################################################
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

##############################################################################
# 12. Plugins (syntax highlighting must be last, autosuggestions before it)
##############################################################################
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

##############################################################################
# 13. Lyft tooling — DO NOT REMOVE
##############################################################################
if [[ -f "/opt/homebrew/Library/Taps/lyft/homebrew-localdevtools/scripts/shell_rc.sh" ]]; then
  source "/opt/homebrew/Library/Taps/lyft/homebrew-localdevtools/scripts/shell_rc.sh"
fi
if [[ -f "$HOME/.rd/shell_rc.sh" ]]; then
  source "$HOME/.rd/shell_rc.sh"
fi

##############################################################################
# 14. Aliases
##############################################################################
source "$HOME/.alias"

##############################################################################
# 15. iTerm2 shell integration
##############################################################################
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

##############################################################################
# 16. Starship prompt — must be last
##############################################################################
eval "$(starship init zsh)"
```

- [ ] **Step 2: Commit**

```bash
cd ~/personal/configuration
git add zshrc
git commit -m "feat(shell): replace zprezto with minimal zsh + starship"
```

---

## Task 5: Set Up mise

**Files:**
- Create: `~/personal/configuration/config/mise/config.toml`

- [ ] **Step 1: Write mise global config**

Write the following to `~/personal/configuration/config/mise/config.toml`:

```toml
[tools]
python = "3.10.0"
node = "22.19.0"

[settings]
experimental = true
jobs = 4
```

Note: Python 3.10.0 and Node 22.19.0 match your current pyenv/fnm globals. Java is omitted — no JDK was installed under jenv.

- [ ] **Step 2: Symlink config early so mise can read it**

```bash
mkdir -p ~/.config/mise
ln -sf ~/personal/configuration/config/mise/config.toml ~/.config/mise/config.toml
```

- [ ] **Step 3: Install the tool versions via mise**

```bash
mise install
```

Expected: downloads Python 3.10.0 and Node 22.19.0 into `~/.local/share/mise/`.

- [ ] **Step 4: Verify mise sees the correct versions**

```bash
mise doctor
mise list
```

Expected: no errors from `mise doctor`; `mise list` shows `python 3.10.0` and `node 22.19.0`.

- [ ] **Step 5: Commit**

```bash
cd ~/personal/configuration
git add config/mise/config.toml
git commit -m "feat(mise): add global config for python 3.10.0 and node 22.19.0"
```

---

## Task 6: Write atuin Config

**Files:**
- Create: `~/personal/configuration/config/atuin/config.toml`

- [ ] **Step 1: Write atuin config**

Write the following to `~/personal/configuration/config/atuin/config.toml`:

```toml
# atuin — searchable shell history
# Replaces Ctrl-R with fuzzy-searchable history across sessions

[history]
filter_mode = "host"        # show only history from this machine by default
filter_mode_shell_up_key_binding = "session"  # up-arrow shows session history

[search]
search_mode = "fuzzy"       # fuzzy match on all history fields

[sync]
records = true
```

- [ ] **Step 2: Symlink early so atuin can read it**

```bash
mkdir -p ~/.config/atuin
ln -sf ~/personal/configuration/config/atuin/config.toml ~/.config/atuin/config.toml
```

- [ ] **Step 3: Commit**

```bash
cd ~/personal/configuration
git add config/atuin/config.toml
git commit -m "feat(atuin): add history search config"
```

---

## Task 7: Write Starship Config

**Files:**
- Create: `~/personal/configuration/config/starship.toml`

- [ ] **Step 1: Write starship.toml**

Write the following to `~/personal/configuration/config/starship.toml`:

```toml
# Starship prompt — backend/infra focused
# Shows: directory, git branch/status, python venv, go version, k8s context, command duration

format = """
$directory\
$git_branch\
$git_status\
$python\
$golang\
$kubernetes\
$cmd_duration\
$line_break\
$character"""

[directory]
truncation_length = 4
truncate_to_repo = true
style = "bold cyan"

[git_branch]
symbol = " "
format = "[$symbol$branch]($style) "
style = "bold purple"

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "bold yellow"
conflicted = "="
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?"
stashed = "$"
modified = "!"
staged = "+"
renamed = "»"
deleted = "✘"

[python]
format = '[${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'
symbol = " "
style = "bold yellow"

[golang]
format = "[$symbol($version )]($style)"
symbol = " "
style = "bold cyan"

[kubernetes]
disabled = false
format = '[$symbol$context(\[$namespace\])]($style) '
symbol = "⎈ "
style = "bold blue"
# Only show k8s context when KUBECONFIG is set or kubectl is in use
detect_files = ["*.yaml", "*.yml", "Dockerfile", "docker-compose.yml"]

[cmd_duration]
min_time = 2000
format = "took [$duration]($style) "
style = "bold yellow"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold green)"

[aws]
disabled = true

[gcloud]
disabled = true
```

- [ ] **Step 2: Symlink**

```bash
mkdir -p ~/.config
ln -sf ~/personal/configuration/config/starship.toml ~/.config/starship.toml
```

- [ ] **Step 3: Commit**

```bash
cd ~/personal/configuration
git add config/starship.toml
git commit -m "feat(starship): add prompt config for backend/infra workflow"
```

---

## Task 8: Write Neovim init.lua

**Files:**
- Create: `~/personal/configuration/config/nvim/init.lua`

- [ ] **Step 1: Write init.lua**

Write the following to `~/personal/configuration/config/nvim/init.lua`:

```lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
vim.opt.pastetoggle = "<F2>"

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
```

- [ ] **Step 2: Commit**

```bash
cd ~/personal/configuration
git add config/nvim/init.lua
git commit -m "feat(nvim): add init.lua with options and lazy.nvim bootstrap"
```

---

## Task 9: Write Neovim Plugin Files

**Files:**
- Create: `~/personal/configuration/config/nvim/lua/plugins/lsp.lua`
- Create: `~/personal/configuration/config/nvim/lua/plugins/treesitter.lua`
- Create: `~/personal/configuration/config/nvim/lua/plugins/telescope.lua`
- Create: `~/personal/configuration/config/nvim/lua/plugins/completion.lua`
- Create: `~/personal/configuration/config/nvim/lua/plugins/formatting.lua`
- Create: `~/personal/configuration/config/nvim/lua/plugins/git.lua`
- Create: `~/personal/configuration/config/nvim/lua/plugins/ui.lua`
- Create: `~/personal/configuration/config/nvim/lua/plugins/editor.lua`

- [ ] **Step 1: Write lsp.lua**

Write the following to `~/personal/configuration/config/nvim/lua/plugins/lsp.lua`:

```lua
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
```

- [ ] **Step 2: Write treesitter.lua**

Write the following to `~/personal/configuration/config/nvim/lua/plugins/treesitter.lua`:

```lua
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
```

- [ ] **Step 3: Write telescope.lua**

Write the following to `~/personal/configuration/config/nvim/lua/plugins/telescope.lua`:

```lua
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
```

- [ ] **Step 4: Write completion.lua**

Write the following to `~/personal/configuration/config/nvim/lua/plugins/completion.lua`:

```lua
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources(
          { { name = "nvim_lsp" }, { name = "luasnip" } },
          { { name = "buffer" },   { name = "path" } }
        ),
      })
    end,
  },
}
```

- [ ] **Step 5: Write formatting.lua**

Write the following to `~/personal/configuration/config/nvim/lua/plugins/formatting.lua`:

```lua
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
          timeout_ms   = 3000,
          lsp_fallback = true,
        },
      })
    end,
  },
}
```

- [ ] **Step 6: Write git.lua**

Write the following to `~/personal/configuration/config/nvim/lua/plugins/git.lua`:

```lua
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
```

- [ ] **Step 7: Write ui.lua**

Write the following to `~/personal/configuration/config/nvim/lua/plugins/ui.lua`:

```lua
return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "night" })
      vim.cmd("colorscheme tokyonight-night")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme                = "tokyonight",
          component_separators = "|",
          section_separators   = "",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({})
    end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
```

- [ ] **Step 8: Write editor.lua**

Write the following to `~/personal/configuration/config/nvim/lua/plugins/editor.lua`:

```lua
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
```

- [ ] **Step 9: Commit all plugin files**

```bash
cd ~/personal/configuration
git add config/nvim/
git commit -m "feat(nvim): add lazy.nvim plugin configs (lsp, treesitter, telescope, cmp, conform, git, ui, editor)"
```

---

## Task 10: Update tmux.conf

**Files:**
- Modify: `~/personal/configuration/tmux.conf`

- [ ] **Step 1: Write new tmux.conf**

Write the following to `~/personal/configuration/tmux.conf` (replacing all content):

```bash
###########
# General #
###########
set-option -g default-shell /opt/homebrew/bin/zsh
set -g default-terminal "tmux-256color"
set -as terminal-features ",xterm-256color:RGB"
set -g history-limit 50000
set -sg escape-time 0
set -g focus-events on

#################
# Pane & Window #
#################
setw -g pane-base-index 1
set -g base-index 1
set -g renumber-windows on
setw -g aggressive-resize on

# Retain cwd on new panes/windows
bind c new-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
bind '"' split-window -v -c "#{pane_current_path}"

############
# Scrolling #
############
setw -g mode-keys vi
bind -n C-k clear-history

#####################
# Mouse & Selection #
#####################
set -g mouse on
bind-key -T root WheelUpPane   if-shell -F "#{pane_in_mode}" "send-keys -M" "copy-mode -e"
bind-key -T root WheelDownPane send-keys -M

bind -T root WheelUpPane \
  if-shell -F '#{alternate_on}' 'send-keys -M' 'copy-mode -e'

bind -T root WheelDownPane \
  if-shell -F '#{alternate_on}' 'send-keys -M' 'send-keys -M'

#################
# Key Bindings  #
#################
# Zoom pane
bind z resize-pane -Z \; display-message "zoom"

# Easy resizing (vim keys) — unchanged from original
bind -r C-h resize-pane -L 5
bind -r C-j resize-pane -D 5
bind -r C-k resize-pane -U 5
bind -r C-l resize-pane -R 5
bind -r H resize-pane -L 15
bind -r L resize-pane -R 15

# Vi copy-mode — unchanged from original
bind Escape copy-mode -e
bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
bind-key -T copy-mode-vi 'y' send-keys -X copy-selection

# Sessionizer — fzf project switcher
bind-key -r f run-shell "tmux neww ~/.local/bin/tmux-sessionizer"

# Quick config edit
bind e new-window -n "tmux-config" "nvim ~/.tmux.conf"

##############
# Status Bar #
##############
set -g status on
set -g status-interval 5
set -g status-bg colour235
set -g status-fg colour136
set -g status-left " [#S] "
set -g status-left-length 20
set -g status-right "#{battery_percentage} | %Y-%m-%d %H:%M "
set -g status-right-length 50

################
# Plugins (TPM)#
################
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-battery'

set -g @continuum-restore 'on'

run '~/.tmux/plugins/tpm/tpm'
```

- [ ] **Step 2: Install tmux-battery plugin**

In a running tmux session, run:
```
<prefix>I
```
(That's `Ctrl-b` then `I` — capital I). Wait for TPM to install `tmux-battery`.

Expected: status bar shows battery percentage after install.

- [ ] **Step 3: Commit**

```bash
cd ~/personal/configuration
git add tmux.conf
git commit -m "feat(tmux): upgrade to tmux-256color, add sessionizer, tmux-battery"
```

---

## Task 11: Write tmux-sessionizer Script

**Files:**
- Create: `~/.local/bin/tmux-sessionizer`

- [ ] **Step 1: Write the script**

Write the following to `~/.local/bin/tmux-sessionizer`:

```bash
#!/usr/bin/env bash
# tmux-sessionizer — fzf-based project switcher
# Bound to <prefix>f in tmux.conf
# Lists ~/src and ~/personal dirs, jumps to existing session or creates new one

selected=$(find ~/src ~/personal -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
  | fzf --height 40% --reverse --prompt="session> ")

if [[ -z "$selected" ]]; then
    exit 0
fi

# Derive session name: basename, dots replaced with underscores
selected_name=$(basename "$selected" | tr . _)

# If not inside tmux and tmux isn't running, start fresh
if [[ -z "$TMUX" ]] && ! pgrep -x tmux > /dev/null; then
    tmux new-session -s "$selected_name" -c "$selected"
    exit 0
fi

# Create session if it doesn't exist
if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

# Switch to it
tmux switch-client -t "$selected_name"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x ~/.local/bin/tmux-sessionizer
```

- [ ] **Step 3: Verify the script runs without error (no tmux session needed)**

```bash
echo "test" | ~/.local/bin/tmux-sessionizer || echo "exit $? (expected non-zero if fzf gets no selection)"
```

Expected: exits cleanly (fzf gets piped input but that's fine — this just verifies the script is parseable).

- [ ] **Step 4: Note — tmux-sessionizer lives in ~/.local/bin, not the dotfiles repo**

This is intentional: it's a standalone script, not a config file. `~/.local/bin` is already in PATH via the new zshrc.

---

## Task 12: Update gitconfig

**Files:**
- Modify: `~/personal/configuration/gitconfig`

- [ ] **Step 1: Replace gitconfig with the complete new version**

Write the following to `~/personal/configuration/gitconfig` (replacing all content):

```ini
[user]
	name = Bhavani Shankar Garikapati
	email = 6279355+gbshankar@users.noreply.github.com

[color]
    ui = true

[core]
    preloadIndex = true
    fscache = true
    untrackedCache = true
    pager = delta
    editor = nvim

[pack]
    threads = 16

[gc]
    auto = 6700

[status]
    showUntrackedFiles = normal

[fetch]
    parallel = 4
    prune = true

[maintenance]
    auto = true

[merge]
    tool = vimdiff
    conflictstyle = diff3

[rebase]
    autosquash = true

[interactive]
    diffFilter = delta --color-only

[delta]
    features = default
    line-numbers = true
    side-by-side = true
    navigate = true
    hyperlinks = true

[url "ssh://git@github.com/"]
	insteadOf = https://github.com/

[pull]
    rebase = true

[push]
    default = current
    autoSetupRemote = true

[branch]
    sort = -committerdate

[diff]
    algorithm = histogram
    colorMoved = default

[rerere]
    enabled = true
    autoupdate = true

[log]
    abbrevCommit = true

[commit]
    verbose = true

[column]
    ui = auto

[init]
    defaultBranch = main

[help]
    autocorrect = prompt

[alias]
    lg = log --oneline --graph --decorate --all
    sw = switch
    recent = branch --sort=-committerdate
    undo = reset --soft HEAD~1

[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
```

Changes from original: removed `core.compression = -1`, updated `core.editor` from `vim` to `nvim`, added `[commit]`, `[column]`, `[init]` blocks.

- [ ] **Step 2: Verify the file parses correctly**

```bash
git config --file ~/personal/configuration/gitconfig --list | grep -E "(verbose|column|defaultBranch|compression)"
```

Expected:
```
commit.verbose=true
column.ui=auto
init.defaultbranch=main
```

`compression` should NOT appear.

- [ ] **Step 3: Commit**

```bash
cd ~/personal/configuration
git add gitconfig
git commit -m "feat(git): add commit.verbose, column.ui, init.defaultBranch; remove compression=-1; editor=nvim"
```

---

## Task 13: Update Brewfile

**Files:**
- Modify: `~/personal/configuration/Brewfile`

- [ ] **Step 1: Write the updated Brewfile**

Write the following to `~/personal/configuration/Brewfile` (replacing all content):

```ruby
# Taps
tap "kyoh86/tap"

# Shell
brew "zsh"
brew "zsh-syntax-highlighting"
brew "zsh-autosuggestions"       # new
brew "starship"                  # new

# Runtime version manager (replaces pyenv + jenv + fnm)
brew "mise"                      # new

# Editor
brew "neovim"                    # new (replaces vim)
brew "vim"                       # keep for emergency fallback

# Search & navigation
brew "fd"
brew "ripgrep"
brew "fzf"

# Git
brew "git-delta"
brew "gh"

# Languages & build
brew "python"
brew "go"
brew "openjdk"
brew "maven"

# Go tools
brew "golangci-lint"
brew "staticcheck"
brew "mockery"
brew "kyoh86/tap/richgo"

# Cloud & infra
brew "awscli"
brew "terraform"
brew "tflint"
brew "grpcurl"

# Shell history
brew "atuin"                     # new

# Multiplexer
brew "tmux"

# Misc
brew "bazelisk"
brew "freetype"
brew "harfbuzz"
brew "imagemagick"
brew "libpq", link: true
brew "mtr"
brew "pkgconf"
brew "rpl"
brew "yarn"
```

Removed: `ack`, `fnm`, `jenv`, `pyenv`, `nvm` (replaced by mise)

- [ ] **Step 2: Commit**

```bash
cd ~/personal/configuration
git add Brewfile
git commit -m "feat(brew): add neovim/starship/mise/atuin/zsh-autosuggestions; remove pyenv/jenv/fnm"
```

---

## Task 14: Write install.sh

**Files:**
- Create: `~/personal/configuration/install.sh`

- [ ] **Step 1: Write install.sh**

Write the following to `~/personal/configuration/install.sh`:

```bash
#!/usr/bin/env bash
# install.sh — idempotent symlink installer for dotfiles
# Usage: bash ~/personal/configuration/install.sh
# Safe to re-run. Backs up existing files to <file>.bak before linking.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

symlink() {
    local src="$REPO_DIR/$1"
    local dst="$2"

    # Ensure parent directory exists
    mkdir -p "$(dirname "$dst")"

    # If target exists and is not already the correct symlink
    if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
        echo -e "${YELLOW}Backing up${NC} $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    elif [[ -L "$dst" ]]; then
        local current
        current="$(readlink "$dst")"
        if [[ "$current" == "$src" ]]; then
            echo -e "${GREEN}Already linked${NC}: $dst"
            return
        else
            echo -e "${YELLOW}Removing stale symlink${NC} $dst (was → $current)"
            rm "$dst"
        fi
    fi

    echo -e "${GREEN}Linking${NC}: $dst → $src"
    ln -s "$src" "$dst"
}

echo "Installing dotfiles from $REPO_DIR"
echo ""

# Shell
symlink zshrc          ~/.zshrc
symlink alias          ~/.alias
symlink ripgreprc      ~/.ripgreprc

# Git
symlink gitconfig      ~/.gitconfig

# Tmux
symlink tmux.conf      ~/.tmux.conf

# Neovim
symlink config/nvim    ~/.config/nvim

# Starship
symlink config/starship.toml ~/.config/starship.toml

# mise
symlink config/mise/config.toml ~/.config/mise/config.toml

# atuin
symlink config/atuin/config.toml ~/.config/atuin/config.toml

echo ""
echo "Done. Open a new terminal or run: source ~/.zshrc"
```

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x ~/personal/configuration/install.sh
cd ~/personal/configuration
git add install.sh
git commit -m "feat(install): add idempotent symlink installer"
```

---

## Task 15: Wire Everything Up

**Files:** none (symlinks + cleanup)

- [ ] **Step 1: Back up zprezto symlinks before removing them**

```bash
# List current zprezto symlinks
ls -la ~/.zlogin ~/.zlogout ~/.zprofile ~/.zpreztorc ~/.zshenv 2>/dev/null
```

Expected: all point to `~/.zprezto/runcoms/`.

- [ ] **Step 2: Remove zprezto runcoms symlinks**

```bash
rm -f ~/.zlogin ~/.zlogout ~/.zprofile ~/.zpreztorc ~/.zshenv
```

These are safe to remove — they're symlinks pointing to zprezto which we're no longer using.

- [ ] **Step 3: Run install.sh**

```bash
bash ~/personal/configuration/install.sh
```

Expected: each line shows either `Already linked` or `Linking: ... → ...`. No errors.

- [ ] **Step 4: Verify all symlinks are correct**

```bash
ls -la ~/.zshrc ~/.alias ~/.gitconfig ~/.tmux.conf ~/.ripgreprc
ls -la ~/.config/nvim ~/.config/starship.toml ~/.config/mise/config.toml ~/.config/atuin/config.toml
```

Expected: all are symlinks pointing into `~/personal/configuration/`.

- [ ] **Step 5: Open a fresh shell and test startup time**

```bash
time zsh -i -c exit
```

Expected: under 200ms total.

- [ ] **Step 6: Verify Starship prompt loads**

Open a new terminal tab (or `exec zsh`). You should see the Starship prompt (❯ character, git info in the prompt).

- [ ] **Step 7: Verify mise is active**

```bash
which python
which node
mise current
```

Expected:
```
~/.local/share/mise/shims/python
~/.local/share/mise/shims/node
python  3.10.0
node    22.19.0
```

- [ ] **Step 8: Verify atuin works**

Press `Ctrl-R` in the shell. Expected: atuin fuzzy history search opens (instead of standard `^R` reverse search).

- [ ] **Step 9: Open Neovim and install plugins**

```bash
nvim
```

On first open, lazy.nvim will auto-install all plugins. Wait for it to complete (progress shown in the lazy UI). Then run:

```
:checkhealth
```

Review output. Expected: no `ERROR` lines for LSP or treesitter sections.

- [ ] **Step 10: Verify LSP works in a Go file**

```bash
nvim ~/src/account/main.go 2>/dev/null || nvim ~/personal/configuration/config/mise/config.toml
```

In Neovim, check:
```
:LspInfo
```

Expected: shows `gopls` attached (for a .go file) or `lua_ls` (for a .lua file).

- [ ] **Step 11: Push final state to GitHub**

```bash
cd ~/personal/configuration
git push origin master
```

---

## Task 16: Clean Up Old Version Managers (Optional but Recommended)

**Files:** none

- [ ] **Step 1: Uninstall pyenv (after verifying mise has Python)**

```bash
mise current python  # confirm: python 3.10.0
brew uninstall pyenv
rm -rf ~/.pyenv
```

- [ ] **Step 2: Uninstall fnm (after verifying mise has Node)**

```bash
mise current node  # confirm: node 22.19.0
brew uninstall fnm
```

- [ ] **Step 3: Uninstall jenv (no Java was installed anyway)**

```bash
brew uninstall jenv
rm -rf ~/.jenv
```

- [ ] **Step 4: Verify nothing broke**

```bash
python --version   # should show 3.10.0 (via mise)
node --version     # should show v22.19.0 (via mise)
time zsh -i -c exit  # should still be under 200ms
```

---

## Verification Checklist

Run these after completing all tasks:

```bash
# Shell startup time
time zsh -i -c exit
# Target: < 200ms

# mise versions match originals
mise current

# Starship prompt active
echo $STARSHIP_SHELL

# atuin history (Ctrl-R should open atuin)
atuin history list | head -5

# Neovim version
nvim --version | head -1

# All dotfiles symlinked
readlink ~/.zshrc
readlink ~/.config/nvim
readlink ~/.config/starship.toml

# Git config additions present
git config commit.verbose
git config column.ui
git config init.defaultBranch

# tmux true color (run inside tmux)
tmux info | grep -i "Tc\|RGB\|color"

# Rollback available
cd ~/personal/configuration && git log --oneline -5
```
