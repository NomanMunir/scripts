#!/bin/bash

#==============================================================================
# Interactive Multi-Selection Module
# Provides checkbox-style CLI interface for software selection
#==============================================================================

# Additional color definitions for interactive module
readonly WHITE="\e[37m"
readonly DIM="\e[2m"

# Global variables for interactive selection
declare -A SOFTWARE_ITEMS=()
declare -A SOFTWARE_DESCRIPTIONS=()
declare -A SOFTWARE_CATEGORIES=()
declare -A SELECTED_SOFTWARE=()
SOFTWARE_LIST=()
CURRENT_SELECTION=0
CATEGORY_FILTER=""

# Initialize software catalog
init_software_catalog() {
    # Development Tools
    SOFTWARE_ITEMS["git"]="Git Version Control"
    SOFTWARE_DESCRIPTIONS["git"]="Distributed version control system"
    SOFTWARE_CATEGORIES["git"]="development"
    
    SOFTWARE_ITEMS["vscode"]="Visual Studio Code"
    SOFTWARE_DESCRIPTIONS["vscode"]="Modern code editor with extensions"
    SOFTWARE_CATEGORIES["vscode"]="development"
    
    SOFTWARE_ITEMS["docker"]="Docker & Docker Compose"
    SOFTWARE_DESCRIPTIONS["docker"]="Container platform for development"
    SOFTWARE_CATEGORIES["docker"]="development"
    
    SOFTWARE_ITEMS["nodejs"]="Node.js & NPM"
    SOFTWARE_DESCRIPTIONS["nodejs"]="JavaScript runtime and package manager"
    SOFTWARE_CATEGORIES["nodejs"]="development"
    
    SOFTWARE_ITEMS["python"]="Python Development Environment"
    SOFTWARE_DESCRIPTIONS["python"]="Python 3, pip, venv, and dev tools"
    SOFTWARE_CATEGORIES["python"]="development"
    
    SOFTWARE_ITEMS["rust"]="Rust Programming Language"
    SOFTWARE_DESCRIPTIONS["rust"]="Systems programming language with Cargo"
    SOFTWARE_CATEGORIES["rust"]="development"
    
    SOFTWARE_ITEMS["go"]="Go Programming Language"
    SOFTWARE_DESCRIPTIONS["go"]="Modern programming language by Google"
    SOFTWARE_CATEGORIES["go"]="development"
    
    SOFTWARE_ITEMS["java"]="Java Development Kit"
    SOFTWARE_DESCRIPTIONS["java"]="OpenJDK and development tools"
    SOFTWARE_CATEGORIES["java"]="development"
    
    # Browsers
    SOFTWARE_ITEMS["chrome"]="Google Chrome"
    SOFTWARE_DESCRIPTIONS["chrome"]="Popular web browser"
    SOFTWARE_CATEGORIES["chrome"]="browsers"
    
    SOFTWARE_ITEMS["firefox"]="Mozilla Firefox"
    SOFTWARE_DESCRIPTIONS["firefox"]="Open-source web browser"
    SOFTWARE_CATEGORIES["firefox"]="browsers"
    
    SOFTWARE_ITEMS["edge"]="Microsoft Edge"
    SOFTWARE_DESCRIPTIONS["edge"]="Modern web browser by Microsoft"
    SOFTWARE_CATEGORIES["edge"]="browsers"
    
    # Databases
    SOFTWARE_ITEMS["mysql"]="MySQL/MariaDB"
    SOFTWARE_DESCRIPTIONS["mysql"]="Popular relational database"
    SOFTWARE_CATEGORIES["mysql"]="databases"
    
    SOFTWARE_ITEMS["postgresql"]="PostgreSQL"
    SOFTWARE_DESCRIPTIONS["postgresql"]="Advanced relational database"
    SOFTWARE_CATEGORIES["postgresql"]="databases"
    
    SOFTWARE_ITEMS["mongodb"]="MongoDB"
    SOFTWARE_DESCRIPTIONS["mongodb"]="NoSQL document database"
    SOFTWARE_CATEGORIES["mongodb"]="databases"
    
    SOFTWARE_ITEMS["redis"]="Redis"
    SOFTWARE_DESCRIPTIONS["redis"]="In-memory data structure store"
    SOFTWARE_CATEGORIES["redis"]="databases"
    
    # Multimedia
    SOFTWARE_ITEMS["vlc"]="VLC Media Player"
    SOFTWARE_DESCRIPTIONS["vlc"]="Universal media player"
    SOFTWARE_CATEGORIES["vlc"]="multimedia"
    
    SOFTWARE_ITEMS["gimp"]="GIMP"
    SOFTWARE_DESCRIPTIONS["gimp"]="GNU Image Manipulation Program"
    SOFTWARE_CATEGORIES["gimp"]="multimedia"
    
    SOFTWARE_ITEMS["obs"]="OBS Studio"
    SOFTWARE_DESCRIPTIONS["obs"]="Live streaming and recording software"
    SOFTWARE_CATEGORIES["obs"]="multimedia"
    
    # Communication
    SOFTWARE_ITEMS["slack"]="Slack"
    SOFTWARE_DESCRIPTIONS["slack"]="Team communication platform"
    SOFTWARE_CATEGORIES["slack"]="communication"
    
    SOFTWARE_ITEMS["discord"]="Discord"
    SOFTWARE_DESCRIPTIONS["discord"]="Voice and text chat platform"
    SOFTWARE_CATEGORIES["discord"]="communication"
    
    SOFTWARE_ITEMS["teams"]="Microsoft Teams"
    SOFTWARE_DESCRIPTIONS["teams"]="Business communication platform"
    SOFTWARE_CATEGORIES["teams"]="communication"
    
    # System Utilities
    SOFTWARE_ITEMS["htop"]="htop"
    SOFTWARE_DESCRIPTIONS["htop"]="Interactive process viewer"
    SOFTWARE_CATEGORIES["htop"]="utils"
    
    SOFTWARE_ITEMS["neofetch"]="Neofetch"
    SOFTWARE_DESCRIPTIONS["neofetch"]="System information display tool"
    SOFTWARE_CATEGORIES["neofetch"]="utils"
    
    SOFTWARE_ITEMS["tmux"]="tmux"
    SOFTWARE_DESCRIPTIONS["tmux"]="Terminal multiplexer"
    SOFTWARE_CATEGORIES["tmux"]="utils"
    
    SOFTWARE_ITEMS["zsh"]="Zsh + Oh My Zsh"
    SOFTWARE_DESCRIPTIONS["zsh"]="Enhanced shell with Oh My Zsh framework"
    SOFTWARE_CATEGORIES["zsh"]="utils"
    
    # Security
    SOFTWARE_ITEMS["ufw"]="UFW Firewall"
    SOFTWARE_DESCRIPTIONS["ufw"]="Uncomplicated Firewall"
    SOFTWARE_CATEGORIES["ufw"]="security"
    
    SOFTWARE_ITEMS["fail2ban"]="Fail2Ban"
    SOFTWARE_DESCRIPTIONS["fail2ban"]="Intrusion prevention software"
    SOFTWARE_CATEGORIES["fail2ban"]="security"
    
    SOFTWARE_ITEMS["ssh"]="SSH Server"
    SOFTWARE_DESCRIPTIONS["ssh"]="OpenSSH server with hardening"
    SOFTWARE_CATEGORIES["ssh"]="security"
    
    # Generate sorted software list
    SOFTWARE_LIST=($(printf '%s\n' "${!SOFTWARE_ITEMS[@]}" | sort))
}

