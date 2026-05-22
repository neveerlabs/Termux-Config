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
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=magenta'

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
        env_part="%F{magenta}[$(basename $VIRTUAL_ENV)]%f "
    fi

    local path_part=""
    if [[ $PWD == "/" ]]; then
        path_part="/"
    elif [[ $PWD != $HOME ]]; then
        local abspath="$PWD"
        if (( ${#abspath} > 30 )); then
            path_part="/•••/${abspath##*/}/"
        else
            path_part="${abspath}/"
        fi
    fi

    local base_prompt="%F{green}Termux%f%F{white}@%f%F{blue}terminal%f"
    if [[ -n $path_part ]]; then
        base_prompt+=" %F{cyan}${path_part}%f"
    fi
    base_prompt+=" %F{yellow}$%f "

    PROMPT="${env_part}${base_prompt}"
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