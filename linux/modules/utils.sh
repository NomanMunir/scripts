#!/bin/bash

#==============================================================================
# System Utilities & CLI Tools Module
# Command-line utilities, system tools, and productivity enhancers
#==============================================================================

# Install enhanced CLI tools
install_enhanced_cli_tools() {
    if confirm_install "Enhanced CLI Tools" "Modern replacements for traditional Unix tools"; then
        print_section "Installing Enhanced CLI Tools"
        
        local packages=(
            bat           # Better cat with syntax highlighting
            exa           # Better ls with colors and git integration
            fd-find       # Better find
            ripgrep       # Better grep
            fzf           # Fuzzy finder
            tree          # Directory tree view
            tldr          # Simplified man pages
            htop          # Better top
            btop          # Even better system monitor
            ncdu          # Disk usage analyzer
            duf           # Better df
            procs         # Better ps
            hyperfine     # Command-line benchmarking
            tokei         # Code statistics
            bandwhich     # Network bandwidth monitor
        )
        
        install_packages "${packages[@]}"
        
        # Install additional modern CLI tools via cargo (if Rust is available)
        if command_exists cargo; then
            print_info "Installing additional Rust-based CLI tools..."
            local rust_tools=(
                "zoxide"      # Better cd
                "starship"    # Cross-shell prompt
                "delta"       # Better git diff
                "gitui"       # Terminal git UI
                "bottom"      # System monitor
                "dust"        # Better du
                "broot"       # Tree navigator
            )
            
            for tool in "${rust_tools[@]}"; do
                if [ -n "$CURRENT_USER" ]; then
                    sudo -u "$CURRENT_USER" cargo install "$tool" >> "$LOG_FILE" 2>&1 || true
                else
                    cargo install "$tool" >> "$LOG_FILE" 2>&1 || true
                fi
            done
        fi
        
        print_success "Enhanced CLI tools installed"
    fi
}

# Install terminal multiplexers and session managers
install_terminal_tools() {
    if confirm_install "Terminal Tools & Multiplexers" "tmux, screen, and terminal session management"; then
        print_section "Installing Terminal Tools"
        
        local packages=(
            tmux
            screen
            byobu
            terminator
            tilix
            kitty
            alacritty
            zellij
        )
        
        install_packages "${packages[@]}"
        
        # Configure tmux with better defaults
        if [ -n "$CURRENT_USER" ]; then
            print_info "Setting up tmux configuration for $CURRENT_USER..."
            sudo -u "$CURRENT_USER" bash -c 'cat > ~/.tmux.conf << "EOF"
# Better prefix key
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'"'"'
unbind %

# Reload config file
bind r source-file ~/.tmux.conf

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Enable mouse mode
set -g mouse on

# Don'\''t rename windows automatically
set-option -g allow-rename off

# Start windows and panes at 1
set -g base-index 1
setw -g pane-base-index 1
EOF'
            print_success "tmux configured for $CURRENT_USER"
        fi
        
        print_success "Terminal tools installed"
    fi
}

# Install file managers and navigation tools
install_file_managers() {
    if confirm_install "File Managers & Navigation" "CLI and GUI file managers"; then
        print_section "Installing File Managers"
        
        local packages=(
            ranger        # Terminal file manager
            nnn           # Lightweight file manager
            mc            # Midnight Commander
            vifm          # Vi-like file manager
            thunar        # GTK file manager
            nautilus      # GNOME file manager
            dolphin       # KDE file manager
            pcmanfm       # Lightweight file manager
            caja          # MATE file manager
        )
        
        install_packages "${packages[@]}"
        
        # Install additional navigation tools
        if command_exists cargo && [ -n "$CURRENT_USER" ]; then
            print_info "Installing broot (interactive tree navigator)..."
            sudo -u "$CURRENT_USER" cargo install broot >> "$LOG_FILE" 2>&1 || true
        fi
        
        print_success "File managers installed"
    fi
}

# Install text processing and manipulation tools
install_text_tools() {
    if confirm_install "Text Processing Tools" "Advanced text manipulation and processing utilities"; then
        print_section "Installing Text Processing Tools"
        
        local packages=(
            awk
            sed
            grep
            sort
            uniq
            cut
            tr
            wc
            head
            tail
            less
            more
            vim
            nano
            emacs
            jq            # JSON processor
            yq            # YAML processor
            xmlstarlet    # XML processor
            csvkit        # CSV toolkit
            miller        # Data processing tool
            pandoc        # Document converter
            dos2unix      # Line ending converter
            recode        # Text encoding converter
        )
        
        install_packages "${packages[@]}"
        
        # Install additional text tools
        if command_exists pip3; then
            print_info "Installing additional Python text tools..."
            pip3 install csvkit yq >> "$LOG_FILE" 2>&1 || true
        fi
        
        print_success "Text processing tools installed"
    fi
}

