# Dotfiles Overhaul Design

**Date:** 2026-04-23  
**Author:** Bhavani Shankar Garikapati  
**Repo:** https://github.com/gbshankar/configuration  
**Approach:** Big Bang — full rewrite on a new branch, push current state first as safety baseline

---

## Context

macOS (Apple Silicon, arm64), iTerm2, primary workflow: backend/infrastructure engineering (Python, Go, Kubernetes).

Current pain points:
- Shell startup slow (~600ms+): duplicate `compinit`, three separate version manager `eval`s at load time
- zprezto framework overhead with unused modules
- vim + Vundle: no LSP, no Treesitter, slow plugin ecosystem
- Three version managers (pyenv, jenv, fnm) adding startup latency
- atuin installed but not wired into shell
- zsh-autosuggestions missing
- PATH has duplicate entries
- tmux using wrong TERM (`xterm-256color` instead of `tmux-256color`)

---

## Section 1: Safety Baseline + Repo Structure

### Safety First
Before any changes:
1. Sync current live dotfiles (`~/.zshrc`, `~/.alias`, `~/.gitconfig`, `~/.tmux.conf`, `~/.vimrc`) into the repo
2. Commit as `snapshot: current dotfiles before overhaul`
3. Push to `origin/master` — rollback is a single `git checkout`

### New Repo Layout

```
~/personal/configuration/
├── zshrc
├── alias
├── gitconfig
├── tmux.conf
├── ripgreprc
├── Brewfile
├── install.sh              ← creates symlinks from ~/ to repo files
├── config/
│   ├── nvim/
│   │   ├── init.lua
│   │   └── lua/
│   │       └── plugins/
│   │           ├── lsp.lua
│   │           ├── treesitter.lua
│   │           ├── telescope.lua
│   │           ├── completion.lua
│   │           ├── formatting.lua
│   │           ├── git.lua
│   │           ├── ui.lua
│   │           └── editor.lua
│   ├── starship.toml
│   ├── mise/
│   │   └── config.toml
│   └── atuin/
│       └── config.toml
└── docs/
    └── superpowers/
        └── specs/
            └── 2026-04-23-dotfiles-overhaul-design.md
```

### install.sh
Before creating each symlink, backs up any existing file to `<file>.bak` (e.g. `~/.zshrc.bak`). Idempotent — safe to re-run; skips if symlink already correct. Creates symlinks:
- `~/.zshrc` → `configuration/zshrc`
- `~/.alias` → `configuration/alias`
- `~/.gitconfig` → `configuration/gitconfig`
- `~/.tmux.conf` → `configuration/tmux.conf`
- `~/.ripgreprc` → `configuration/ripgreprc`
- `~/.config/nvim` → `configuration/config/nvim`
- `~/.config/starship.toml` → `configuration/config/starship.toml`
- `~/.config/mise/config.toml` → `configuration/config/mise/config.toml`
- `~/.config/atuin/config.toml` → `configuration/config/atuin/config.toml`

---

## Section 2: Shell — Starship + Minimal zsh

### Removed
- zprezto framework (all symlinked runcoms: `.zlogin`, `.zlogout`, `.zprofile`, `.zpreztorc`, `.zshenv`)
- Duplicate `compinit` call
- pyenv, jenv, fnm (replaced by mise)
- Commented-out dead code (virtualenvwrapper, nvm blocks)
- Duplicate `/opt/homebrew/sbin` in PATH

### .zshrc Structure

```zsh
# 1. Homebrew (cached prefix, not re-evaluated every shell)
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_NO_AUTO_UPDATE=1

# 2. PATH — set once, no duplicates
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$HOME/.local/bin:$HOME/.antigravity/antigravity/bin:$HOME/.rd/bin:$PATH"

# 3. compinit with cache (only regenerate if >24h old)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi

# 4. zsh options
setopt autocd extended_glob hist_ignore_dups hist_ignore_space share_history

# 5. cdpath
cdpath=($HOME/src $HOME/personal)

# 6. Completion style
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zcompcache

# 7. mise (single version manager for Python, Node, Go, Java)
eval "$(mise activate zsh)"

# 8. atuin (searchable shell history, replaces Ctrl-R)
eval "$(atuin init zsh)"

# 9. fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='-m --height 50% --border'
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# 10. Go
export GOPATH="$HOME/go"
export GOPROXY='http://athens.ingress.infra-prd.us-east-1.k8s.lyft.net,direct'
export GONOSUMDB='github.com/lyft/*,github.lyft.net/*'
export PATH="$GOPATH/bin:$PATH"

# 11. Plugins
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# 12. Lyft tooling (preserved, clearly marked)
[[ -f "/opt/homebrew/Library/Taps/lyft/homebrew-localdevtools/scripts/shell_rc.sh" ]] && \
  source "/opt/homebrew/Library/Taps/lyft/homebrew-localdevtools/scripts/shell_rc.sh"
[[ -f "$HOME/.rd/shell_rc.sh" ]] && source "$HOME/.rd/shell_rc.sh"

# 13. Aliases
source ~/.alias

# 14. iTerm2 integration
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

# 15. Starship prompt (last)
eval "$(starship init zsh)"
```

### Startup Target
Under 200ms (from ~600ms+). Key wins: cached compinit, mise replaces 3 separate evals, no framework overhead.

---

## Section 3: Neovim — lazy.nvim + LSP + Treesitter

