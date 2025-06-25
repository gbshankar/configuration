if type brew &>/dev/null; then
      FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

        autoload -Uz compinit
          compinit
fi
fpath=(/usr/local/share/zsh-completions $fpath)
source ${ZDOTDIR:-$HOME}/.zprezto/init.zsh
source ~/.alias


zstyle ':completion:*' accept-exact '*(N)'

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
#source /usr/local/bin/virtualenvwrapper.sh
#source $HOME/Library/Python/3.7/bin



setopt autocd
cdpath=($HOME/src $HOME/go/src/github.com/lyft $HOME/personal)


test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Add support for Go modules and Lyft's Athens module proxy/store
# These variables were added by 'hacktools/set_go_env_vars.sh'
export GOPATH='/Users/sgarikapati/go'
export GOPROXY='http://athens.ingress.infra-prd.us-east-1.k8s.lyft.net,direct'
export GONOSUMDB='github.com/lyft/*,github.lyft.net/*'
export GONOSUM='github.com/lyft/*,github.lyft.net/*'
export GO111MODULE='auto'

export FZF_DEFAULT_COMMAND='fd . $HOME'
export FZF_DEFAULT_OPTS='-m --height 50% --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd -t d . $HOME"

#eval "$(/opt/lyft/brew/bin/aactivator init)"
export PATH="/opt/homebrew/sbin:/Users/sgarikapati/.rd/bin:$GOPATH/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
### lyft_localdevtools_shell_rc start
### DO NOT REMOVE: automatically installed as part of Lyft local dev tool setup
if [[ -f "/opt/homebrew/Library/Taps/lyft/homebrew-localdevtools/scripts/shell_rc.sh" ]]; then
    source "/opt/homebrew/Library/Taps/lyft/homebrew-localdevtools/scripts/shell_rc.sh"
fi
### lyft_localdevtools_shell_rc end

### lyft_rd_shell_rc start
### DO NOT REMOVE: automatically installed as part of Rancher Desktop setup
if [[ -f /Users/sgarikapati/.rd/shell_rc.sh ]]; then
  source /Users/sgarikapati/.rd/shell_rc.sh
fi
### lyft_rd_shell_rc end
eval export PATH="/Users/sgarikapati/.jenv/shims:${PATH}"
export JENV_SHELL=zsh
export JENV_LOADED=1
#npm config set registry https://artifactory.lyft.net/artifactory/api/npm/virtual-npm-lyft/

### DO NOT REMOVE: automatically installed as part of Lyft local dev tool setup
eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
alias ack="echo 'use rg'"
#alias python=python3

#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.local/bin/env"
export GOPATH=/Users/sgarikapati/go
export PATH=$GOPATH/bin:$PATH
export HOMEBREW_NO_AUTO_UPDATE=1
