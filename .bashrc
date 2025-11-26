#
# ~/.bashrc
#

export PATH="$HOME/.local/archi/bin:$PATH" # archi scripts

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


PS1="\[\e[35m\]\w\[\e[m\] \[\e[36m\]archlinux \[\e[m\] "

# ============== aliases ==============
# eza & zoxide
alias _ls="ls"                                                       # backup default ls
alias ls="eza -l  --icons=always --header --group-directories-first" # long listing
alias la="eza -la --icons=always --header --group-directories-first" # include hidden files
alias lt="eza -T --level=3 --git --icons=always"                     # tree view
alias _cd="cd"                                                       # backup default cd
alias cd='z'                                                         # replaces default cd
alias ..='z ..'                                                      # go up 1 directory
alias ...='z ../..'                                                  # go up 2 directories
alias ....='z ../../..'                                              # go up 3 directories
eval "$(zoxide init bash)"

# grep
alias grep='grep --color=auto'

# create_ap
alias ap='create_ap'

# zed code editor
alias zed='zeditor'

# ======= PATHs =======
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
