# Termux Config

<p align="center">
  <img src="https://raw.githubusercontent.com/neveerlabs/Termux-Config/main/template.jpg" alt="Termux Config Preview" width="600">
</p>

Konfigurasi Zsh untuk Termux yang membuat tampilan dan fitur seperti terminal Linux. Fitur:
- Autosuggestion dari history tersimpan (ghost text)
- Syntax highlighting untuk perintah, path & opsi
- Prompt dinamis menampilkan direktori aktif & virtual env
- Blok kursor, navigasi panah kanan pintar

## Persyaratan
- Termux (dari F-Droid)
- Zshrc

## Setup & Installasi
Jalankan perintah berikut di Termux:
```bash
# Clone repositori:
git clone https://github.com/neveerlabs/Termux-Config.git

# Masuk kedalam folder:
cd Termux-Config

# Beri izin akses:
chmod +x config.sh

# Setup terminal:
./config.sh
```
> *Setelah semuanya selesai, keluar dari termux lalu masuk kembali kedalam termux*

## Catatan
- Mengubah penggunaan `bashrc` dengan `zshrc`.
- Semua data input perintah ddisimpan didalam `.zsh_history` dan data username disimpan di `.zsh_config`
- Pada saat setelah penginstalan plugin dan package yang dibutuhkan selesai, system akan meminta input username yang nantinya akan ditampilkan di input prompt terminal
- History input hanya perintah yang sukses aja yang dismpan, yang gagal dan input yang sudah ada tidak disimpan agar tidak duplikat
