#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='\[\e[35m\]\u@\h\[\e[m\] \[\e[34m\]\w\[\e[m\] '

# ============== history ==============
shopt -s histappend
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoreboth
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# fzf stuff
source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash

# ============== aliases ==============
# eza & zoxide
alias _ls="command ls"                                                       # backup default ls
alias ls="eza -l  --icons=always --header --group-directories-first" # long listing
alias la="eza -la --icons=always --header --group-directories-first" # include hidden files
alias lt="eza -T --level=3 --git --icons=always"                     # tree view
alias _cd="command cd"                                                       # backup default cd
alias cd='z'                                                         # replaces default cd
alias ..='z ..'                                                      # go up 1 directory
alias ...='z ../..'                                                  # go up 2 directories
alias ....='z ../../..'                                              # go up 3 directories
# eval "$(zoxide init bash)"
_zoxide_cache="$HOME/.cache/zoxide_init.sh"
if [[ ! -f "$_zoxide_cache" ]]; then
    zoxide init bash > "$_zoxide_cache"
fi
source "$_zoxide_cache"

# grep
alias grep='grep --color=auto'

# trash-cli & rm
alias trash='trash-put'
alias rm='rm -Iv'

# zed code editor
alias zed='zeditor'

# get used ports
alias ports='ss -tulpn'

# ======= PATHs =======
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# ======= conda initialize =======
conda() {
  unset -f conda
  source /opt/miniforge/etc/profile.d/conda.sh
  conda "$@"
}

# ======= extras =======

# OpenClaw Completion
source "$HOME/.openclaw/completions/openclaw.bash"

# thefuck
_thefuck_cache="$HOME/.cache/thefuck_init.sh"
if [[ ! -f "$_thefuck_cache" ]]; then
    thefuck --alias > "$_thefuck_cache"
fi
source "$_thefuck_cache"
