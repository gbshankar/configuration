fpath=(/usr/local/share/zsh-completions $fpath)
source ${ZDOTDIR:-$HOME}/.zprezto/init.zsh
source ~/.alias

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh
source $HOME/Library/Python/3.7/bin

PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"


setopt auto_cd
cdpath=($HOME/src)

source '/Users/sgarikapati/src/awsaccess/awsaccess2.sh' # awsaccess
source '/Users/sgarikapati/src/awsaccess/oktaawsaccess.sh' # oktaawsaccess
export PS1="\$(ps1_mfa_context)$PS1" # awsaccess
PATH=$PATH:/Users/sgarikapati/.lyftkube-bin
