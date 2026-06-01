#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "[*] Starting Termux Kali-style setup..."

cd ~

ensure_pkg() {
    if ! dpkg -s "$1" &>/dev/null; then
        echo "[+] Installing $1..."
        pkg install -y "$1"
    else
        echo "[i] $1 is already installed."
    fi
}

pkg update -y

ensure_pkg zsh
ensure_pkg git
ensure_pkg which

mkdir -p ~/.zsh

if [ ! -d ~/.zsh/zsh-autosuggestions ]; then
    echo "[+] Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
else
    echo "[i] zsh-autosuggestions already present."
fi

if [ ! -d ~/.zsh/zsh-syntax-highlighting ]; then
    echo "[+] Cloning zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
else
    echo "[i] zsh-syntax-highlighting already present."
fi

if [ ! -d ~/.zsh/zsh-autocomplete ]; then
    echo "[+] Cloning zsh-autocomplete..."
    git clone https://github.com/marlonrichert/zsh-autocomplete.git ~/.zsh/zsh-autocomplete
else
    echo "[i] zsh-autocomplete already present."
fi

cat > ~/.zshrc << 'EOF'
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

_last_exit_code=0
_first_prompt=1
precmd() {
    _last_exit_code=$?

    if (( _first_prompt )); then
        printf '\033[2J\033[H'
        _first_prompt=0
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
EOF

touch ~/.hushlogin

if [ -f ~/.zsh_config ]; then
    source ~/.zsh_config
    echo "[*] Current username: $USER_NAME"
    read -rp "[?] Change username? (y/n): " ganti
    if [[ "$ganti" == "y" ]]; then
        read -rp "[+] Enter new username: " new_name
        echo "USER_NAME=$new_name" > ~/.zsh_config
        echo "[+] Username updated."
    else
        echo "[i] Keeping existing username."
    fi
else
    read -rp "[+] Enter your terminal username: " user_name
    echo "USER_NAME=$user_name" > ~/.zsh_config
    echo "[+] Username saved."
fi

if [ "$SHELL" != "$(which zsh)" ]; then
    echo "[+] Changing default shell to zsh..."
    chsh -s zsh
else
    echo "[i] Default shell is already zsh."
fi

if ! grep -q "exec zsh -l" ~/.bashrc; then
    echo "exec zsh -l" >> ~/.bashrc
    echo "[+] Zsh will now load automatically when you restart Termux."
fi

echo "[*] Setup complete. Restart Termux or run 'exec zsh'."