#!/bin/bash

#==============================================================================
# Core System Components Module
# Essential system utilities and basic tools
#==============================================================================

# Core system packages installation
install_core_system_packages() {
    if confirm_install "Essential System Utilities" "Basic tools: curl, wget, git, zip, unzip, build-essential, software-properties-common"; then
        print_section "Installing Essential System Utilities"
        
        local packages=(
            curl
            wget
            git
            zip
            unzip
            build-essential
            software-properties-common
            apt-transport-https
            ca-certificates
            gnupg
            lsb-release
            dirmngr
            gpg-agent
            software-properties-common
            dpkg-dev
            pkg-config
            autoconf
            automake
            libtool
            make
            cmake
            ninja-build
        )
        
        install_packages "${packages[@]}"
        
        # Configure Git with safe defaults if user exists
        if [ -n "$CURRENT_USER" ]; then
            print_info "Setting up Git configuration for $CURRENT_USER..."
            sudo -u "$CURRENT_USER" git config --global init.defaultBranch main
            sudo -u "$CURRENT_USER" git config --global pull.rebase false
            sudo -u "$CURRENT_USER" git config --global core.autocrlf input
            print_success "Git configured with safe defaults"
        fi
    fi
}

# Install networking and system monitoring tools
install_networking_tools() {
    if confirm_install "Networking & System Monitoring" "Tools: net-tools, iputils-ping, dnsutils, traceroute, netstat, ss, htop, iotop, neofetch"; then
        print_section "Installing Networking & System Monitoring Tools"
        
        local packages=(
            net-tools
            iputils-ping
            dnsutils
            traceroute
            netcat-openbsd
            nmap
            whois
            curl
            wget
            rsync
            htop
            iotop
            neofetch
            tree
            lsof
            strace
            tcpdump
        )
        
        install_packages "${packages[@]}"
    fi
}

# Install compression and archive tools
install_compression_tools() {
    if confirm_install "Compression & Archive Tools" "Tools: tar, gzip, bzip2, xz, 7zip, rar, p7zip"; then
        print_section "Installing Compression & Archive Tools"
        
        local packages=(
            tar
            gzip
            bzip2
            xz-utils
            p7zip-full
            p7zip-rar
            unrar
            zip
            unzip
            zstd
            lz4
            pigz
            pbzip2
        )
        
        install_packages "${packages[@]}"
    fi
}

# Install text processing utilities
install_text_utilities() {
    if confirm_install "Text Processing Utilities" "Tools: grep, sed, awk, sort, cut, tr, jq, yq, xmlstarlet"; then
        print_section "Installing Text Processing Utilities"
        
        local packages=(
            grep
            sed
            gawk
            coreutils
            findutils
            diffutils
            patch
            jq
            xmlstarlet
            dos2unix
            iconv
        )
        
        install_packages "${packages[@]}"
        
        # Install yq (YAML processor) from GitHub
        if command_exists curl; then
            print_info "Installing yq (YAML processor)..."
            local arch=$(get_architecture)
            case "$arch" in
                amd64) arch="amd64" ;;
                arm64) arch="arm64" ;;
                armhf) arch="arm" ;;
                *) arch="amd64" ;;
            esac
            
            local yq_url="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${arch}"
            if curl -L "$yq_url" -o /usr/local/bin/yq >> "$LOG_FILE" 2>&1; then
                chmod +x /usr/local/bin/yq
                print_success "yq installed successfully"
            else
                print_warning "Failed to install yq"
            fi
        fi
    fi
}

# Install system utilities
install_system_utilities() {
    if confirm_install "System Utilities" "Tools: systemd utilities, cron, logrotate, rsyslog, sudo, passwd utilities"; then
        print_section "Installing System Utilities"
        
        local packages=(
            sudo
            cron
            rsyslog
            logrotate
            systemd
            systemd-timesyncd
            acl
            attr
            file
            which
            locate
            mlocate
            man-db
            manpages
            info
            less
            more
            psmisc
            procps
            util-linux
            uuid-runtime
        )
        
        install_packages "${packages[@]}"
        
        # Update locate database
        print_info "Updating locate database..."
        updatedb >> "$LOG_FILE" 2>&1 || true
    fi
}

# Install hardware utilities
install_hardware_utilities() {
    if confirm_install "Hardware Utilities" "Tools: lshw, lscpu, lsusb, lspci, hdparm, smartmontools, dmidecode"; then
        print_section "Installing Hardware Utilities"
        
        local packages=(
            lshw
            lscpu
            usbutils
            pciutils
            hdparm
            smartmontools
            dmidecode
            hwinfo
            inxi
            cpuid
            memtester
            stress-ng
            sysbench
        )
        
        install_packages "${packages[@]}"
    fi
}

# Install performance monitoring tools
install_performance_tools() {
    if confirm_install "Performance Monitoring" "Tools: top, htop, iotop, iftop, nethogs, glances, atop"; then
        print_section "Installing Performance Monitoring Tools"
        
        local packages=(
            htop
            iotop
            iftop
            nethogs
            glances
            atop
            sysstat
            dstat
            nmon
            collectl
            bmon
            vnstat
            jnettop
        )
        
        install_packages "${packages[@]}"
        
        # Enable sysstat service for system statistics
        if systemctl enable sysstat >> "$LOG_FILE" 2>&1; then
            print_success "sysstat service enabled"
        fi
    fi
}

# Main core module execution
main() {
    print_header "Core System Components Installation"
    
    install_core_system_packages
    install_networking_tools
    install_compression_tools
    install_text_utilities
    install_system_utilities
    install_hardware_utilities
    install_performance_tools
    
    print_success "Core system components installation completed"
}

# Execute main function
main
