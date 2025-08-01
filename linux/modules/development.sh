#!/bin/bash

#==============================================================================
# Development Tools & Languages Module
# Programming languages, compilers, interpreters, and development utilities
#==============================================================================

# Install compilers and build tools
install_compilers() {
    if confirm_install "Compilers & Build Tools" "GCC, Clang, Make, CMake, and build essentials"; then
        print_section "Installing Compilers & Build Tools"
        
        local packages=(
            gcc
            g++
            clang
            clang++
            make
            cmake
            ninja-build
            autoconf
            automake
            libtool
            pkg-config
            gdb
            valgrind
            strace
            ltrace
            objdump
            nm
            readelf
            ldd
            file
            xxd
            hexdump
        )
        
        install_packages "${packages[@]}"
        
        # Install additional development libraries
        local dev_packages=(
            libc6-dev
            linux-libc-dev
            libssl-dev
            libffi-dev
            libxml2-dev
            libxslt1-dev
            libcurl4-openssl-dev
            libsqlite3-dev
            libreadline-dev
            libbz2-dev
            libncurses5-dev
            libncursesw5-dev
            liblzma-dev
            zlib1g-dev
        )
        
        install_packages "${dev_packages[@]}"
    fi
}

# Install Python development environment
install_python() {
    if confirm_install "Python Development Environment" "Python 3, pip, venv, and popular packages"; then
        print_section "Installing Python Development Environment"
        
        local packages=(
            python3
            python3-pip
            python3-venv
            python3-dev
            python3-setuptools
            python3-wheel
            python-is-python3
            ipython3
            python3-pytest
            python3-flake8
            python3-black
            python3-autopep8
            python3-mypy
        )
        
        install_packages "${packages[@]}"
        
        # Install Poetry (Python dependency manager)
        if confirm_action "Install Poetry" "Modern Python dependency management"; then
            print_info "Installing Poetry..."
            if curl -sSL https://install.python-poetry.org | python3 - >> "$LOG_FILE" 2>&1; then
                print_success "Poetry installed successfully"
                # Add Poetry to PATH for all users
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> /etc/profile.d/poetry.sh
            else
                print_warning "Failed to install Poetry"
            fi
        fi
        
        # Install pipx for isolated Python apps
        print_info "Installing pipx..."
        python3 -m pip install --user pipx >> "$LOG_FILE" 2>&1
        if [ -n "$CURRENT_USER" ]; then
            sudo -u "$CURRENT_USER" python3 -m pipx ensurepath >> "$LOG_FILE" 2>&1
        fi
        
        # Set up Python alternatives if multiple versions exist
        if command_exists python3 && ! command_exists python; then
            update-alternatives --install /usr/bin/python python /usr/bin/python3 1
        fi
    fi
}

# Install Node.js and npm
install_nodejs() {
    if confirm_install "Node.js Development Environment" "Node.js, npm, yarn, and development tools"; then
        print_section "Installing Node.js Development Environment"
        
        # Install Node.js from NodeSource repository for latest LTS
        print_info "Adding NodeSource repository..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - >> "$LOG_FILE" 2>&1
        
        install_packages nodejs
        
        # Install Yarn
        print_info "Installing Yarn package manager..."
        npm install -g yarn >> "$LOG_FILE" 2>&1
        
        # Install common global packages
        if confirm_action "Install common Node.js global packages" "typescript, eslint, prettier, nodemon, pm2"; then
            print_info "Installing global Node.js packages..."
            local global_packages=(
                typescript
                ts-node
                eslint
                prettier
                nodemon
                pm2
                live-server
                http-server
                json-server
                create-react-app
                @vue/cli
                @angular/cli
                express-generator
            )
            
            for package in "${global_packages[@]}"; do
                npm install -g "$package" >> "$LOG_FILE" 2>&1 || true
            done
            print_success "Global Node.js packages installed"
        fi
        
        # Install pnpm
        if confirm_action "Install pnpm" "Fast, disk space efficient package manager"; then
            npm install -g pnpm >> "$LOG_FILE" 2>&1
            print_success "pnpm installed"
        fi
    fi
}

# Install Rust programming language
install_rust() {
    if confirm_install "Rust Programming Language" "Rust compiler, Cargo, and toolchain"; then
        print_section "Installing Rust Programming Language"
        
        print_info "Installing Rust via rustup..."
        if [ -n "$CURRENT_USER" ]; then
            sudo -u "$CURRENT_USER" bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable'
            
            # Add Rust to PATH for the user
            echo 'source $HOME/.cargo/env' >> "/home/$CURRENT_USER/.bashrc"
            echo 'source $HOME/.cargo/env' >> "/home/$CURRENT_USER/.profile"
            
            # Install common Rust tools
            sudo -u "$CURRENT_USER" bash -c 'source $HOME/.cargo/env && cargo install ripgrep fd-find bat exa tokei cargo-watch cargo-edit cargo-outdated'
            
            print_success "Rust installed for user $CURRENT_USER"
        else
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
            source ~/.cargo/env
            print_success "Rust installed system-wide"
        fi
    fi
}

