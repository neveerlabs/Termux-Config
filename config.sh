#!/data/data/com.termux/files/usr/bin/bash
set -e
echo "Starting kali termux setup..."

pkg update -y
pkg install zsh git -y

mkdir -p ~/.zsh
if [ ! -d ~/.zsh/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi
if [ ! -d ~/.zsh/zsh-syntax-highlighting ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
fi

cp "$(dirname $0)/.zshrc" ~/.zshrc

touch ~/.hushlogin

printf "Enter your terminal username: "
read user_name
echo "USER_NAME=$user_name" > ~/.zsh_config

chsh -s zsh

echo "Done! Please restart Termux or run Zshrc."
