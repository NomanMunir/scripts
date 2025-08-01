#!/bin/bash

#==============================================================================
# Comprehensive Developer Environment Setup Script for Debian/Ubuntu
# Version: 3.0 - Modular Edition
# Description: Automated installation of development tools with modular architecture
# Author: Professional Setup Script
# License: MIT
#==============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MODULES_DIR="$SCRIPT_DIR/modules"
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/var/log/dev-setup-$(date +%Y%m%d-%H%M%S).log"
readonly BACKUP_DIR="/root/setup-backup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
readonly GREEN="\e[32m"
readonly CYAN="\e[36m"
readonly RED="\e[31m"
readonly YELLOW="\e[33m"
readonly BLUE="\e[34m"
readonly PURPLE="\e[35m"
readonly BOLD="\e[1m"
readonly RESET="\e[0m"

# Global variables
CURRENT_USER=""
INSTALLATION_COUNT=0
TOTAL_MODULES=0
FAILED_INSTALLATIONS=()
START_TIME=$(date +%s)
SELECTED_MODULES=()

# Available modules
declare -A MODULES=(
    ["core"]="Core System Components"
    ["security"]="Security & Networking Tools"
    ["development"]="Development Tools & Languages"
    ["databases"]="Database Systems"
    ["multimedia"]="Multimedia Tools & Codecs"
    ["browsers"]="Web Browsers"
    ["utils"]="System Utilities & CLI Tools"
    ["editors"]="Text Editors & IDEs"
    ["virtualization"]="Virtualization & Containers"
    ["communication"]="Communication Tools"
    ["design"]="Design & Graphics Tools"
    ["productivity"]="Productivity & Office Tools"
)

#==============================================================================
# Load Common Functions
#==============================================================================

source "$MODULES_DIR/common.sh" 2>/dev/null || {
    echo "Error: Cannot load common functions. Please ensure modules/common.sh exists."
    exit 1
}

#==============================================================================
# Module Management Functions
#==============================================================================

# Display available modules with descriptions
show_modules_menu() {
    print_header "Available Installation Modules"
    
    echo -e "${BOLD}${BLUE}Select modules to install (you can choose multiple):${RESET}\n"
    
    local i=1
    for module in "${!MODULES[@]}"; do
        echo -e "${CYAN}[$i]${RESET} ${BOLD}${module}${RESET} - ${MODULES[$module]}"
        ((i++))
    done
    
    echo -e "\n${CYAN}[A]${RESET} ${BOLD}Install All Modules${RESET}"
    echo -e "${CYAN}[C]${RESET} ${BOLD}Custom Selection${RESET}"
    echo -e "${CYAN}[Q]${RESET} ${BOLD}Quit${RESET}"
}