# Install Go programming language
install_golang() {
    if confirm_install "Go Programming Language" "Go compiler and tools"; then
        print_section "Installing Go Programming Language"
        
        # Get latest Go version
        local go_version=$(curl -s https://api.github.com/repos/golang/go/releases/latest | jq -r '.tag_name' | sed 's/go//')
        local arch=$(get_architecture)
        
        case "$arch" in
            amd64) go_arch="amd64" ;;
            arm64) go_arch="arm64" ;;
            armhf) go_arch="armv6l" ;;
            *) go_arch="amd64" ;;
        esac
        
        local go_url="https://golang.org/dl/go${go_version}.linux-${go_arch}.tar.gz"
        
        print_info "Downloading Go ${go_version}..."
        if curl -L "$go_url" -o "/tmp/go${go_version}.tar.gz" >> "$LOG_FILE" 2>&1; then
            print_info "Installing Go..."
            rm -rf /usr/local/go
            tar -C /usr/local -xzf "/tmp/go${go_version}.tar.gz"
            
            # Add Go to PATH
            echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/go.sh
            echo 'export GOPATH=$HOME/go' >> /etc/profile.d/go.sh
            echo 'export PATH=$PATH:$GOPATH/bin' >> /etc/profile.d/go.sh
            
            print_success "Go ${go_version} installed successfully"
            
            # Install common Go tools
            if [ -n "$CURRENT_USER" ]; then
                print_info "Installing Go tools..."
                sudo -u "$CURRENT_USER" bash -c 'export PATH=$PATH:/usr/local/go/bin && go install golang.org/x/tools/cmd/goimports@latest'
                sudo -u "$CURRENT_USER" bash -c 'export PATH=$PATH:/usr/local/go/bin && go install golang.org/x/tools/cmd/godoc@latest'
                sudo -u "$CURRENT_USER" bash -c 'export PATH=$PATH:/usr/local/go/bin && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest'
            fi
        else
            print_error "Failed to download Go"
        fi
        
        rm -f "/tmp/go${go_version}.tar.gz"
    fi
}

# Install Java development environment
install_java() {
    if confirm_install "Java Development Environment" "OpenJDK, Maven, Gradle"; then
        print_section "Installing Java Development Environment"
        
        local packages=(
            default-jdk
            default-jre
            maven
            gradle
            ant
        )
        
        install_packages "${packages[@]}"
        
        # Install SDKMAN for managing Java versions
        if confirm_action "Install SDKMAN" "Software Development Kit Manager for Java ecosystem"; then
            if [ -n "$CURRENT_USER" ]; then
                print_info "Installing SDKMAN for user $CURRENT_USER..."
                sudo -u "$CURRENT_USER" bash -c 'curl -s "https://get.sdkman.io" | bash'
                print_success "SDKMAN installed for user $CURRENT_USER"
            fi
        fi
    fi
}

# Install .NET development environment
install_dotnet() {
    if confirm_install ".NET Development Environment" "Microsoft .NET SDK and runtime"; then
        print_section "Installing .NET Development Environment"
        
        # Add Microsoft repository
        print_info "Adding Microsoft repository..."
        wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb >> "$LOG_FILE" 2>&1
        install_deb_package packages-microsoft-prod.deb "Microsoft packages repository"
        rm -f packages-microsoft-prod.deb
        
        apt update >> "$LOG_FILE" 2>&1
        
        local packages=(
            dotnet-sdk-8.0
            aspnetcore-runtime-8.0
            dotnet-runtime-8.0
        )
        
        install_packages "${packages[@]}"
    fi
}

# Install Ruby development environment
install_ruby() {
    if confirm_install "Ruby Development Environment" "Ruby, RubyGems, Bundler, and rbenv"; then
        print_section "Installing Ruby Development Environment"
        
        local packages=(
            ruby
            ruby-dev
            rubygems
            bundler
            rake
            irb
        )
        
        install_packages "${packages[@]}"
        
        # Install rbenv for Ruby version management
        if confirm_action "Install rbenv" "Ruby version manager"; then
            if [ -n "$CURRENT_USER" ]; then
                print_info "Installing rbenv for user $CURRENT_USER..."
                sudo -u "$CURRENT_USER" bash -c 'curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash'
                
                # Add rbenv to PATH
                echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> "/home/$CURRENT_USER/.bashrc"
                echo 'eval "$(rbenv init -)"' >> "/home/$CURRENT_USER/.bashrc"
                
                print_success "rbenv installed for user $CURRENT_USER"
            fi
        fi
    fi
}

