# Termux Config

Konfigurasi Zsh untuk Termux yang membuat tampilan dan fitur seperti terminal Linux. Fitur:
- Autosuggestion dari history (ghost text)
- Syntax highlighting untuk perintah, path, opsi
- Prompt dinamis menampilkan direktori aktif & virtual env
- History hanya perintah sukses, anti duplikat
- Blok kursor, navigasi panah kanan pintar

## Persyaratan
- Termux (dari F-Droid)
- Koneksi internet

## Setup & Installasi
Jalankan perintah berikut di Termux:
```bash
# Clone repositori:
git clone https://github.com/neveerlabs/Termux-Config.git

# Masuk kedalam folder:
cd Termux-Config

# Install dependensi:
pkg update && pkg install zsh git -y

# Install plugin:
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

# Hilangkan banner termux:
touch ~/.hushlogin

# Ubah shell default ke Zsh:
chsh -s zsh

# Salin konfigurasi ke home:
cp .zshrc ~/.zshrc
```
> *Setelah semuanya selesai, keluar dari termux lalu masuk kembali kedalam termux*