# Terminal control functions
hide_cursor() {
    printf '\e[?25l'
}

show_cursor() {
    printf '\e[?25h'
}

move_cursor() {
    printf '\e[%d;%dH' "$1" "$2"
}

clear_screen() {
    printf '\e[2J\e[H'
}

# Draw the interactive selection interface
draw_interface() {
    clear_screen
    
    # Header
    echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${BLUE}║                    Software Selection Interface                      ║${RESET}"
    echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    echo
    
    # Instructions
    echo -e "${CYAN}Instructions:${RESET}"
    echo -e "  ${YELLOW}↑/↓${RESET} or ${YELLOW}k/j${RESET}: Navigate"
    echo -e "  ${YELLOW}Space${RESET}: Toggle selection"
    echo -e "  ${YELLOW}Enter${RESET}: Confirm selections"
    echo -e "  ${YELLOW}a${RESET}: Select all"
    echo -e "  ${YELLOW}n${RESET}: Select none"
    echo -e "  ${YELLOW}c${RESET}: Filter by category"
    echo -e "  ${YELLOW}q${RESET}: Quit"
    echo
    
    # Category filter info
    if [[ -n "$CATEGORY_FILTER" ]]; then
        echo -e "${PURPLE}Filtered by category: ${CATEGORY_FILTER}${RESET} (press 'c' to change)"
        echo
    fi
    
    # Software list
    local visible_items=()
    for item in "${SOFTWARE_LIST[@]}"; do
        if [[ -z "$CATEGORY_FILTER" || "${SOFTWARE_CATEGORIES[$item]}" == "$CATEGORY_FILTER" ]]; then
            visible_items+=("$item")
        fi
    done
    
    if [[ ${#visible_items[@]} -eq 0 ]]; then
        echo -e "${RED}No software found for category: $CATEGORY_FILTER${RESET}"
        return
    fi
    
    # Draw software items
    for i in "${!visible_items[@]}"; do
        local item="${visible_items[$i]}"
        local selected_marker=""
        local cursor_marker="  "
        
        # Check if selected
        if [[ "${SELECTED_SOFTWARE[$item]:-}" == "1" ]]; then
            selected_marker="${GREEN}[✓]${RESET}"
        else
            selected_marker="${RED}[ ]${RESET}"
        fi
        
        # Check if current cursor position
        if [[ $i -eq $CURRENT_SELECTION ]]; then
            cursor_marker="${YELLOW}▶ ${RESET}"
        fi
        
        # Category badge
        local category="${SOFTWARE_CATEGORIES[$item]}"
        local category_color=""
        case "$category" in
            "development") category_color="${BLUE}" ;;
            "browsers") category_color="${GREEN}" ;;
            "databases") category_color="${PURPLE}" ;;
            "multimedia") category_color="${CYAN}" ;;
            "communication") category_color="${YELLOW}" ;;
            "utils") category_color="${WHITE}" ;;
            "security") category_color="${RED}" ;;
            *) category_color="${RESET}" ;;
        esac
        
        printf "%s%s ${category_color}[%s]${RESET} ${BOLD}%s${RESET}\n" \
            "$cursor_marker" "$selected_marker" "$category" "${SOFTWARE_ITEMS[$item]}"
        printf "    ${DIM}%s${RESET}\n" "${SOFTWARE_DESCRIPTIONS[$item]}"
        echo
    done
    
    # Footer with selection count
    local selected_count=$(count_selected)
    echo -e "${BOLD}${CYAN}Selected: ${selected_count} items${RESET}"
}

