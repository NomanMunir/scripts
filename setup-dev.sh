#!/bin/bash

#==============================================================================
# Developer Environment Setup Script for Debian/Ubuntu
# Version: 2.0
# Description: Automated installation of development tools and security hardening
# Author: Professional Setup Script
# License: MIT
#==============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/var/log/dev-setup-$(date +%Y%m%d-%H%M%S).log"
readonly BACKUP_DIR="/root/ssh-backup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
readonly GREEN="\e[32m"
readonly CYAN="\e[36m"
readonly RED="\e[31m"
readonly YELLOW="\e[33m"
readonly BLUE="\e[34m"
readonly BOLD="\e[1m"
readonly RESET="\e[0m"

# Global variables
CURRENT_USER=""
INSTALLATION_COUNT=0
FAILED_INSTALLATIONS=()
START_TIME=$(date +%s)

#==============================================================================
# Utility Functions
#==============================================================================

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Print formatted messages
print_header() {
    echo -e "\n${BOLD}${BLUE}================================${RESET}"
    echo -e "${BOLD}${BLUE} $1${RESET}"
    echo -e "${BOLD}${BLUE}================================${RESET}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${RESET}"
    log "SUCCESS" "$1"
}

print_error() {
    echo -e "${RED}✗ $1${RESET}"
    log "ERROR" "$1"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${RESET}"
    log "WARNING" "$1"
}

print_info() {
    echo -e "${CYAN}ℹ $1${RESET}"
    log "INFO" "$1"
}

# Check if running as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_error "This script must be run as root"
        echo "Please run: sudo $SCRIPT_NAME"
        exit 1
    fi
}

# Check system compatibility
check_system() {
    if ! command -v apt &>/dev/null; then
        print_error "This script requires a Debian/Ubuntu system with apt package manager"
        exit 1
    fi
    
    print_success "System compatibility verified"
}

# Enhanced confirmation function with better UX
confirm_install() {
    local component="$1"
    local description="$2"
    
    echo -e "\n${BOLD}Install: ${component}${RESET}"
    if [ -n "$description" ]; then
        echo -e "${CYAN}Description: $description${RESET}"
    fi
    
    while true; do
        read -p "Do you want to install this component? [Y/n]: " choice
        case "$choice" in
            [Yy]* | "" ) return 0 ;;
            [Nn]* ) return 1 ;;
            * ) echo "Please answer yes (y) or no (n)." ;;
        esac
    done
}

# Safe package installation with error handling
install_packages() {
    local packages=("$@")
    local failed_packages=()
    
    for package in "${packages[@]}"; do
        print_info "Installing $package..."
        if apt install -y "$package" >> "$LOG_FILE" 2>&1; then
            print_success "$package installed successfully"
        else
            print_error "Failed to install $package"
            failed_packages+=("$package")
        fi
    done
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        FAILED_INSTALLATIONS+=("${failed_packages[@]}")
        return 1
    fi
    return 0
}