# Install system monitoring and diagnostics
install_monitoring_tools() {
    if confirm_install "System Monitoring & Diagnostics" "System performance and diagnostic tools"; then
        print_section "Installing Monitoring & Diagnostic Tools"
        
        local packages=(
            htop
            btop
            iotop
            iftop
            nethogs
            nload
            vnstat
            sysstat
            atop
            glances
            dstat
            nmon
            iostat
            vmstat
            free
            lsof
            ss
            netstat
            psmisc
            pstree
            ltrace
            strace
            tcpdump
            wireshark-common
            iperf3
            speedtest-cli
            inxi
            neofetch
            screenfetch
            cpu-x
            hardinfo
        )
        
        install_packages "${packages[@]}"
        
        # Install Bashtop/Bpytop if available
        if command_exists pip3; then
            print_info "Installing bpytop..."
            pip3 install bpytop >> "$LOG_FILE" 2>&1 || true
        fi
        
        print_success "Monitoring and diagnostic tools installed"
    fi
}

# Install network utilities
install_network_utilities() {
    if confirm_install "Network Utilities" "Network diagnostic and management tools"; then
        print_section "Installing Network Utilities"
        
        local packages=(
            curl
            wget
            aria2         # Download manager
            axel          # Download accelerator
            rsync
            scp
            sftp
            ssh
            nmap
            masscan
            zmap
            hping3
            arping
            fping
            mtr           # Network diagnostic tool
            traceroute
            dig
            nslookup
            host
            whois
            netcat-openbsd
            socat
            telnet
            ftp
            lftp
            rclone        # Cloud storage sync
            s3cmd         # Amazon S3 tools
        )
        
        install_packages "${packages[@]}"
        
        print_success "Network utilities installed"
    fi
}

# Install archive and compression tools
install_archive_tools() {
    if confirm_install "Archive & Compression Tools" "Comprehensive archive format support"; then
        print_section "Installing Archive & Compression Tools"
        
        local packages=(
            tar
            gzip
            gunzip
            bzip2
            bunzip2
            xz-utils
            lzma
            zip
            unzip
            p7zip-full
            p7zip-rar
            rar
            unrar
            arj
            lha
            lzop
            zstd
            lz4
            pigz          # Parallel gzip
            pbzip2        # Parallel bzip2
            pixz          # Parallel xz
            cabextract    # Microsoft CAB files
            rpm2cpio      # RPM package extraction
        )
        
        install_packages "${packages[@]}"
        
        print_success "Archive and compression tools installed"
    fi
}

# Install data recovery and forensics tools
install_recovery_tools() {
    if confirm_install "Data Recovery & Forensics" "File recovery and digital forensics tools"; then
        print_section "Installing Data Recovery & Forensics Tools"
        
        local packages=(
            testdisk      # Partition recovery
            photorec      # File recovery
            ddrescue      # Data recovery
            gddrescue     # GNU ddrescue
            safecopy      # Data recovery tool
            foremost      # File carving
            scalpel       # File carving
            sleuthkit     # Digital forensics
            autopsy       # Digital forensics GUI
            volatility    # Memory forensics
            binwalk       # Firmware analysis
            hexedit       # Hex editor
            ghex          # GNOME hex editor
            okteta        # KDE hex editor
            bless         # Hex editor
        )
        
        install_packages "${packages[@]}"
        
        print_success "Data recovery and forensics tools installed"
        print_warning "Use these tools responsibly and in accordance with applicable laws"
    fi
}

# Install backup and synchronization tools
install_backup_tools() {
    if confirm_install "Backup & Synchronization" "Backup utilities and cloud sync tools"; then
        print_section "Installing Backup & Synchronization Tools"
        
        local packages=(
            rsync
            rclone
            duplicity
            rdiff-backup
            rsnapshot
            borgbackup
            restic
            deja-dup      # Simple backup tool
            luckybackup   # GUI for rsync
            grsync        # GUI for rsync
            unison        # File synchronizer
            syncthing     # Continuous file sync
        )
        
        install_packages "${packages[@]}"
        
        # Install cloud storage clients
        if confirm_action "Install cloud storage clients" "Dropbox, Google Drive, OneDrive clients"; then
            # Install cloud storage tools
            local cloud_packages=(
                rclone
                insync        # Google Drive client
                dropbox       # Dropbox client
            )
            
            # Dropbox
            if confirm_action "Install Dropbox" "Official Dropbox client"; then
                download_and_install "https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb" "dropbox.deb" "Dropbox"
            fi
            
            # Install via snap if available
            if command_exists snap; then
                if confirm_action "Install cloud clients via Snap" "Additional cloud storage clients"; then
                    install_snap_packages discord telegram-desktop
                fi
            fi
        fi
        
        print_success "Backup and synchronization tools installed"
    fi
}