### Config Entry Point: `~/.config/nvim/init.lua`

Bootstrap `lazy.nvim`, then load plugin specs from `lua/plugins/`.

### Plugin Manifest

| File | Plugins | Purpose |
|------|---------|---------|
| `plugins/lsp.lua` | `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig.nvim` | LSP install + config |
| `plugins/treesitter.lua` | `nvim-treesitter` | Syntax, folding, highlights |
| `plugins/completion.lua` | `nvim-cmp`, `cmp-nvim-lsp`, `LuaSnip`, `cmp_luasnip` | Completion |
| `plugins/telescope.lua` | `telescope.nvim`, `telescope-fzf-native.nvim` | Fuzzy find files/grep/buffers |
| `plugins/formatting.lua` | `conform.nvim` | Format on save (gopls, ruff, prettier) |
| `plugins/git.lua` | `gitsigns.nvim`, `vim-fugitive` | Inline blame/diff + Git commands |
| `plugins/ui.lua` | `lualine.nvim`, `which-key.nvim`, `nvim-web-devicons` | Status line, key hints, icons |
| `plugins/editor.lua` | `oil.nvim`, `mini.surround`, `mini.comment` | File explorer, surround, commenting |

### LSP Servers (auto-installed via mason)
- `gopls` — Go
- `pyright` + `ruff` — Python (pyright for types, ruff for lint/format)
- `lua_ls` — Lua (for editing Neovim config itself)
- `terraformls` — Terraform/HCL
- `yamlls` — Kubernetes manifests, CI configs
- `dockerls` — Dockerfile

### Keybinding Philosophy
- Preserve existing muscle memory: `,` leader, `Space` clears search
- LSP bindings under `<leader>l`: `<leader>ld` (definition), `<leader>lr` (references), `<leader>lrn` (rename), `<leader>la` (code action)
- Telescope: `<leader>ff` (files), `<leader>fg` (grep), `<leader>fb` (buffers)
- Oil: `-` opens file explorer in current dir (oil.nvim default)

### Replaced
- Vundle → lazy.nvim
- syntastic + flake8 → nvim-lspconfig (pyright + ruff)
- yapf → conform.nvim (ruff format)
- vim-go (partial) → gopls via lspconfig + conform for gofmt/goimports
- fzf.vim → telescope.nvim

---

## Section 4: tmux — Modernized

### Changes

| Before | After | Why |
|--------|-------|-----|
| `default-terminal "xterm-256color"` | `default-terminal "tmux-256color"` | Proper terminfo for true color + italics in Neovim |
| `set -ga terminal-overrides` | `set -as terminal-features ",xterm-256color:RGB"` | Cleaner true color passthrough |
| `battery_percentage` script | `tmux-battery` TPM plugin | Reliable on Apple Silicon |
| `history-limit 10000` | `history-limit 50000` | Cheap to increase |

### Additions
- `tmux-sessionizer`: `<prefix>f` — a small shell script (`~/.local/bin/tmux-sessionizer`) that uses fzf to list `~/src` and `~/personal` dirs; selects one, derives a session name from the directory name, and either switches to the existing session or creates a new one with that path as cwd. Not a TPM plugin — just a script bound via `bind-key -r f run-shell "tmux-sessionizer"`.
- `<prefix>e`: open `~/.tmux.conf` in Neovim for quick edits
- Nerdfont-aware status bar with cleaner icons

### Preserved
All existing keybindings: vim-style resize, vi copy-mode, cwd retention on splits, mouse mode, TPM, resurrect, continuum.

---

## Section 5: Git Config — Minor Additions

Current config is well-tuned. Small additions only:

```ini
[commit]
    verbose = true          # show full diff in commit message editor

[column]
    ui = auto               # columnar output for branch/tag/status

[init]
    defaultBranch = main    # no more master on new repos
```

**Removed:** `core.compression = -1` (currently disables compression — wastes bandwidth on clones).

Everything else (delta, histogram, rerere, autosquash, fetch.parallel) stays as-is.

---

## Section 6: Brewfile — Updated

### Removed
- `nvm` (replaced by mise)

### Added
```ruby
brew "neovim"
brew "mise"
brew "starship"
brew "zsh-autosuggestions"   # currently missing
brew "atuin"                  # already installed, add to Brewfile
```

### Kept
`fzf`, `fd`, `ripgrep`, `delta`, `tmux`, `gh`, `zsh-syntax-highlighting`, all Lyft tooling.

---

## Implementation Order

1. **Safety**: Sync + push current state to GitHub
2. **Shell**: New `.zshrc` + install starship, mise, zsh-autosuggestions
3. **Version managers**: Migrate pyenv/jenv/fnm → mise, set up `~/.config/mise/config.toml`
4. **Neovim**: Install neovim, write config from scratch
5. **tmux**: Update `.tmux.conf`, install new TPM plugins
6. **Git**: Apply minor gitconfig additions
7. **Brewfile**: Sync to current state
8. **install.sh**: Write symlink script, wire everything up

---

## Success Criteria

- Shell startup < 200ms (`time zsh -i -c exit`)
- LSP working in Neovim for Go and Python (hover, go-to-definition, format on save)
- `tmux-sessionizer` replaces manual session creation
- atuin history search working in shell
- All dotfiles symlinked from `~/personal/configuration` — no more manual copy/paste to update
- `install.sh` idempotent — safe to re-run
