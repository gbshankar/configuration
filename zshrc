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
