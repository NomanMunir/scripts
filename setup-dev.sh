#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please switch to root (or use sudo if available)."
    exit 1
fi

# Colors for output
GREEN="\e[32m"
CYAN="\e[36m"
RED="\e[31m"
RESET="\e[0m"

# Function to prompt user for confirmation
confirm_install() {
    read -p "Do you want to install $1? (y/n): " choice
    case "$choice" in
        y|Y ) return 0 ;;
        * ) return 1 ;;
    esac
}

# --- Step 1: Basic System Setup ---

echo -e "${GREEN}Updating and upgrading system...${RESET}"
apt update && apt upgrade -y

# Install sudo if not installed (on minimal systems sudo may be missing)
if ! command -v sudo &>/dev/null; then
    echo -e "${CYAN}sudo not found, installing sudo...${RESET}"
    apt install -y sudo
fi

# --- Step 2: Create a New User and Add to sudo Group ---
if confirm_install "Create a new user"; then
    read -p "Enter the username for the new user: " newuser
    if id "$newuser" &>/dev/null; then
        echo -e "${RED}User '$newuser' already exists. Skipping user creation.${RESET}"
    else
        echo -e "${CYAN}Creating user '$newuser'...${RESET}"
        useradd -m -s /bin/bash "$newuser"
        echo "Please set a password for $newuser:"
        passwd "$newuser"
        echo -e "${CYAN}Adding user '$newuser' to the sudo group...${RESET}"
        usermod -aG sudo "$newuser"
    fi
fi

# --- Step 3: Install Essential Tools ---
if confirm_install "Essential System Utilities (curl, wget, git, zip, unzip, build-essential)"; then
    echo -e "${CYAN}Installing essential system utilities...${RESET}"
    apt install -y curl wget git zip unzip build-essential
fi

# --- Step 4: Networking & Security Tools ---
if confirm_install "Networking & Security Tools (net-tools, iputils-ping, ufw, fail2ban)"; then
    echo -e "${CYAN}Installing networking & security tools...${RESET}"
    apt install -y net-tools iputils-ping ufw fail2ban
fi

# --- Step 5: SSH Server Configuration ---
if confirm_install "SSH Server Setup & Hardening (openssh-server)"; then
    echo -e "${CYAN}Installing and configuring SSH server...${RESET}"
    apt install -y openssh-server
    systemctl enable ssh
    systemctl start ssh

    echo -e "${CYAN}Hardening SSH settings...${RESET}"
    # Ensure SSH is set to use port 22 (or modify as needed)
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
    # Disable root login and password authentication for better security
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    # --- Additional Logging Configuration for SSH ---
    if ! grep -q "^LogLevel" /etc/ssh/sshd_config; then
        echo "LogLevel VERBOSE" >> /etc/ssh/sshd_config
        systemctl restart ssh
    fi
    systemctl restart ssh
fi

# --- Step 6: UFW Firewall Setup ---
if confirm_install "UFW Firewall Setup (allow SSH, HTTP, HTTPS)"; then
    echo -e "${CYAN}Configuring UFW firewall...${RESET}"
    ufw allow 22/tcp   # SSH
    ufw allow 80/tcp   # HTTP
    ufw allow 443/tcp  # HTTPS
    ufw --force enable
    ufw status verbose
fi

# --- Step 7: Docker Installation ---
if confirm_install "Docker & Docker Compose"; then
    echo -e "${CYAN}Installing Docker & Docker Compose...${RESET}"
    apt install -y docker.io docker-compose
    usermod -aG docker "$newuser"
fi

# --- Step 8: Databases ---
if confirm_install "Database Tools (SQLite, PostgreSQL, MariaDB)"; then
    echo -e "${CYAN}Installing databases...${RESET}"
    apt install -y sqlite3 postgresql postgresql-contrib mariadb-server
fi

# --- Step 9: Development Tools ---
if confirm_install "Development Tools (gcc, g++, clang, gdb, valgrind, Python, Node.js)"; then
    echo -e "${CYAN}Installing development tools...${RESET}"
    apt install -y gcc g++ clang gdb valgrind python3 python3-pip python3-venv nodejs npm
fi

# --- Step 10: Rust Installation ---
if confirm_install "Rust Programming Language"; then
    echo -e "${CYAN}Installing Rust...${RESET}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# --- Step 11: Zsh and Oh My Zsh ---
if confirm_install "Zsh & Oh My Zsh with Powerline Fonts"; then
    echo -e "${CYAN}Installing Zsh & Oh My Zsh...${RESET}"
    apt install -y zsh fonts-powerline
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    chsh -s "$(which zsh)" "$newuser"
fi

# --- Step 12: Additional CLI Tools ---
if confirm_install "Useful CLI Tools (tmux, bat, fzf, ripgrep, jq)"; then
    echo -e "${CYAN}Installing additional CLI tools...${RESET}"
    apt install -y tmux bat fzf ripgrep jq
fi

# --- Step 13: Web Server (Nginx) ---
if confirm_install "Nginx Web Server"; then
    echo -e "${CYAN}Installing Nginx...${RESET}"
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx
fi

# --- Step 14: Automatic Security Updates ---
if confirm_install "Automatic Security Updates (unattended-upgrades)"; then
    echo -e "${CYAN}Installing and configuring unattended-upgrades...${RESET}"
    apt install -y unattended-upgrades
    dpkg-reconfigure --priority=low unattended-upgrades
fi

# --- Step 15: Additional Enhancements ---
if confirm_install "Additional Enhancements (swap file, time sync, fail2ban config)"; then
    echo -e "${CYAN}Setting up a swap file (2G)...${RESET}"
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab

    echo -e "${CYAN}Installing Chrony for time synchronization...${RESET}"
    apt install -y chrony
    systemctl enable chrony
    systemctl start chrony

    echo -e "${CYAN}Configuring Fail2ban for SSH protection...${RESET}"
    # A basic Fail2ban configuration for SSH (you can extend this as needed)
    cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF
    systemctl restart fail2ban
fi

echo -e "${GREEN}Setup complete! Please reboot your system for all changes to take effect.${RESET}"
