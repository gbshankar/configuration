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

PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"


setopt auto_cd
cdpath=($HOME/src $HOME/go/src/github.com/lyft $HOME/personal)

source '/Users/shankargarikapati/src/awsaccess/awsaccess2.sh' # awsaccess
source '/Users/shankargarikapati/src/awsaccess/oktaawsaccess.sh' # oktaawsaccess
#export PS1="\$(ps1_mfa_context)$PS1" # awsaccess
PATH=$HOME/bin:$PATH:/Users/shankargarikapati/.lyftkube-bin

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Add support for Go modules and Lyft's Athens module proxy/store
# These variables were added by 'hacktools/set_go_env_vars.sh'
export GOPROXY='https://athens.ingress.infra.us-east-1.k8s.lyft.net'
export GONOSUMDB='github.com/lyft/*,github.lyft.net/*'
export GO111MODULE='auto'

export FZF_DEFAULT_COMMAND='fd . $HOME'
export FZF_DEFAULT_OPTS='-m --height 50% --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd -t d . $HOME"