# Install productivity and organization tools
install_productivity_tools() {
    if confirm_install "Productivity & Organization" "Task management and productivity utilities"; then
        print_section "Installing Productivity Tools"
        
        local packages=(
            task          # TaskWarrior - CLI task manager
            calcurse      # Calendar and todo
            remind        # Calendar and alarm
            wyrd          # Calendar frontend
            ledger        # Plain text accounting
            hledger       # Accounting tool
            timewarrior   # Time tracking
            watson        # Time tracking
            keepassxc     # Password manager
            pass          # CLI password manager
            qtpass        # GUI for pass
            zbar-tools    # QR code tools
            qrencode      # QR code generator
        )
        
        install_packages "${packages[@]}"
        
        # Install additional productivity tools
        if command_exists pip3; then
            print_info "Installing Python productivity tools..."
            pip3 install todotxt-machine >> "$LOG_FILE" 2>&1 || true
        fi
        
        print_success "Productivity and organization tools installed"
    fi
}

# Install shell enhancements
install_shell_enhancements() {
    if confirm_install "Shell Enhancements" "Zsh, Oh My Zsh, and shell productivity tools"; then
        print_section "Installing Shell Enhancements"
        
        local packages=(
            zsh
            fish
            bash-completion
            zsh-completions
            zsh-syntax-highlighting
            zsh-autosuggestions
            fonts-powerline
            powerline
            thefuck       # Command correction
        )
        
        install_packages "${packages[@]}"
        
        # Install Oh My Zsh for user
        if [ -n "$CURRENT_USER" ] && command_exists zsh; then
            if confirm_action "Install Oh My Zsh for $CURRENT_USER" "Popular Zsh framework"; then
                print_info "Installing Oh My Zsh for user $CURRENT_USER..."
                sudo -u "$CURRENT_USER" bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
                
                # Set Zsh as default shell
                chsh -s "$(which zsh)" "$CURRENT_USER"
                print_success "Oh My Zsh installed and Zsh set as default shell for $CURRENT_USER"
            fi
        fi
        
        # Install Starship prompt
        if confirm_action "Install Starship prompt" "Cross-shell customizable prompt"; then
            print_info "Installing Starship prompt..."
            curl -sS https://starship.rs/install.sh | sh -s -- --yes >> "$LOG_FILE" 2>&1
            
            if [ -n "$CURRENT_USER" ]; then
                # Add to shell configs
                sudo -u "$CURRENT_USER" bash -c 'echo '\''eval "$(starship init bash)"'\'' >> ~/.bashrc'
                sudo -u "$CURRENT_USER" bash -c 'echo '\''eval "$(starship init zsh)"'\'' >> ~/.zshrc' 2>/dev/null || true
            fi
            
            print_success "Starship prompt installed"
        fi
        
        print_success "Shell enhancements installed"
    fi
}

# Install development utilities
install_dev_utilities() {
    if confirm_install "Development Utilities" "Code quality, formatting, and development tools"; then
        print_section "Installing Development Utilities"
        
        local packages=(
            git-flow
            git-lfs
            tig           # Git repository browser
            gitk
            git-gui
            meld          # Diff tool
            colordiff
            icdiff        # Side-by-side diff
            editorconfig  # Code style configuration
            shellcheck    # Shell script linter
            yamllint      # YAML linter
            black         # Python formatter
            pylint        # Python linter
            flake8        # Python style checker
            mypy          # Python type checker
            clang-format  # C/C++ formatter
            astyle        # Code formatter
            indent        # C code formatter
        )
        
        install_packages "${packages[@]}"
        
        # Install additional dev tools via language package managers
        if command_exists npm; then
            print_info "Installing Node.js development utilities..."
            npm install -g eslint prettier jshint jscs nodemon live-server http-server >> "$LOG_FILE" 2>&1 || true
        fi
        
        if command_exists pip3; then
            print_info "Installing Python development utilities..."
            pip3 install pre-commit commitizen gitlint >> "$LOG_FILE" 2>&1 || true
        fi
        
        print_success "Development utilities installed"
    fi
}

# Main utils module execution
main() {
    print_header "System Utilities & CLI Tools Installation"
    
    install_enhanced_cli_tools
    install_terminal_tools
    install_file_managers
    install_text_tools
    install_monitoring_tools
    install_network_utilities
    install_archive_tools
    install_recovery_tools
    install_backup_tools
    install_productivity_tools
    install_shell_enhancements
    install_dev_utilities
    
    print_success "System utilities & CLI tools installation completed"
    
    # Utilities recommendations
    echo -e "\n${BOLD}${YELLOW}Utilities Recommendations:${RESET}"
    echo -e "${CYAN}• Explore modern CLI tools: bat, exa, fd, ripgrep, fzf${RESET}"
    echo -e "${CYAN}• Set up shell aliases for frequently used commands${RESET}"
    echo -e "${CYAN}• Configure tmux for persistent terminal sessions${RESET}"
    echo -e "${CYAN}• Use task management tools for productivity${RESET}"
    echo -e "${CYAN}• Set up automated backups with rsync or borgbackup${RESET}"
    echo -e "${CYAN}• Learn keyboard shortcuts for terminal efficiency${RESET}"
    echo -e "${CYAN}• Consider using dotfiles to manage configurations${RESET}"
}

# Execute main function
main