# Count selected items
count_selected() {
    local count=0
    for item in "${!SELECTED_SOFTWARE[@]}"; do
        if [[ "${SELECTED_SOFTWARE[$item]}" == "1" ]]; then
            ((count++))
        fi
    done
    echo $count
}

# Get visible items based on category filter
get_visible_items() {
    local visible=()
    for item in "${SOFTWARE_LIST[@]}"; do
        if [[ -z "$CATEGORY_FILTER" || "${SOFTWARE_CATEGORIES[$item]}" == "$CATEGORY_FILTER" ]]; then
            visible+=("$item")
        fi
    done
    printf '%s\n' "${visible[@]}"
}

# Handle keyboard input
handle_input() {
    local visible_items=($(get_visible_items))
    local max_index=$((${#visible_items[@]} - 1))
    
    if [[ $max_index -lt 0 ]]; then
        return
    fi
    
    while true; do
        read -rsn1 key
        
        case "$key" in
            # Arrow keys and vim-style navigation
            $'\e')
                read -rsn2 key
                case "$key" in
                    '[A'|'OA') # Up arrow
                        ((CURRENT_SELECTION > 0)) && ((CURRENT_SELECTION--))
                        ;;
                    '[B'|'OB') # Down arrow
                        ((CURRENT_SELECTION < max_index)) && ((CURRENT_SELECTION++))
                        ;;
                esac
                ;;
            'k') # Vim up
                ((CURRENT_SELECTION > 0)) && ((CURRENT_SELECTION--))
                ;;
            'j') # Vim down
                ((CURRENT_SELECTION < max_index)) && ((CURRENT_SELECTION++))
                ;;
            ' ') # Space - toggle selection
                local current_item="${visible_items[$CURRENT_SELECTION]}"
                if [[ "${SELECTED_SOFTWARE[$current_item]:-}" == "1" ]]; then
                    SELECTED_SOFTWARE["$current_item"]="0"
                else
                    SELECTED_SOFTWARE["$current_item"]="1"
                fi
                ;;
            'a') # Select all visible
                for item in "${visible_items[@]}"; do
                    SELECTED_SOFTWARE["$item"]="1"
                done
                ;;
            'n') # Select none
                for item in "${visible_items[@]}"; do
                    SELECTED_SOFTWARE["$item"]="0"
                done
                ;;
            'c') # Category filter
                show_category_menu
                visible_items=($(get_visible_items))
                max_index=$((${#visible_items[@]} - 1))
                CURRENT_SELECTION=0
                ;;
            $'\n') # Enter - confirm
                return 0
                ;;
            'q') # Quit
                return 1
                ;;
        esac
        
        draw_interface
    done
}

