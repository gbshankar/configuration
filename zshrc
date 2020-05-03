if type brew &>/dev/null; then
      FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

        autoload -Uz compinit
          compinit
fi
fpath=(/usr/local/share/zsh-completions $fpath)
source ${ZDOTDIR:-$HOME}/.zprezto/init.zsh
source ~/.alias

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
#source /usr/local/bin/virtualenvwrapper.sh
#source $HOME/Library/Python/3.7/bin

PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"


setopt auto_cd
cdpath=($HOME/src $HOME/go/src/github.com/lyft)

source '/Users/shankargarikapati/src/awsaccess/awsaccess2.sh' # awsaccess
source '/Users/shankargarikapati/src/awsaccess/oktaawsaccess.sh' # oktaawsaccess
#export PS1="\$(ps1_mfa_context)$PS1" # awsaccess
PATH=$HOME/bin:$PATH:/Users/shankargarikapati/.lyftkube-bin

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
