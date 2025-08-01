#!/bin/bash

#==============================================================================
# Common Functions Module
# Shared utility functions for the modular setup script
#==============================================================================

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

print_section() {
    echo -e "\n${BOLD}${PURPLE}▶ $1${RESET}"
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
    
    # Check if we're on a supported distribution
    if command -v lsb_release &>/dev/null; then
        local distro=$(lsb_release -si)
        local version=$(lsb_release -sr)
        print_info "Detected: $distro $version"
        
        case "$distro" in
            Ubuntu|Debian)
                print_success "System compatibility verified"
                ;;
            *)
                print_warning "Untested distribution: $distro. Proceeding with caution."
                ;;
        esac
    else
        print_warning "Could not detect distribution. Assuming Debian/Ubuntu compatibility."
    fi
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

# Generic confirmation function
confirm_action() {
    local action="$1"
    local description="${2:-}"
    
    if [ -n "$description" ]; then
        echo -e "${CYAN}$description${RESET}"
    fi
    
    while true; do
        read -p "$action? [Y/n]: " choice
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

# Install packages with dpkg (for .deb files)
install_deb_package() {
    local deb_file="$1"
    local package_name="$2"
    
    print_info "Installing $package_name from .deb package..."
    if dpkg -i "$deb_file" >> "$LOG_FILE" 2>&1; then
        print_success "$package_name installed successfully"
        return 0
    else
        print_warning "dpkg installation failed, trying to fix dependencies..."
        if apt-get install -f -y >> "$LOG_FILE" 2>&1; then
            print_success "$package_name installed successfully after fixing dependencies"
            return 0
        else
            print_error "Failed to install $package_name"
            FAILED_INSTALLATIONS+=("$package_name")
            return 1
        fi
    fi
}

# Add APT repository safely
add_repository() {
    local repo="$1"
    local keyring_file="$2"
    local key_url="$3"
    
    print_info "Adding repository: $repo"
    
    # Add GPG key if provided
    if [ -n "$key_url" ] && [ -n "$keyring_file" ]; then
        curl -fsSL "$key_url" | gpg --dearmor -o "$keyring_file" >> "$LOG_FILE" 2>&1
    fi
    
    # Add repository
    echo "$repo" | tee /etc/apt/sources.list.d/$(basename "$keyring_file" .gpg).list > /dev/null
    
    # Update package lists
    apt update >> "$LOG_FILE" 2>&1
    
    print_success "Repository added successfully"
}

# Install snap packages
install_snap_packages() {
    local packages=("$@")
    
    # Ensure snapd is installed
    if ! command -v snap &>/dev/null; then
        print_info "Installing snapd..."
        install_packages snapd
        systemctl enable snapd >> "$LOG_FILE" 2>&1
        systemctl start snapd >> "$LOG_FILE" 2>&1
    fi
    
    for package in "${packages[@]}"; do
        print_info "Installing snap package: $package"
        if snap install "$package" >> "$LOG_FILE" 2>&1; then
            print_success "Snap package $package installed successfully"
        else
            print_error "Failed to install snap package: $package"
            FAILED_INSTALLATIONS+=("snap:$package")
        fi
    done
}

# Install flatpak packages
install_flatpak_packages() {
    local packages=("$@")
    
    # Ensure flatpak is installed
    if ! command -v flatpak &>/dev/null; then
        print_info "Installing flatpak..."
        install_packages flatpak
        
        # Add flathub repository
        print_info "Adding Flathub repository..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >> "$LOG_FILE" 2>&1
    fi
    
    for package in "${packages[@]}"; do
        print_info "Installing flatpak package: $package"
        if flatpak install -y flathub "$package" >> "$LOG_FILE" 2>&1; then
            print_success "Flatpak package $package installed successfully"
        else
            print_error "Failed to install flatpak package: $package"
            FAILED_INSTALLATIONS+=("flatpak:$package")
        fi
    done
}

# Download and install from URL
download_and_install() {
    local url="$1"
    local filename="$2"
    local package_name="$3"
    local temp_dir="/tmp/setup-downloads"
    
    mkdir -p "$temp_dir"
    
    print_info "Downloading $package_name..."
    if curl -L -o "$temp_dir/$filename" "$url" >> "$LOG_FILE" 2>&1; then
        print_success "$package_name downloaded successfully"
        
        case "$filename" in
            *.deb)
                install_deb_package "$temp_dir/$filename" "$package_name"
                ;;
            *.tar.gz|*.tgz)
                print_info "Extracting $package_name..."
                tar -xzf "$temp_dir/$filename" -C "$temp_dir/" >> "$LOG_FILE" 2>&1
                print_success "$package_name extracted to $temp_dir/"
                ;;
            *.zip)
                print_info "Extracting $package_name..."
                unzip -q "$temp_dir/$filename" -d "$temp_dir/" >> "$LOG_FILE" 2>&1
                print_success "$package_name extracted to $temp_dir/"
                ;;
            *)
                print_info "$package_name downloaded to $temp_dir/$filename"
                ;;
        esac
    else
        print_error "Failed to download $package_name"
        FAILED_INSTALLATIONS+=("$package_name")
        return 1
    fi
}

