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

TERMUX_CONFIG_VERSION="v3.2.1"

[ -f ~/.zsh_config ] && source ~/.zsh_config
if [ -z "$USER_NAME" ]; then
    USER_NAME="user"
fi

if ! pgrep -x "mysqld" > /dev/null && ! pgrep -x "mariadbd" > /dev/null; then
    termux-wake-lock 2>/dev/null
    mysqld --log-error=/dev/null --general-log=0 --slow-query-log=0 --pid-file=$PREFIX/var/lib/mysql/$(hostname).pid &>/dev/null &!
fi

if [[ -z "$_TERMUX_WELCOME_SHOWN" ]]; then
    printf 'Welcome to Termux!\n\n'
    export _TERMUX_WELCOME_SHOWN=1
fi

TERMUX_CONFIG_DIR="$HOME/Termux-Config"
_update_check_done=0

_download_with_progress() {
    local url="$1"
    local dest="$2"
    local filename=$(basename "$dest")
    printf 'Updating %s ... ' "$filename"
    if curl -# -L -o "$dest" "$url" 2>&1; then
        printf 'Done\n'
        return 0
    else
        printf 'Failed\n'
        return 1
    fi
}

_get_remote_version() {
    local remote_zshrc
    remote_zshrc=$(curl -fsSL --max-time 10 "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/.zshrc" 2>/dev/null)
    if [[ -z "$remote_zshrc" ]]; then
        return 1
    fi
    local ver
    ver=$(echo "$remote_zshrc" | grep -o 'TERMUX_CONFIG_VERSION="[^"]*"' | head -1 | grep -o '"[^"]*"' | tr -d '"')
    if [[ -z "$ver" ]]; then
        return 1
    fi
    echo "$ver"
    return 0
}

_version_parse() {
    python3 -c "import sys; v=sys.argv[1].lstrip('v'); print('.'.join(str(int(x)) for x in v.split('.')))" "$1" 2>/dev/null || echo "0.0.0"
}

_version_greater_equal() {
    local v1=$(_version_parse "$1")
    local v2=$(_version_parse "$2")
    python3 -c "
import sys
v1 = tuple(map(int, sys.argv[1].split('.')))
v2 = tuple(map(int, sys.argv[2].split('.')))
sys.exit(0 if v1 >= v2 else 1)
" "$v1" "$v2" 2>/dev/null
    return $?
}

_show_changelog_since() {
    local since_version="$1"
    local changelog_url="https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/Changelog.json"
    local changelog_json
    changelog_json=$(curl -fsSL --max-time 10 "$changelog_url" 2>/dev/null)
    if [[ -z "$changelog_json" ]]; then
        printf 'Changelog not available.\n'
        return
    fi
    python3 -c "
import json, sys
entries = json.loads(sys.stdin.read())
since = sys.argv[1]
def parse(v):
    return tuple(map(int, v.lstrip('v').split('.')))
target = parse(since)
relevant = [e for e in entries if parse(e['version']) > target]
if not relevant:
    print('No recent changes.')
else:
    for e in relevant:
        print(f\"Version {e['version']}:\n{e['changes']}\n\")
" "$since_version" <<< "$changelog_json" 2>/dev/null || printf 'Failed to parse changelog.\n'
}

_perform_update() {
    local base_url="https://raw.githubusercontent.com/neveerlabs/Termux-Config/main"
    local update_failed=0
    mkdir -p "$TERMUX_CONFIG_DIR"
    _download_with_progress "$base_url/.zshrc" "$HOME/.zshrc.tmp" || update_failed=1
    if [[ $update_failed -eq 0 ]]; then
        mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"
        cp "$HOME/.zshrc" "$TERMUX_CONFIG_DIR/.zshrc"
    fi
    _download_with_progress "$base_url/Changelog.json" "$TERMUX_CONFIG_DIR/Changelog.json" || true
    _download_with_progress "$base_url/README.md" "$TERMUX_CONFIG_DIR/README.md" || true
    _download_with_progress "$base_url/config.sh" "$TERMUX_CONFIG_DIR/config.sh" || true
    if [[ $update_failed -eq 0 ]]; then
        printf '\nUpdate complete. Restart Termux to apply changes.\n'
    else
        printf '\nUpdate finished with errors. Some files may not have been updated.\n'
    fi
}

_scan_updates_output() {
    local remote_version
    remote_version=$(_get_remote_version)
    if [[ -z "$remote_version" ]]; then
        printf 'Unable to check remote version. Check your internet connection.\n'
        return 1
    fi
    printf 'Local version:  %s\n' "$TERMUX_CONFIG_VERSION"
    printf 'Remote version: %s\n' "$remote_version"
    if [[ "$TERMUX_CONFIG_VERSION" != "$remote_version" ]]; then
        if _version_greater_equal "$remote_version" "$TERMUX_CONFIG_VERSION"; then
            printf '\nUpdate available.\n\n'
            _show_changelog_since "$TERMUX_CONFIG_VERSION"
        else
            printf '\nLocal version is newer than remote. You may have a pre-release.\n'
        fi
    else
        printf 'Already up to date.\n'
    fi
    return 0
}

_check_for_updates() {
    if [[ $_update_check_done -eq 1 ]]; then
        return
    fi
    _update_check_done=1

    if [[ ! -d "$TERMUX_CONFIG_DIR" ]]; then
        mkdir -p "$TERMUX_CONFIG_DIR"
    fi

    local remote_version
    remote_version=$(_get_remote_version)
    if [[ -z "$remote_version" ]]; then
        return
    fi

    if [[ "$TERMUX_CONFIG_VERSION" != "$remote_version" ]]; then
        if _version_greater_equal "$remote_version" "$TERMUX_CONFIG_VERSION"; then
            printf '\n'
            printf '╔══════════════════════════════════════════╗\n'
            printf '║  Update available!                      ║\n'
            printf '╠══════════════════════════════════════════╣\n'
            printf '║  Current version: %-23s║\n' "$TERMUX_CONFIG_VERSION"
            printf '║  New version:     %-23s║\n' "$remote_version"
            printf '╚══════════════════════════════════════════╝\n'
            printf '\n'
            _show_changelog_since "$TERMUX_CONFIG_VERSION"
            printf 'Do you want to update? (y/n): '
            read -rk1 ans
            printf '\n'
            if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
                _perform_update
            fi
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

    PROMPT="${green}┌───${reset}${env_part}${green}(${reset}${cyan}${USER_NAME}㉿termux${reset}${green})-[${reset}${white}${display_path}${reset}${green}]${reset}
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

command_not_found_handler() {
    if [[ "$1" == "--help" ]]; then
        printf '%s\n' "Available custom commands:"
        printf '%s\n' "  --help          Show this help message"
        printf '%s\n' "  --version       Show script version"
        printf '%s\n' "  --updates scan  Check for updates"
        printf '%s\n' "  --update        Update configuration files"
        return 0
    fi
    if [[ "$1" == "--version" ]]; then
        printf '%s\n' "$TERMUX_CONFIG_VERSION"
        return 0
    fi
    if [[ "$1" == "--updates" && "$2" == "scan" ]]; then
        _scan_updates_output
        return 0
    fi
    if [[ "$1" == "--update" ]]; then
        _perform_update
        return 0
    fi
    printf 'zsh: command not found: %s\n' "$1"
    return 127
}