# Install PHP development environment
install_php() {
    if confirm_install "PHP Development Environment" "PHP, Composer, and common extensions"; then
        print_section "Installing PHP Development Environment"
        
        local packages=(
            php
            php-cli
            php-fpm
            php-common
            php-mysql
            php-zip
            php-gd
            php-mbstring
            php-curl
            php-xml
            php-pear
            php-bcmath
            php-json
            php-intl
            php-sqlite3
            php-dev
            php-xdebug
        )
        
        install_packages "${packages[@]}"
        
        # Install Composer
        print_info "Installing Composer..."
        curl -sS https://getcomposer.org/installer | php >> "$LOG_FILE" 2>&1
        mv composer.phar /usr/local/bin/composer
        chmod +x /usr/local/bin/composer
        print_success "Composer installed"
    fi
}

# Install version control systems
install_version_control() {
    if confirm_install "Version Control Systems" "Git, Mercurial, Subversion, and Git tools"; then
        print_section "Installing Version Control Systems"
        
        local packages=(
            git
            git-lfs
            git-flow
            mercurial
            subversion
            bzr
            tig
            gitk
            git-gui
            gitg
            meld
        )
        
        install_packages "${packages[@]}"
        
        # Install GitHub CLI
        if confirm_action "Install GitHub CLI" "Official GitHub command-line tool"; then
            print_info "Installing GitHub CLI..."
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            apt update >> "$LOG_FILE" 2>&1
            install_packages gh
        fi
        
        # Install GitLab CLI
        if confirm_action "Install GitLab CLI" "Official GitLab command-line tool"; then
            print_info "Installing GitLab CLI..."
            curl -L "https://gitlab.com/gitlab-org/cli/-/releases/v1.36.0/downloads/glab_1.36.0_Linux_x86_64.tar.gz" | tar -xz -C /tmp
            mv /tmp/bin/glab /usr/local/bin/
            chmod +x /usr/local/bin/glab
            print_success "GitLab CLI installed"
        fi
    fi
}

# Install debugging and profiling tools
install_debugging_tools() {
    if confirm_install "Debugging & Profiling Tools" "Advanced debugging and performance analysis tools"; then
        print_section "Installing Debugging & Profiling Tools"
        
        local packages=(
            gdb
            gdb-multiarch
            cgdb
            ddd
            valgrind
            callgrind
            massif
            perf-tools-unstable
            strace
            ltrace
            tcpdump
            wireshark-common
            hexedit
            okteta
            radare2
            binwalk
            foremost
            sleuthkit
        )
        
        install_packages "${packages[@]}"
    fi
}

# Install API development tools
install_api_tools() {
    if confirm_install "API Development Tools" "Postman, Insomnia, curl, HTTPie"; then
        print_section "Installing API Development Tools"
        
        # Install HTTPie and curl-based tools
        local packages=(
            curl
            httpie
            jq
            yq
        )
        
        install_packages "${packages[@]}"
        
        # Install Postman
        if confirm_action "Install Postman" "Popular API development environment"; then
            download_and_install "https://dl.pstmn.io/download/latest/linux64" "postman.tar.gz" "Postman"
            
            if [ -f "/tmp/setup-downloads/postman.tar.gz" ]; then
                tar -xzf "/tmp/setup-downloads/postman.tar.gz" -C /opt/
                ln -sf /opt/Postman/Postman /usr/local/bin/postman
                
                create_desktop_entry "Postman" "/opt/Postman/Postman" "/opt/Postman/app/resources/app/assets/icon.png" "API Development Environment" "Development;Network;"
                print_success "Postman installed"
            fi
        fi
        
        # Install Insomnia
        if confirm_action "Install Insomnia" "Modern REST client"; then
            echo "deb [trusted=yes arch=amd64] https://download.konghq.com/insomnia-ubuntu/ default all" | tee -a /etc/apt/sources.list.d/insomnia.list
            apt update >> "$LOG_FILE" 2>&1
            install_packages insomnia
        fi
    fi
}

# Main development module execution
main() {
    print_header "Development Tools & Languages Installation"
    
    install_compilers
    install_python
    install_nodejs
    install_rust
    install_golang
    install_java
    install_dotnet
    install_ruby
    install_php
    install_version_control
    install_debugging_tools
    install_api_tools
    
    print_success "Development tools & languages installation completed"
    
    # Development recommendations
    echo -e "\n${BOLD}${YELLOW}Development Recommendations:${RESET}"
    echo -e "${CYAN}• Configure Git: git config --global user.name 'Your Name'${RESET}"
    echo -e "${CYAN}• Configure Git: git config --global user.email 'your.email@example.com'${RESET}"
    echo -e "${CYAN}• Set up SSH keys for Git: ssh-keygen -t ed25519${RESET}"
    echo -e "${CYAN}• Explore language-specific package managers (pip, npm, cargo, etc.)${RESET}"
    echo -e "${CYAN}• Consider setting up development environments with Docker${RESET}"
}

# Execute main function
main