# Get or create user
setup_user() {
    local username=""
    
    # Check if there's already a non-root user
    local existing_user=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' | head -n1)
    
    if [ -n "$existing_user" ]; then
        echo -e "\n${CYAN}Found existing user: $existing_user${RESET}"
        if confirm_action "Use existing user ($existing_user)" "Use the existing non-root user for configuration"; then
            CURRENT_USER="$existing_user"
            return 0
        fi
    fi
    
    if confirm_action "Create new user" "Create a new non-root user with sudo privileges"; then
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

# Service management functions
enable_and_start_service() {
    local service="$1"
    
    print_info "Enabling and starting $service..."
    if systemctl enable "$service" >> "$LOG_FILE" 2>&1 && systemctl start "$service" >> "$LOG_FILE" 2>&1; then
        print_success "$service enabled and started"
        return 0
    else
        print_error "Failed to enable/start $service"
        return 1
    fi
}

# Check if service is running
check_service_status() {
    local service="$1"
    
    if systemctl is-active --quiet "$service"; then
        print_success "$service is running"
        return 0
    else
        print_warning "$service is not running"
        return 1
    fi
}

# Add user to group
add_user_to_group() {
    local user="$1"
    local group="$2"
    
    if [ -n "$user" ]; then
        print_info "Adding user '$user' to group '$group'..."
        if usermod -aG "$group" "$user" >> "$LOG_FILE" 2>&1; then
            print_success "User '$user' added to group '$group'"
            return 0
        else
            print_error "Failed to add user '$user' to group '$group'"
            return 1
        fi
    else
        print_warning "No user specified for group '$group'"
        return 1
    fi
}

# Create desktop entry
create_desktop_entry() {
    local name="$1"
    local exec="$2"
    local icon="$3"
    local comment="$4"
    local categories="${5:-Development}"
    
    local desktop_file="/usr/share/applications/${name,,}.desktop"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$name
Comment=$comment
Exec=$exec
Icon=$icon
Categories=$categories;
Terminal=false
StartupNotify=true
EOF
    
    chmod 644 "$desktop_file"
    print_success "Desktop entry created for $name"
}

# Check if package is installed
is_package_installed() {
    local package="$1"
    dpkg -l | grep -q "^ii  $package "
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Get system architecture
get_architecture() {
    dpkg --print-architecture
}

# Get system codename
get_codename() {
    lsb_release -cs 2>/dev/null || echo "unknown"
}

# Clean up temporary files
cleanup_temp_files() {
    local temp_dir="/tmp/setup-downloads"
    if [ -d "$temp_dir" ]; then
        print_info "Cleaning up temporary files..."
        rm -rf "$temp_dir"
        print_success "Temporary files cleaned up"
    fi
}

# Error handling for module execution
handle_module_error() {
    local module="$1"
    local error_message="$2"
    
    print_error "Error in module '$module': $error_message"
    log "ERROR" "Module '$module' failed: $error_message"
    FAILED_INSTALLATIONS+=("$module")
}

# Backup file before modification
backup_file() {
    local file="$1"
    local backup_suffix="${2:-.backup}"
    
    if [ -f "$file" ]; then
        local backup_file="${BACKUP_DIR}/$(basename "$file")${backup_suffix}"
        cp "$file" "$backup_file"
        print_info "Backed up $file to $backup_file"
    fi
}

# Restore file from backup
restore_file() {
    local file="$1"
    local backup_suffix="${2:-.backup}"
    local backup_file="${BACKUP_DIR}/$(basename "$file")${backup_suffix}"
    
    if [ -f "$backup_file" ]; then
        cp "$backup_file" "$file"
        print_info "Restored $file from backup"
        return 0
    else
        print_error "Backup file not found: $backup_file"
        return 1
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