# Show category selection menu
show_category_menu() {
    clear_screen
    echo -e "${BOLD}${BLUE}Select Category Filter:${RESET}\n"
    
    local categories=("all" "development" "browsers" "databases" "multimedia" "communication" "utils" "security")
    local current_cat_selection=0
    
    while true; do
        # Clear and redraw category menu
        move_cursor 3 1
        for i in "${!categories[@]}"; do
            local cat="${categories[$i]}"
            local marker="  "
            if [[ $i -eq $current_cat_selection ]]; then
                marker="${YELLOW}▶ ${RESET}"
            fi
            
            if [[ "$cat" == "all" ]]; then
                printf "%s${BOLD}All Categories${RESET}\n" "$marker"
            else
                printf "%s${BOLD}%s${RESET}\n" "$marker" "${cat^}"
            fi
        done
        
        echo -e "\n${CYAN}Press Enter to select, q to cancel${RESET}"
        
        read -rsn1 key
        case "$key" in
            $'\e')
                read -rsn2 key
                case "$key" in
                    '[A'|'OA') # Up
                        ((current_cat_selection > 0)) && ((current_cat_selection--))
                        ;;
                    '[B'|'OB') # Down
                        ((current_cat_selection < ${#categories[@]} - 1)) && ((current_cat_selection++))
                        ;;
                esac
                ;;
            'k')
                ((current_cat_selection > 0)) && ((current_cat_selection--))
                ;;
            'j')
                ((current_cat_selection < ${#categories[@]} - 1)) && ((current_cat_selection++))
                ;;
            $'\n') # Enter
                local selected_cat="${categories[$current_cat_selection]}"
                if [[ "$selected_cat" == "all" ]]; then
                    CATEGORY_FILTER=""
                else
                    CATEGORY_FILTER="$selected_cat"
                fi
                return
                ;;
            'q')
                return
                ;;
        esac
    done
}

# Main interactive selection function
interactive_software_selection() {
    init_software_catalog
    
    # Initialize all software as unselected
    for item in "${SOFTWARE_LIST[@]}"; do
        SELECTED_SOFTWARE["$item"]="0"
    done
    
    hide_cursor
    trap 'show_cursor; clear_screen' EXIT
    
    draw_interface
    
    if handle_input; then
        show_cursor
        clear_screen
        
        # Show selected items
        echo -e "${BOLD}${GREEN}Selected Software:${RESET}\n"
        local has_selections=false
        for item in "${SOFTWARE_LIST[@]}"; do
            if [[ "${SELECTED_SOFTWARE[$item]:-}" == "1" ]]; then
                echo -e "  ${GREEN}✓${RESET} ${SOFTWARE_ITEMS[$item]} - ${SOFTWARE_DESCRIPTIONS[$item]}"
                has_selections=true
            fi
        done
        
        if [[ "$has_selections" == "false" ]]; then
            echo -e "${YELLOW}No software selected.${RESET}"
            return 1
        fi
        
        echo
        if confirm_action "Proceed with Installation" "Install all selected software"; then
            return 0
        else
            return 1
        fi
    else
        show_cursor
        clear_screen
        echo -e "${YELLOW}Installation cancelled.${RESET}"
        return 1
    fi
}

# Get list of selected software
get_selected_software() {
    local selected=()
    for item in "${SOFTWARE_LIST[@]}"; do
        if [[ "${SELECTED_SOFTWARE[$item]:-}" == "1" ]]; then
            selected+=("$item")
        fi
    done
    printf '%s\n' "${selected[@]}"
}

# Install selected software
install_selected_software() {
    local selected_items=($(get_selected_software))
    
    if [[ ${#selected_items[@]} -eq 0 ]]; then
        print_warning "No software selected for installation"
        return 1
    fi
    
    print_header "Installing Selected Software"
    
    local total_items=${#selected_items[@]}
    local current_item=0
    
    for item in "${selected_items[@]}"; do
        ((current_item++))
        show_progress $current_item $total_items "Installing ${SOFTWARE_ITEMS[$item]}"
        
        case "$item" in
            "git")
                install_git
                ;;
            "vscode")
                install_vscode
                ;;
            "docker")
                install_docker_interactive
                ;;
            "nodejs")
                install_nodejs_interactive
                ;;
            "python")
                install_python_interactive
                ;;
            "rust")
                install_rust_interactive
                ;;
            "go")
                install_go_interactive
                ;;
            "java")
                install_java_interactive
                ;;
            "chrome")
                install_chrome
                ;;
            "firefox")
                install_firefox
                ;;
            "edge")
                install_edge
                ;;
            "mysql")
                install_mysql_interactive
                ;;
            "postgresql")
                install_postgresql_interactive
                ;;
            "mongodb")
                install_mongodb_interactive
                ;;
            "redis")
                install_redis_interactive
                ;;
            "vlc")
                install_vlc
                ;;
            "gimp")
                install_gimp
                ;;
            "obs")
                install_obs
                ;;
            "slack")
                install_slack
                ;;
            "discord")
                install_discord
                ;;
            "teams")
                install_teams
                ;;
            "htop")
                install_htop
                ;;
            "neofetch")
                install_neofetch
                ;;
            "tmux")
                install_tmux
                ;;
            "zsh")
                install_zsh_interactive
                ;;
            "ufw")
                install_ufw_interactive
                ;;
            "fail2ban")
                install_fail2ban_interactive
                ;;
            "ssh")
                install_ssh_interactive
                ;;
            *)
                print_warning "Unknown software item: $item"
                ;;
        esac
        
        sleep 0.5  # Small delay for better UX
    done
    
    print_success "All selected software installation completed!"
}