# Get user module selection
select_modules() {
    while true; do
        show_modules_menu
        echo
        read -p "Enter your choice [1-${#MODULES[@]}/A/C/Q]: " choice
        
        case "${choice^^}" in
            A)
                SELECTED_MODULES=($(printf '%s\n' "${!MODULES[@]}" | sort))
                print_success "All modules selected for installation"
                break
                ;;
            C)
                select_custom_modules
                break
                ;;
            Q)
                print_info "Installation cancelled by user"
                exit 0
                ;;
            [1-9]*)
                if [[ $choice -ge 1 && $choice -le ${#MODULES[@]} ]]; then
                    local module_array=($(printf '%s\n' "${!MODULES[@]}" | sort))
                    local selected_module="${module_array[$((choice-1))]}"
                    SELECTED_MODULES=("$selected_module")
                    print_success "Selected module: ${MODULES[$selected_module]}"
                    break
                else
                    print_error "Invalid selection. Please choose a number between 1 and ${#MODULES[@]}"
                fi
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac
    done
}

# Custom module selection
select_custom_modules() {
    local temp_selection=()
    
    print_header "Custom Module Selection"
    echo -e "${CYAN}Select modules by entering their numbers separated by spaces (e.g., 1 3 5 7)${RESET}"
    echo -e "${CYAN}Or enter module names separated by spaces (e.g., core development utils)${RESET}\n"
    
    local i=1
    for module in $(printf '%s\n' "${!MODULES[@]}" | sort); do
        echo -e "${CYAN}[$i]${RESET} ${BOLD}$module${RESET} - ${MODULES[$module]}"
        ((i++))
    done
    
    echo
    read -p "Enter your selection: " selections
    
    # Parse selections (numbers or names)
    for selection in $selections; do
        if [[ "$selection" =~ ^[0-9]+$ ]]; then
            # Numeric selection
            if [[ $selection -ge 1 && $selection -le ${#MODULES[@]} ]]; then
                local module_array=($(printf '%s\n' "${!MODULES[@]}" | sort))
                local selected_module="${module_array[$((selection-1))]}"
                if [[ ! " ${temp_selection[@]} " =~ " ${selected_module} " ]]; then
                    temp_selection+=("$selected_module")
                fi
            else
                print_warning "Invalid module number: $selection"
            fi
        else
            # Name selection
            if [[ -n "${MODULES[$selection]:-}" ]]; then
                if [[ ! " ${temp_selection[@]} " =~ " ${selection} " ]]; then
                    temp_selection+=("$selection")
                fi
            else
                print_warning "Unknown module: $selection"
            fi
        fi
    done
    
    if [[ ${#temp_selection[@]} -gt 0 ]]; then
        SELECTED_MODULES=("${temp_selection[@]}")
        
        echo -e "\n${BOLD}Selected modules:${RESET}"
        for module in "${SELECTED_MODULES[@]}"; do
            echo -e "  ${GREEN}✓${RESET} ${BOLD}$module${RESET} - ${MODULES[$module]}"
        done
        
        echo
        if confirm_action "Proceed with these modules"; then
            print_success "Module selection confirmed"
        else
            select_modules
        fi
    else
        print_error "No valid modules selected"
        select_modules
    fi
}

# Load and execute a module
load_module() {
    local module="$1"
    local module_file="$MODULES_DIR/$module.sh"
    
    if [[ ! -f "$module_file" ]]; then
        print_error "Module file not found: $module_file"
        FAILED_INSTALLATIONS+=("$module")
        return 1
    fi
    
    print_header "Installing: ${MODULES[$module]}"
    
    # Source the module
    if source "$module_file"; then
        print_success "Module '$module' completed successfully"
        return 0
    else
        print_error "Module '$module' failed to execute"
        FAILED_INSTALLATIONS+=("$module")
        return 1
    fi
}

# Calculate total installation steps
calculate_total_steps() {
    TOTAL_MODULES=$((${#SELECTED_MODULES[@]} + 3)) # +3 for init, user setup, system update
}

#==============================================================================
# Main Installation Functions
#==============================================================================

# Initialize script
initialize() {
    print_header "Comprehensive Developer Environment Setup v3.0"
    
    print_info "Starting modular setup process..."
    print_info "Logs will be saved to: $LOG_FILE"
    
    check_root
    check_system
    
    # Create necessary directories
    mkdir -p "$BACKUP_DIR"
    
    # Create log file
    touch "$LOG_FILE"
    log "INFO" "Script started by user: $(logname 2>/dev/null || echo 'root')"
    log "INFO" "System: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')"
    log "INFO" "Script directory: $SCRIPT_DIR"
    
    ((INSTALLATION_COUNT++))
    show_progress $INSTALLATION_COUNT $TOTAL_MODULES "Initializing system"
}

# System update and basic setup
update_system() {
    ((INSTALLATION_COUNT++))
    show_progress $INSTALLATION_COUNT $TOTAL_MODULES "Updating system packages"
    
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
    
    # Add universe repository for more packages
    if ! grep -q "universe" /etc/apt/sources.list; then
        print_info "Adding universe repository..."
        add-apt-repository universe -y >> "$LOG_FILE" 2>&1
        apt update >> "$LOG_FILE" 2>&1
    fi
}

# Execute selected modules
execute_modules() {
    for module in "${SELECTED_MODULES[@]}"; do
        ((INSTALLATION_COUNT++))
        show_progress $INSTALLATION_COUNT $TOTAL_MODULES "Installing ${MODULES[$module]}"
        
        load_module "$module"
        
        # Small delay for better UX
        sleep 1
    done
}

# Generate comprehensive installation summary
generate_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    local hours=$((duration / 3600))
    local minutes=$(((duration % 3600) / 60))
    local seconds=$((duration % 60))
    
    print_header "Installation Summary"
    
    echo -e "${BOLD}Installation completed in: ${hours}h ${minutes}m ${seconds}s${RESET}"
    echo -e "${BOLD}Log file: ${LOG_FILE}${RESET}"
    echo -e "${BOLD}Backup directory: ${BACKUP_DIR}${RESET}\n"
    
    # Show installed modules
    echo -e "${BOLD}${GREEN}Successfully Installed Modules:${RESET}"
    for module in "${SELECTED_MODULES[@]}"; do
        if [[ ! " ${FAILED_INSTALLATIONS[@]} " =~ " ${module} " ]]; then
            echo -e "  ${GREEN}✓${RESET} ${BOLD}$module${RESET} - ${MODULES[$module]}"
        fi
    done
    
    # Show failed installations
    if [ ${#FAILED_INSTALLATIONS[@]} -gt 0 ]; then
        echo -e "\n${BOLD}${RED}Failed Installations:${RESET}"
        for failed in "${FAILED_INSTALLATIONS[@]}"; do
            echo -e "  ${RED}✗${RESET} ${BOLD}$failed${RESET}"
        done
        print_info "Check the log file for detailed error information"
    else
        print_success "All selected modules installed successfully!"
    fi
    
    # Post-installation recommendations
    show_post_installation_recommendations
    
    # System reboot recommendation
    print_info "System reboot recommended to ensure all changes take effect"
    
    # Ask about reboot
    echo
    if confirm_action "Reboot System" "Reboot now to apply all changes (recommended)"; then
        print_info "Rebooting system in 10 seconds... (Ctrl+C to cancel)"
        sleep 10
        reboot
    else
        print_warning "Please reboot your system when convenient"
    fi
}

# Show post-installation recommendations
show_post_installation_recommendations() {
    echo -e "\n${BOLD}${PURPLE}Post-Installation Recommendations:${RESET}"
    
    if [ -n "$CURRENT_USER" ]; then
        echo -e "${CYAN}• Log out and back in as '$CURRENT_USER' to apply group changes${RESET}"
        echo -e "${CYAN}• Set up SSH keys: ssh-keygen -t ed25519${RESET}"
        echo -e "${CYAN}• Configure Git: git config --global user.name 'Your Name'${RESET}"
        echo -e "${CYAN}• Configure Git: git config --global user.email 'your.email@example.com'${RESET}"
    fi
    
    # Module-specific recommendations
    for module in "${SELECTED_MODULES[@]}"; do
        case "$module" in
            "virtualization")
                if command -v docker &>/dev/null; then
                    echo -e "${CYAN}• Test Docker: docker run hello-world${RESET}"
                fi
                ;;
            "databases")
                if command -v mysql &>/dev/null || command -v mariadb &>/dev/null; then
                    echo -e "${CYAN}• Secure MariaDB: mysql_secure_installation${RESET}"
                fi
                ;;
            "development")
                echo -e "${CYAN}• Install additional language tools via their package managers${RESET}"
                echo -e "${CYAN}• Configure your IDE/editor preferences${RESET}"
                ;;
            "multimedia")
                echo -e "${CYAN}• Test multimedia codecs with sample files${RESET}"
                ;;
        esac
    done
    
    echo -e "${CYAN}• Update your system regularly: apt update && apt upgrade${RESET}"
    echo -e "${CYAN}• Explore installed applications via the application menu${RESET}"
    echo -e "${CYAN}• Consider setting up dotfiles for personalized configuration${RESET}"
}

#==============================================================================
# Main Execution
#==============================================================================

main() {
    # Module selection
    select_modules
    
    # Calculate total steps for progress tracking
    calculate_total_steps
    
    # Initialize
    initialize
    
    # User setup
    setup_user
    
    # System update
    update_system
    
    # Execute selected modules
    execute_modules
    
    # Final summary
    generate_summary
}

# Trap to handle script interruption
trap 'print_error "Script interrupted"; log "ERROR" "Script interrupted by user"; exit 1' INT TERM

# Check if modules directory exists
if [[ ! -d "$MODULES_DIR" ]]; then
    echo -e "${RED}Error: Modules directory not found at $MODULES_DIR${RESET}"
    echo "Please ensure the script is run from the correct directory with all module files present."
    exit 1
fi

# Run main function
main "$@"
