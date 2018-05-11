# exports
export ZSH=$HOME/.oh-my-zsh
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR=vim

# settings
ZSH_THEME="frisk"
plugins=(git colored-man-pages colorize github virtualenv pip python zsh-syntax-highlighting)
zstyle ':completion:*' special-dirs true

# source files
source $ZSH/oh-my-zsh.sh
source ~/.aliases
