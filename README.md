```md
# Developer Setup Script

This script automates the installation of essential development tools on a fresh **Debian** system.

## 📌 How to Run the Script

Run the following command in your terminal to execute the setup script directly from GitHub:

```bash
bash <(curl -sL https://raw.githubusercontent.com/NomanMunir/scripts/main/setup-dev.sh)
```

Alternatively, you can download and run it manually:

```bash
wget -O setup-dev.sh https://raw.githubusercontent.com/NomanMunir/scripts/main/setup-dev.sh
chmod +x setup-dev.sh
./setup-dev.sh
```

## 🚀 What This Script Installs

- **System Utilities**: `curl`, `wget`, `git`, `zip`, `unzip`, `build-essential`
- **Shell & Terminal Enhancements**: `zsh`, `tmux`, `htop`, `neofetch`
- **Development Tools**: `gcc`, `g++`, `clang`, `gdb`, `valgrind`, `python3`, `nodejs`
- **Docker & Databases**: `docker`, `postgresql`, `sqlite3`, `mariadb`
- **Networking & Security**: `net-tools`, `ufw`
- **Editors**: `vim`, `VS Code`
- **Optional Enhancements**: `Oh My Zsh`, `fzf`, `ripgrep`, `nvm`, `pyenv`

## 🔧 Customization

The script asks for confirmation before installing each set of tools, allowing you to customize the setup based on your needs.
