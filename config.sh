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
ensure_pkg curl

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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/.zshrc" ]; then
    cp "$SCRIPT_DIR/.zshrc" ~/.zshrc
    echo "[+] .zshrc copied from script directory."
else
    echo "[!] .zshrc not found in script directory, downloading from GitHub..."
    curl -fsSL -o ~/.zshrc "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/.zshrc"
    if [ -f ~/.zshrc ]; then
        echo "[+] .zshrc downloaded successfully."
    else
        echo "[!] Failed to download .zshrc. Please check your internet connection or repository URL."
        exit 1
    fi
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

if ! grep -q "exec zsh -l" ~/.bashrc; then
    echo "exec zsh -l" >> ~/.bashrc
    echo "[+] Zsh will now load automatically when you restart Termux."
fi

echo "[*] Setup complete. Restart Termux or run 'exec zsh'."