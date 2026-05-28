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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/.zshrc"
DEST="$HOME/.zshrc"

if [ -f "$SRC" ]; then
    if [ "$(realpath "$SRC" 2>/dev/null || echo "$SRC")" != "$(realpath "$DEST" 2>/dev/null || echo "$DEST")" ]; then
        cp "$SRC" "$DEST"
        echo "[+] .zshrc deployed."
    else
        echo "[i] Source and destination are the same file, skipping copy."
    fi
else
    echo "[!] .zshrc not found in script directory, skipping copy."
fi

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

echo "[*] Setup complete. Restart Termux or run 'zsh'."
