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
ensure_pkg python
ensure_pkg nodejs
ensure_pkg termux-api
ensure_pkg bc
ensure_pkg sox
ensure_pkg mpv

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
    curl -fsSL -o ~/.zshrc "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/.zshrc" 2>/dev/null || {
        echo "[!] Failed to download .zshrc. Please check your internet connection or repository URL."
        exit 1
    }
    if [ -f ~/.zshrc ]; then
        echo "[+] .zshrc downloaded successfully."
    else
        echo "[!] Failed to download .zshrc."
        exit 1
    fi
fi

mkdir -p ~/.termux/praytimes

if [ -f "$SCRIPT_DIR/PrayTimes.js" ]; then
    cp "$SCRIPT_DIR/PrayTimes.js" ~/.termux/praytimes/PrayTimes.js
    echo "[+] PrayTimes.js copied from script directory."
else
    echo "[!] PrayTimes.js not found in script directory, downloading from GitHub..."
    curl -fsSL -o ~/.termux/praytimes/PrayTimes.js "https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/PrayTimes.js" 2>/dev/null || {
        echo "[!] Failed to download PrayTimes.js. Please check your internet connection or repository URL."
        exit 1
    }
    if [ -f ~/.termux/praytimes/PrayTimes.js ]; then
        echo "[+] PrayTimes.js downloaded successfully."
    else
        echo "[!] Failed to download PrayTimes.js."
        exit 1
    fi
fi

VENV_PATH="$HOME/venv"
VENV_CREATED=false
if [ ! -d "$VENV_PATH" ]; then
    echo "[*] Python virtual environment not found. Creating..."
    python3 -m venv "$VENV_PATH" || {
        echo "[!] Failed to create virtual environment. Trying to install python3-venv..."
        pkg install -y python
        python3 -m venv "$VENV_PATH" || {
            echo "[!] Could not create virtual environment. Continuing without it."
            VENV_PATH=""
        }
    }
    if [ -d "$VENV_PATH" ]; then
        VENV_CREATED=true
        echo "[+] Virtual environment created at $VENV_PATH"
    fi
else
    echo "[i] Python virtual environment already exists at $VENV_PATH"
fi

if [ -n "$VENV_PATH" ]; then
    source "$VENV_PATH/bin/activate"
    echo "[*] Upgrading pip..."
    pip install --upgrade pip 2>/dev/null || true
    echo "[*] Installing Python dependencies..."
    pip install requests 2>/dev/null || true
    deactivate
fi

touch ~/.hushlogin

if [ -f ~/.zsh_config ]; then
    source ~/.zsh_config
    echo "[*] Current username: $USER_NAME"
    read -rp "[?] Change username? (y/n): " ganti
    if [[ "$ganti" == "y" ]]; then
        read -rp "[+] Enter new username: " new_name
        USER_NAME="$new_name"
        echo "USER_NAME=$USER_NAME" > ~/.zsh_config
        echo "[+] Username updated."
    else
        echo "[i] Keeping existing username."
    fi
else
    read -rp "[+] Enter your terminal username: " user_name
    echo "USER_NAME=$user_name" > ~/.zsh_config
    echo "[+] Username saved."
fi

read -rp "[?] Auto-start MySQL/MariaDB if present? (y/n): " mysql_auto
if [[ "$mysql_auto" =~ ^[Yy] ]]; then
    ENABLE_MYSQL="yes"
else
    ENABLE_MYSQL="no"
fi
grep -q "^ENABLE_MYSQL=" ~/.zsh_config 2>/dev/null && sed -i "s/^ENABLE_MYSQL=.*/ENABLE_MYSQL=$ENABLE_MYSQL/" ~/.zsh_config || echo "ENABLE_MYSQL=$ENABLE_MYSQL" >> ~/.zsh_config

read -rp "[?] Enable automatic update check on startup? (y/n): " update_check
if [[ "$update_check" =~ ^[Yy] ]]; then
    UPDATE_CHECK="yes"
else
    UPDATE_CHECK="no"
fi
grep -q "^UPDATE_CHECK=" ~/.zsh_config 2>/dev/null && sed -i "s/^UPDATE_CHECK=.*/UPDATE_CHECK=$UPDATE_CHECK/" ~/.zsh_config || echo "UPDATE_CHECK=$UPDATE_CHECK" >> ~/.zsh_config

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

echo "[*] Setup complete."
echo ""
echo "=========== IMPORTANT NOTES ==========="
echo "1. Make sure Termux:API app is installed from F-Droid and permissions are granted (especially Location)."
echo "2. Run 'termux-location' once to trigger the location permission popup."
echo "3. To manually check prayer times, use commands: --location, --schedule, --update, --changelog"
echo "4. If sound not working, install one of: termux-media-player (built-in), sox, mpv"
echo "5. Restart Termux or run 'exec zsh' to start using the new configuration."
if [ "$VENV_CREATED" = true ]; then
    echo "6. A Python virtual environment was created at ~/venv. To use it, run: source ~/venv/bin/activate"
fi
echo "======================================="