# Get or create user
setup_user() {
    local username=""
    
    # Check if there's already a non-root user
    local existing_user=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' | head -n1)
    
    if [ -n "$existing_user" ]; then
        echo -e "\n${CYAN}Found existing user: $existing_user${RESET}"
        if confirm_install "Use existing user ($existing_user)" "Use the existing non-root user for configuration"; then
            CURRENT_USER="$existing_user"
            return 0
        fi
    fi
    
    if confirm_install "Create new user" "Create a new non-root user with sudo privileges"; then
        while true; do
            read -p "Enter username for the new user: " username
            if [ -n "$username" ] && [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
                break
            else
                print_error "Invalid username. Use lowercase letters, numbers, underscore, and hyphen only."
            fi
        done
        
        if id "$username" &>/dev/null; then
            print_warning "User '$username' already exists"
            CURRENT_USER="$username"
        else
            print_info "Creating user '$username'..."
            useradd -m -s /bin/bash "$username"
            echo "Please set a password for $username:"
            passwd "$username"
            usermod -aG sudo "$username"
            print_success "User '$username' created and added to sudo group"
            CURRENT_USER="$username"
        fi
    fi
}

# Backup SSH configuration before making changes
backup_ssh_config() {
    if [ -f /etc/ssh/sshd_config ]; then
        mkdir -p "$BACKUP_DIR"
        cp /etc/ssh/sshd_config "$BACKUP_DIR/sshd_config.backup"
        print_info "SSH configuration backed up to $BACKUP_DIR"
    fi
}

# Safe SSH configuration with validation
configure_ssh_safely() {
    backup_ssh_config
    
    local config_file="/etc/ssh/sshd_config"
    local temp_config="/tmp/sshd_config.tmp"
    
    cp "$config_file" "$temp_config"
    
    # Apply SSH hardening
    sed -i 's/#Port 22/Port 22/' "$temp_config"
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' "$temp_config"
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' "$temp_config"
    
    # Only disable password auth if SSH keys exist for the user
    if [ -n "$CURRENT_USER" ] && [ -d "/home/$CURRENT_USER/.ssh" ] && [ -f "/home/$CURRENT_USER/.ssh/authorized_keys" ]; then
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' "$temp_config"
        sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' "$temp_config"
        print_info "Password authentication disabled (SSH keys detected)"
    else
        print_warning "SSH keys not found. Keeping password authentication enabled for safety."
        print_info "To set up SSH keys later, run: ssh-keygen -t ed25519"
    fi
    
    # Add LogLevel if not present
    if ! grep -q "^LogLevel" "$temp_config"; then
        echo "LogLevel VERBOSE" >> "$temp_config"
    fi
    
    # Test SSH configuration
    if sshd -t -f "$temp_config" 2>/dev/null; then
        mv "$temp_config" "$config_file"
        print_success "SSH configuration updated successfully"
        return 0
    else
        print_error "SSH configuration test failed. Keeping original configuration."
        rm -f "$temp_config"
        return 1
    fi
}

# Progress tracking
show_progress() {
    local current="$1"
    local total="$2"
    local description="$3"
    
    local percentage=$((current * 100 / total))
    local bar_length=50
    local filled_length=$((percentage * bar_length / 100))
    
    printf "\r${CYAN}Progress: ["
    printf "%*s" "$filled_length" | tr ' ' '='
    printf "%*s" $((bar_length - filled_length)) | tr ' ' '-'
    printf "] %d%% - %s${RESET}" "$percentage" "$description"
    
    if [ "$current" -eq "$total" ]; then
        echo
    fi
}

#==============================================================================
# Main Installation Functions
#==============================================================================

# Initialize script
initialize() {
    print_header "Development Environment Setup Script v2.0"
    
    print_info "Starting setup process..."
    print_info "Logs will be saved to: $LOG_FILE"
    
    check_root
    check_system
    
    # Create log file
    touch "$LOG_FILE"
    log "INFO" "Script started by user: $(logname 2>/dev/null || echo 'root')"
    log "INFO" "System: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')"
}

# System update and basic setup
update_system() {
    ((INSTALLATION_COUNT++))
    show_progress $INSTALLATION_COUNT 15 "Updating system packages"
    
    print_info "Updating package lists and upgrading system..."
    if apt update >> "$LOG_FILE" 2>&1 && apt upgrade -y >> "$LOG_FILE" 2>&1; then
        print_success "System updated successfully"
    else
        print_error "Failed to update system"
        return 1
    fi
    
    # Install sudo if not present
    if ! command -v sudo &>/dev/null; then
        print_info "Installing sudo..."
        install_packages sudo
    fi
}

# Essential system utilities
install_essential_tools() {
    if confirm_install "Essential System Utilities" "Basic tools: curl, wget, git, zip, unzip, build-essential, software-properties-common"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Installing essential tools"
        
        local packages=(curl wget git zip unzip build-essential software-properties-common apt-transport-https ca-certificates gnupg lsb-release)
        install_packages "${packages[@]}"
    fi
}

# Networking and security tools
install_networking_security() {
    if confirm_install "Networking & Security Tools" "Tools: net-tools, iputils-ping, ufw, fail2ban, htop, neofetch"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Installing networking & security tools"
        
        local packages=(net-tools iputils-ping ufw fail2ban htop neofetch)
        install_packages "${packages[@]}"
    fi
}

# SSH server setup with enhanced security
setup_ssh_server() {
    if confirm_install "SSH Server Setup & Hardening" "Install and configure OpenSSH server with security hardening"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Setting up SSH server"
        
        install_packages openssh-server
        
        print_info "Configuring SSH server..."
        systemctl enable ssh >> "$LOG_FILE" 2>&1
        systemctl start ssh >> "$LOG_FILE" 2>&1
        
        if configure_ssh_safely; then
            if systemctl restart ssh >> "$LOG_FILE" 2>&1; then
                print_success "SSH server configured and restarted successfully"
            else
                print_error "Failed to restart SSH service"
                # Restore backup if restart fails
                if [ -f "$BACKUP_DIR/sshd_config.backup" ]; then
                    cp "$BACKUP_DIR/sshd_config.backup" /etc/ssh/sshd_config
                    systemctl restart ssh
                    print_info "SSH configuration restored from backup"
                fi
            fi
        fi
    fi
}

# UFW firewall configuration
setup_firewall() {
    if confirm_install "UFW Firewall Setup" "Configure firewall to allow SSH (22), HTTP (80), and HTTPS (443)"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Configuring firewall"
        
        print_info "Configuring UFW firewall..."
        {
            ufw allow 22/tcp    # SSH
            ufw allow 80/tcp    # HTTP  
            ufw allow 443/tcp   # HTTPS
            ufw --force enable
        } >> "$LOG_FILE" 2>&1
        
        print_success "Firewall configured successfully"
        print_info "Current firewall status:"
        ufw status verbose
    fi
}

# Docker installation
install_docker() {
    if confirm_install "Docker & Docker Compose" "Container platform for development and deployment"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Installing Docker"
        
        # Install Docker using official repository for latest version
        print_info "Adding Docker repository..."
        {
            curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt update
        } >> "$LOG_FILE" 2>&1
        
        install_packages docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        if [ -n "$CURRENT_USER" ]; then
            usermod -aG docker "$CURRENT_USER"
            print_success "User '$CURRENT_USER' added to docker group"
            print_warning "User needs to log out and back in for docker group changes to take effect"
        fi
    fi
}

# Database installation
install_databases() {
    if confirm_install "Database Tools" "SQLite, PostgreSQL, and MariaDB database systems"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Installing databases"
        
        local packages=(sqlite3 postgresql postgresql-contrib mariadb-server)
        install_packages "${packages[@]}"
        
        print_info "Starting database services..."
        {
            systemctl enable postgresql
            systemctl start postgresql
            systemctl enable mariadb
            systemctl start mariadb
        } >> "$LOG_FILE" 2>&1
        
        print_success "Databases installed and started"
        print_warning "Remember to run 'mysql_secure_installation' for MariaDB security setup"
    fi
}

# Development tools
install_development_tools() {
    if confirm_install "Development Tools" "Compilers and dev tools: gcc, g++, clang, gdb, valgrind, Python3, Node.js"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Installing development tools"
        
        local packages=(gcc g++ clang gdb valgrind python3 python3-pip python3-venv nodejs npm)
        install_packages "${packages[@]}"
        
        # Set up Python alternatives if multiple versions exist
        if command -v python3 &>/dev/null && ! command -v python &>/dev/null; then
            update-alternatives --install /usr/bin/python python /usr/bin/python3 1
        fi
    fi
}

# Rust installation
install_rust() {
    if confirm_install "Rust Programming Language" "Modern systems programming language with cargo package manager"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Installing Rust"
        
        print_info "Installing Rust via rustup..."
        if [ -n "$CURRENT_USER" ]; then
            sudo -u "$CURRENT_USER" bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
            print_success "Rust installed for user $CURRENT_USER"
        else
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            print_success "Rust installed system-wide"
        fi
    fi
}

# Shell and terminal enhancements
install_shell_enhancements() {
    if confirm_install "Zsh & Oh My Zsh" "Enhanced shell with Oh My Zsh framework and powerline fonts"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Installing Zsh and Oh My Zsh"
        
        install_packages zsh fonts-powerline
        
        if [ -n "$CURRENT_USER" ]; then
            print_info "Installing Oh My Zsh for user $CURRENT_USER..."
            sudo -u "$CURRENT_USER" bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
            chsh -s "$(which zsh)" "$CURRENT_USER"
            print_success "Zsh set as default shell for $CURRENT_USER"
        else
            print_warning "No user specified. Skipping Oh My Zsh installation."
        fi
    fi
}

# Additional CLI tools
install_cli_tools() {
    if confirm_install "Useful CLI Tools" "Enhanced productivity tools: tmux, bat, fzf, ripgrep, jq, tree, vim"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Installing CLI tools"
        
        local packages=(tmux bat fzf ripgrep jq tree vim)
        install_packages "${packages[@]}"
    fi
}

# Web server installation
install_web_server() {
    if confirm_install "Nginx Web Server" "High-performance web server and reverse proxy"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Installing Nginx"
        
        install_packages nginx
        
        print_info "Configuring Nginx..."
        {
            systemctl enable nginx
            systemctl start nginx
        } >> "$LOG_FILE" 2>&1
        
        print_success "Nginx installed and started"
        print_info "Default site available at http://localhost"
    fi
}

# Automatic security updates
setup_auto_updates() {
    if confirm_install "Automatic Security Updates" "Configure unattended-upgrades for automatic security patches"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Setting up automatic updates"
        
        install_packages unattended-upgrades
        
        print_info "Configuring automatic updates..."
        echo 'Unattended-Upgrade::Automatic-Reboot "false";' > /etc/apt/apt.conf.d/52-auto-reboot
        dpkg-reconfigure -plow unattended-upgrades
        print_success "Automatic security updates configured"
    fi
}

# System enhancements
setup_system_enhancements() {
    if confirm_install "System Enhancements" "Swap file, time synchronization, and fail2ban configuration"; then
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT 15 "Applying system enhancements"
        
        # Setup swap file with user input
        local swap_size="2G"
        if [ ! -f /swapfile ]; then
            read -p "Enter swap file size (default: 2G): " user_swap
            swap_size="${user_swap:-2G}"
            
            print_info "Creating ${swap_size} swap file..."
            {
                fallocate -l "$swap_size" /swapfile
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile
                echo '/swapfile none swap sw 0 0' >> /etc/fstab
            } >> "$LOG_FILE" 2>&1
            print_success "Swap file created: $swap_size"
        else
            print_info "Swap file already exists"
        fi
        
        # Time synchronization
        install_packages chrony
        {
            systemctl enable chrony
            systemctl start chrony
        } >> "$LOG_FILE" 2>&1
        print_success "Time synchronization configured"
        
        # Enhanced Fail2ban configuration
        print_info "Configuring Fail2ban..."
        cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200
EOF
        
        {
            systemctl enable fail2ban
            systemctl restart fail2ban
        } >> "$LOG_FILE" 2>&1
        print_success "Fail2ban configured for SSH protection"
    fi
}

# Generate installation summary
generate_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    local hours=$((duration / 3600))
    local minutes=$(((duration % 3600) / 60))
    local seconds=$((duration % 60))
    
    print_header "Installation Summary"
    
    echo -e "${BOLD}Installation completed in: ${hours}h ${minutes}m ${seconds}s${RESET}"
    echo -e "${BOLD}Log file: ${LOG_FILE}${RESET}"
    
    if [ ${#FAILED_INSTALLATIONS[@]} -eq 0 ]; then
        print_success "All selected components installed successfully!"
    else
        print_warning "Some installations failed:"
        for failed in "${FAILED_INSTALLATIONS[@]}"; do
            echo -e "  ${RED}• $failed${RESET}"
        done
        print_info "Check the log file for detailed error information"
    fi
    
    # Post-installation recommendations
    echo -e "\n${BOLD}${BLUE}Post-Installation Recommendations:${RESET}"
    
    if [ -n "$CURRENT_USER" ]; then
        echo -e "${CYAN}• Log out and back in as '$CURRENT_USER' to apply group changes${RESET}"
        echo -e "${CYAN}• Set up SSH keys: ssh-keygen -t ed25519${RESET}"
    fi
    
    if command -v docker &>/dev/null; then
        echo -e "${CYAN}• Test Docker: docker run hello-world${RESET}"
    fi
    
    if command -v mariadb &>/dev/null; then
        echo -e "${CYAN}• Secure MariaDB: mysql_secure_installation${RESET}"
    fi
    
    echo -e "${CYAN}• Update your system regularly: apt update && apt upgrade${RESET}"
    echo -e "${CYAN}• Configure your development environment and tools${RESET}"
    
    print_info "System reboot recommended to ensure all changes take effect"
    
    # Ask about reboot
    echo
    if confirm_install "Reboot System" "Reboot now to apply all changes (recommended)"; then
        print_info "Rebooting system in 10 seconds... (Ctrl+C to cancel)"
        sleep 10
        reboot
    else
        print_warning "Please reboot your system when convenient"
    fi
}

#==============================================================================
# Main Execution
#==============================================================================

main() {
    # Initialize
    initialize
    
    # User setup
    setup_user
    
    # System update
    update_system
    
    # Install components
    install_essential_tools
    install_networking_security
    setup_ssh_server
    setup_firewall
    install_docker
    install_databases
    install_development_tools
    install_rust
    install_shell_enhancements
    install_cli_tools
    install_web_server
    setup_auto_updates
    setup_system_enhancements
    
    # Final summary
    generate_summary
}

# Trap to handle script interruption
trap 'print_error "Script interrupted"; exit 1' INT TERM

# Run main function
main "$@"
