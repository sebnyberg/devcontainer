# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

## Bash settings

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# ignore case when using cd
bind 'set completion-ignore-case On'

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    if test -r $HOME/.dircolors ; then
        eval "$(dircolors -b $HOME/.dircolors)"
    else
        eval "$(dircolors -b)" 
    fi
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    red="\033[0;31m"
    yellow="\033[0;33m"
    green="\033[0;32m"
    ochre="\033[38;5;95m"
    blue="\033[0;34m"
    white="\033[0;37m"
    reset="\033[0m"
else
    red=""
    yellow=""
    green=""
    ochre=""
    blue=""
    white=""
    reset=""
fi

# Load Git prompt function (__git_ps1)
# See https://github.com/git/git/edit/master/contrib/completion/git-prompt.sh
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM=1
source $HOME/.git-prompt.sh

# Returns a prompt on the format:
# $context @ $cluster ($namespace)
function kube_info() {
    local current_context=$(kubectl config current-context)
    local cluster=$(kubectl config get-contexts | awk -v ctx="${current_context}" ' $2 ~ ctx { print $3 }')
    local namespace=$(kubectl config get-contexts | awk -v ctx="${current_context}" ' $2 ~ ctx { print $5 }')
    if [ -z "$namespace" ]; then
        namespace="default"
    fi

    local msg=""

    msg+="${red}${current_context}${reset}"
    msg+=" @ ${yellow}${cluster}${reset}"
    msg+=" (${blue}${namespace}${reset})"

    echo -e "$msg"
}

# Does a prompt on the format
# $usrcontext in $pwd ($git_prompt)
function prompt() {
    # __git_ps1 sets PS1 with the first argument as a prefix and second as a postfix
    if [ -f "$HOME/.kube/config" ] && kubectl config current-context &>/dev/null ; then
        echo -e '__git_ps1 "\$(kube_info) in ${green}\w${reset}" "\n\$ "'
    else
        echo -e '__git_ps1 "${red}\u${reset} @ ${yellow}\h${reset} in ${green}\w${reset}" "\n\$ "'
    fi
}
export PROMPT_COMMAND=$(prompt)

# connect to SSH socket
if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval `ssh-agent -s`
    ssh-add
fi