# Individual installation functions (simplified versions)
install_git() {
    install_packages git
}

install_vscode() {
    print_info "Installing Visual Studio Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
    apt update >> "$LOG_FILE" 2>&1
    install_packages code
}

install_docker_interactive() {
    # Add Docker repository
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update >> "$LOG_FILE" 2>&1
    install_packages docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    if [ -n "$CURRENT_USER" ]; then
        usermod -aG docker "$CURRENT_USER"
    fi
}

install_nodejs_interactive() {
    # Install Node.js via NodeSource
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - >> "$LOG_FILE" 2>&1
    install_packages nodejs
}

install_python_interactive() {
    install_packages python3 python3-pip python3-venv python3-dev
}

install_rust_interactive() {
    if [ -n "$CURRENT_USER" ]; then
        sudo -u "$CURRENT_USER" bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y' >> "$LOG_FILE" 2>&1
    fi
}

install_go_interactive() {
    local go_version="1.21.3"
    wget "https://golang.org/dl/go${go_version}.linux-amd64.tar.gz" -O /tmp/go.tar.gz >> "$LOG_FILE" 2>&1
    rm -rf /usr/local/go
    tar -C /usr/local -xzf /tmp/go.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile.d/go.sh
    rm /tmp/go.tar.gz
}

install_java_interactive() {
    install_packages openjdk-17-jdk openjdk-17-jre
}

