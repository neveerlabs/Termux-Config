HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555"
ZSH_AUTOSUGGEST_STRATEGY=(history)

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_STYLES[default]='fg=white'
ZSH_HIGHLIGHT_STYLES[command]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[path]='fg=white,bold'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=white'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=magenta'

alias ls='ls --color=auto'
export LS_COLORS='di=36:fi=37:ln=36:ex=32:or=31:mi=31'

[ -f ~/.zsh_config ] && source ~/.zsh_config
if [ -z "$USER_NAME" ]; then
    USER_NAME="user"
fi

if [[ -z "$_TERMUX_WELCOME_SHOWN" ]]; then
    printf 'Welcome to Termux!\n\n'
    export _TERMUX_WELCOME_SHOWN=1
fi

_last_exit_code=0
precmd() {
    _last_exit_code=$?
    printf '\e[2 q'

    local env_part=""
    if [[ -n $VIRTUAL_ENV ]]; then
        env_part="%F{green}($(basename $VIRTUAL_ENV))%f─"
    fi

    local display_path
    if [[ $PWD == $HOME ]]; then
        display_path="~"
    elif [[ $PWD == $HOME/* ]]; then
        display_path="~/${PWD#$HOME/}"
    else
        display_path="$PWD"
    fi

    if (( ${#display_path} > 30 )); then
        if [[ $PWD == $HOME || $PWD == $HOME/* ]]; then
            display_path="~/···/${PWD##*/}"
        else
            display_path="/···/${PWD##*/}"
        fi
    fi

    local green="%F{green}"
    local cyan="%F{cyan}"
    local white="%F{white}"
    local reset="%f"

    PROMPT="${green}┌──${reset}${env_part}${green}(${reset}${cyan}${USER_NAME}㉿kali${reset}${green})-[${reset}${white}${display_path}${reset}${green}]${reset}
${green}└─${white}\$${reset} "
}

zshaddhistory() {
    [[ $_last_exit_code -eq 0 ]] && return 0 || return 1
}

function _accept_suggestion_or_forward_char() {
    if [[ -n $POSTDISPLAY ]] && [[ $CURSOR -eq ${#BUFFER} ]]; then
        zle autosuggest-accept
    else
        zle forward-char
    fi
}
zle -N _accept_suggestion_or_forward_char
bindkey '^[[C' _accept_suggestion_or_forward_char
bindkey '^F' autosuggest-accept
bindkey '^[[1;3C' forward-word
