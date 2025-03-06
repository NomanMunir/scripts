#!/bin/bash

# Colors for output
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"

# Function to prompt user for confirmation
confirm_install() {
    read -p "Do you want to install $1? (y/n): " choice
    case "$choice" in
        y|Y ) return 0 ;;
        * ) return 1 ;;
    esac
}

echo -e "${GREEN}Updating and upgrading system...${RESET}"
sudo apt update && sudo apt upgrade -y

if confirm_install "Essential System Utilities (curl, wget, git, zip, build-essential)"; then
    echo -e "${CYAN}Installing essential system utilities...${RESET}"
    sudo apt install -y curl wget git zip unzip build-essential
fi

if confirm_install "Shell & Terminal Utilities (zsh, tmux, htop, neofetch)"; then
    echo -e "${CYAN}Installing shell & terminal utilities...${RESET}"
    sudo apt install -y zsh tmux htop neofetch
fi

if confirm_install "Development Tools (C, C++, Python, Node.js)"; then
    echo -e "${CYAN}Installing development tools...${RESET}"
    sudo apt install -y gcc g++ clang gdb valgrind python3 python3-pip python3-venv nodejs npm
fi

if confirm_install "Docker & Docker Compose"; then
    echo -e "${CYAN}Installing Docker & Docker Compose...${RESET}"
    sudo apt install -y docker.io docker-compose
    sudo usermod -aG docker $USER
fi

if confirm_install "Database Tools (SQLite, PostgreSQL, MariaDB)"; then
    echo -e "${CYAN}Installing database tools...${RESET}"
    sudo apt install -y sqlite3 postgresql postgresql-contrib mariadb-server
fi

if confirm_install "Networking & Security Tools (net-tools, ping, ufw)"; then
    echo -e "${CYAN}Installing networking & security tools...${RESET}"
    sudo apt install -y net-tools iputils-ping ufw
    sudo ufw enable
fi

if confirm_install "Vim Editor"; then
    echo -e "${CYAN}Installing Vim editor...${RESET}"
    sudo apt install -y vim
fi

if confirm_install "VS Code"; then
    echo -e "${CYAN}Installing VS Code...${RESET}"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update && sudo apt install -y code
fi

if confirm_install "Oh My Zsh & Powerline Fonts"; then
    echo -e "${CYAN}Installing Oh My Zsh...${RESET}"
    sudo apt install -y zsh fonts-powerline
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    chsh -s $(which zsh)
fi

echo -e "${GREEN}Setup complete! Please restart your system.${RESET}"