install_chrome() {
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - >> "$LOG_FILE" 2>&1
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
    apt update >> "$LOG_FILE" 2>&1
    install_packages google-chrome-stable
}

install_firefox() {
    install_packages firefox-esr
}

install_edge() {
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list
    apt update >> "$LOG_FILE" 2>&1
    install_packages microsoft-edge-stable
}

install_mysql_interactive() {
    install_packages mariadb-server mariadb-client
    systemctl enable mariadb >> "$LOG_FILE" 2>&1
    systemctl start mariadb >> "$LOG_FILE" 2>&1
}

install_postgresql_interactive() {
    install_packages postgresql postgresql-contrib
    systemctl enable postgresql >> "$LOG_FILE" 2>&1
    systemctl start postgresql >> "$LOG_FILE" 2>&1
}

install_mongodb_interactive() {
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - >> "$LOG_FILE" 2>&1
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    apt update >> "$LOG_FILE" 2>&1
    install_packages mongodb-org
}

install_redis_interactive() {
    install_packages redis-server
    systemctl enable redis-server >> "$LOG_FILE" 2>&1
    systemctl start redis-server >> "$LOG_FILE" 2>&1
}

install_vlc() {
    install_packages vlc
}

install_gimp() {
    install_packages gimp
}

install_obs() {
    add-apt-repository ppa:obsproject/obs-studio -y >> "$LOG_FILE" 2>&1
    apt update >> "$LOG_FILE" 2>&1
    install_packages obs-studio
}

install_slack() {
    wget https://downloads.slack-edge.com/releases/linux/4.29.149/prod/x64/slack-desktop-4.29.149-amd64.deb -O /tmp/slack.deb >> "$LOG_FILE" 2>&1
    dpkg -i /tmp/slack.deb >> "$LOG_FILE" 2>&1 || apt-get install -f -y >> "$LOG_FILE" 2>&1
    rm /tmp/slack.deb
}

install_discord() {
    wget "https://discord.com/api/download?platform=linux&format=deb" -O /tmp/discord.deb >> "$LOG_FILE" 2>&1
    dpkg -i /tmp/discord.deb >> "$LOG_FILE" 2>&1 || apt-get install -f -y >> "$LOG_FILE" 2>&1
    rm /tmp/discord.deb
}

install_teams() {
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" > /etc/apt/sources.list.d/teams.list
    apt update >> "$LOG_FILE" 2>&1
    install_packages teams
}

install_htop() {
    install_packages htop
}

install_neofetch() {
    install_packages neofetch
}

install_tmux() {
    install_packages tmux
}

install_zsh_interactive() {
    install_packages zsh
    # Install Oh My Zsh for the user
    if [ -n "$CURRENT_USER" ]; then
        sudo -u "$CURRENT_USER" bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended' >> "$LOG_FILE" 2>&1
        chsh -s /bin/zsh "$CURRENT_USER"
    fi
}

install_ufw_interactive() {
    install_packages ufw
    ufw allow 22/tcp >> "$LOG_FILE" 2>&1
    ufw allow 80/tcp >> "$LOG_FILE" 2>&1
    ufw allow 443/tcp >> "$LOG_FILE" 2>&1
    ufw --force enable >> "$LOG_FILE" 2>&1
}

install_fail2ban_interactive() {
    install_packages fail2ban
    systemctl enable fail2ban >> "$LOG_FILE" 2>&1
    systemctl start fail2ban >> "$LOG_FILE" 2>&1
}

install_ssh_interactive() {
    install_packages openssh-server
    systemctl enable ssh >> "$LOG_FILE" 2>&1
    systemctl start ssh >> "$LOG_FILE" 2>&1
    configure_ssh_safely
}
