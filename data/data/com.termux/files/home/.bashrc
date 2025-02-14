# Enhanced history settings
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:ll:history:w:pwd:exit:clear"
HISTTIMEFORMAT="%F %T "

# Performance optimizations
set -o noclobber
shopt -s checkwinsize
shopt -s histappend

alias monitor='bash monitor.sh'
alias mem='free -h'
alias top='sudo htop'
alias exx='exit'

alias ic='ifconfig'
alias ifc='ip -c a'
alias rb='sudo reboot now'

# Quick system cleanup
alias cleanup='apt clean && apt autoclean && rm -rf ~/storage/downloads/*'

# Fast directory switching
alias h='cd ~'
alias w='cd ~/web'

# Package management shortcuts
alias update='pkg update && pkg dist-upgrade'

# Add some useful aliases
alias l='ls --color=auto'
alias ll='ls -la --color=auto'
alias ..='cd ..'

# Speed up cd navigation
alias cd..='cd ..'

# Clear screen shortcut
alias c='clear'

# Show system resources
alias res='neofetch'

# Improved system aliases
alias df='df -h'
alias du='du -h'
alias free='free -m'
alias ps='ps auxf'
alias ping='ping -c 5'
alias ports='netstat -tulanp'

# Network troubleshooting
alias ns='netstat -alnp --protocol=inet'

# Enhanced directory navigation
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Quick edit for common files
alias eb='$EDITOR ~/.bashrc'
alias sb='source ~/.bashrc'

# Disable flow control (Ctrl+S and Ctrl+Q)
stty -ixon

# Set vim as default editor
export EDITOR=vim

# Optimize readline settings
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'

# Speed up keyboard response
bind 'set show-all-if-unmodified on'
bind 'set skip-completed-text on'

# Better command line editing
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Custom PS1 prompt (minimal for better performance)
PS1='\[\e[0;32m\]\w\[\e[0m\] \$ '

# Advanced PS1 with git integration
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
PS1='\[\e[0;32m\]\w\[\e[91m\]$(parse_git_branch)\[\e[00m\] $ '

# Performance improvements
ulimit -S -c 0
set -o notify
