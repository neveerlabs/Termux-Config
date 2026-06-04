HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt NO_NOTIFY

autoload -Uz compinit
compinit

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

source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' history-search yes
zstyle ':autocomplete:*' insert-unambiguous no
zstyle ':autocomplete:*' list-lines 16
zstyle ':autocomplete:*' autosuggest no
zstyle ':autocomplete:*' recent-dirs-insert always
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
bindkey -M autocomplete '^[[C' undefined-key
bindkey -M autocomplete '^[[C' _accept_suggestion_or_forward_char
bindkey -M autocomplete '^F' autosuggest-accept

alias ls='ls --color=auto'
export LS_COLORS='di=36:fi=37:ln=36:ex=32:or=31:mi=31'

[ -f ~/.zsh_config ] && source ~/.zsh_config
if [ -z "$USER_NAME" ]; then
    USER_NAME="user"
fi

if ! pgrep -x "mariadbd" > /dev/null; then
    termux-wake-lock 2>/dev/null
    mariadbd-safe &>/dev/null &!
fi

if [[ -z "$_TERMUX_WELCOME_SHOWN" ]]; then
    printf 'Welcome to Termux!\n\n'
    export _TERMUX_WELCOME_SHOWN=1
fi

TERMUX_CONFIG_DIR="$HOME/Termux-Config"
_update_check_done=0

_check_for_updates() {
    if [[ $_update_check_done -eq 1 ]]; then
        return
    fi
    _update_check_done=1

    if [[ ! -d "$TERMUX_CONFIG_DIR" ]]; then
        return
    fi

    local local_version=""
    if [[ -f "$TERMUX_CONFIG_DIR/version.txt" ]]; then
        local_version=$(<"$TERMUX_CONFIG_DIR/version.txt")
    fi

    local remote_version=""
    remote_version=$(curl -fsSL --max-time 5 "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/version.txt" 2>/dev/null)
    if [[ -z "$remote_version" ]]; then
        return
    fi

    if [[ "$local_version" != "$remote_version" ]]; then
        printf '\n'
        printf '╔══════════════════════════════════════════╗\n'
        printf '║  Update available!                      ║\n'
        printf '╠══════════════════════════════════════════╣\n'
        printf '║  Current version: %-23s║\n' "$local_version"
        printf '║  New version:     %-23s║\n' "$remote_version"
        printf '╚══════════════════════════════════════════╝\n'
        printf '\n'
        if [[ -f "$TERMUX_CONFIG_DIR/Changelog.md" ]]; then
            printf 'Changelog:\n'
            cat "$TERMUX_CONFIG_DIR/Changelog.md"
            printf '\n'
        else
            local changelog_content
            changelog_content=$(curl -fsSL --max-time 5 "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/Changelog.md" 2>/dev/null)
            if [[ -n "$changelog_content" ]]; then
                printf 'Changelog:\n%s\n\n' "$changelog_content"
            fi
        fi

        printf 'Do you want to update? (y/n): '
        read -rk1 ans
        printf '\n'
        if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
            printf 'Updating...\n'
            if git -C "$TERMUX_CONFIG_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
                git -C "$TERMUX_CONFIG_DIR" pull --ff-only
            else
                curl -fsSL -o "$TERMUX_CONFIG_DIR/.zshrc" "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/.zshrc"
                curl -fsSL -o "$TERMUX_CONFIG_DIR/version.txt" "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/version.txt"
                curl -fsSL -o "$TERMUX_CONFIG_DIR/Changelog.md" "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/Changelog.md"
                curl -fsSL -o "$TERMUX_CONFIG_DIR/README.md" "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/README.md"
            fi
            if [[ -f "$TERMUX_CONFIG_DIR/.zshrc" ]]; then
                cp "$TERMUX_CONFIG_DIR/.zshrc" ~/.zshrc
            fi
            printf 'Update complete. Restart Termux to apply changes.\n'
        fi
    fi
}

_last_exit_code=0
_first_prompt=1
precmd() {
    _last_exit_code=$?

    if (( _first_prompt )); then
        printf '\033[2J\033[H'
        _first_prompt=0
        _check_for_updates
    fi

    printf '\e[2 q'
    printf '\e]12;white\a'

    local env_part=""
    if [[ -n $VIRTUAL_ENV ]]; then
        env_part="%F{green}($(basename $VIRTUAL_ENV))%f│"
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
            display_path="~/⋯/${PWD##*/}"
        else
            display_path="/⋯/${PWD##*/}"
        fi
    fi

    local green="%F{green}"
    local cyan="%F{cyan}"
    local white="%F{white}"
    local reset="%f"

    PROMPT="${green}┌───${reset}${env_part}${green}(${reset}${cyan}${USER_NAME}㉿kali${reset}${green})-[${reset}${white}${display_path}${reset}${green}]${reset}
${green}└──${white}\$${reset} "
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