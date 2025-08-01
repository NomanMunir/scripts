#!/bin/bash

#==============================================================================
# Text Editors & IDEs Module
# Code editors, IDEs, and development environments
#==============================================================================

# Install Visual Studio Code
install_vscode() {
    if confirm_install "Visual Studio Code" "Microsoft's popular code editor"; then
        print_section "Installing Visual Studio Code"
        
        # Add Microsoft repository
        print_info "Adding Microsoft repository..."
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        install_packages code
        
        # Install useful VS Code extensions
        if [ -n "$CURRENT_USER" ] && confirm_action "Install popular VS Code extensions" "Essential extensions for development"; then
            print_info "Installing VS Code extensions for $CURRENT_USER..."
            
            local extensions=(
                "ms-python.python"
                "ms-vscode.vscode-typescript-next"
                "bradlc.vscode-tailwindcss"
                "esbenp.prettier-vscode"
                "ms-vscode.vscode-eslint"
                "ritwickdey.liveserver"
                "formulahendry.auto-rename-tag"
                "christian-kohler.path-intellisense"
                "ms-vscode.vscode-json"
                "redhat.vscode-yaml"
                "ms-vscode.vscode-markdown"
                "shd101wyy.markdown-preview-enhanced"
                "ms-vscode.theme-github-light"
                "pkief.material-icon-theme"
                "ms-vscode-remote.remote-ssh"
                "ms-vscode-remote.remote-containers"
                "ms-vscode.vscode-remote-extensionpack"
                "gitpod.gitpod-remote-ssh"
                "ms-vscode.vscode-docker"
                "hashicorp.terraform"
                "rust-lang.rust-analyzer"
                "golang.go"
                "ms-dotnettools.csharp"
                "ms-java.java-pack"
                "ms-python.jupyter"
            )
            
            for extension in "${extensions[@]}"; do
                sudo -u "$CURRENT_USER" code --install-extension "$extension" >> "$LOG_FILE" 2>&1 || true
            done
            
            print_success "VS Code extensions installed"
        fi
        
        print_success "Visual Studio Code installed"
    fi
}

# Install VSCodium (open-source VS Code)
install_vscodium() {
    if confirm_install "VSCodium" "Open-source build of VS Code without Microsoft telemetry"; then
        print_section "Installing VSCodium"
        
        # Add VSCodium repository
        print_info "Adding VSCodium repository..."
        curl -fsSL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg | gpg --dearmor -o /usr/share/keyrings/vscodium-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main" | tee /etc/apt/sources.list.d/vscodium.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        install_packages codium
        
        print_success "VSCodium installed"
    fi
}

# Install Vim and Neovim
install_vim_neovim() {
    if confirm_install "Vim & Neovim" "Powerful terminal-based text editors"; then
        print_section "Installing Vim & Neovim"
        
        local packages=(
            vim
            vim-runtime
            vim-doc
            vim-scripts
            neovim
            python3-neovim
            exuberant-ctags
            universal-ctags
        )
        
        install_packages "${packages[@]}"
        
        # Install vim-plug for Vim and Neovim
        if [ -n "$CURRENT_USER" ]; then
            print_info "Installing vim-plug for $CURRENT_USER..."
            
            # Vim
            sudo -u "$CURRENT_USER" bash -c 'curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
            
            # Neovim
            sudo -u "$CURRENT_USER" bash -c 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
            
            # Basic Vim configuration
            sudo -u "$CURRENT_USER" bash -c 'cat > ~/.vimrc << "EOF"
set nocompatible
set number
set relativenumber
set autoindent
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4
set mouse=a
set clipboard=unnamedplus
syntax on
colorscheme desert

call plug#begin()
" Popular plugins
Plug '\''vim-airline/vim-airline'\''
Plug '\''preservim/nerdtree'\''
Plug '\''junegunn/fzf.vim'\''
Plug '\''tpope/vim-fugitive'\''
Plug '\''airblade/vim-gitgutter'\''
call plug#end()

" NERDTree toggle
map <C-n> :NERDTreeToggle<CR>
EOF'
            
            print_success "Vim configuration set up for $CURRENT_USER"
        fi
        
        print_success "Vim & Neovim installed"
    fi
}

# Install Emacs
install_emacs() {
    if confirm_install "GNU Emacs" "Extensible text editor and development environment"; then
        print_section "Installing GNU Emacs"
        
        local packages=(
            emacs
            emacs-common
            emacs-el
            emacs-goodies-el
        )
        
        install_packages "${packages[@]}"
        
        # Install Doom Emacs
        if [ -n "$CURRENT_USER" ] && confirm_action "Install Doom Emacs" "Modern Emacs configuration framework"; then
            print_info "Installing Doom Emacs for $CURRENT_USER..."
            sudo -u "$CURRENT_USER" bash -c 'git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d'
            sudo -u "$CURRENT_USER" bash -c '~/.emacs.d/bin/doom install --no-config --no-env'
            
            # Add doom to PATH
            echo 'export PATH="$HOME/.emacs.d/bin:$PATH"' >> "/home/$CURRENT_USER/.bashrc"
            
            print_success "Doom Emacs installed for $CURRENT_USER"
        fi
        
        print_success "GNU Emacs installed"
    fi
}

# Install JetBrains IDEs
install_jetbrains_ides() {
    if confirm_install "JetBrains IDEs" "Professional development environments"; then
        print_section "Installing JetBrains IDEs"
        
        # Install JetBrains Toolbox (manages all JetBrains IDEs)
        if confirm_action "Install JetBrains Toolbox" "Centralized IDE manager"; then
            print_info "Installing JetBrains Toolbox..."
            
            local toolbox_url="https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.28.1.15219.tar.gz"
            download_and_install "$toolbox_url" "jetbrains-toolbox.tar.gz" "JetBrains Toolbox"
            
            if [ -f "/tmp/setup-downloads/jetbrains-toolbox.tar.gz" ]; then
                tar -xzf "/tmp/setup-downloads/jetbrains-toolbox.tar.gz" -C /opt/
                local toolbox_dir=$(find /opt -name "jetbrains-toolbox-*" -type d | head -n1)
                if [ -n "$toolbox_dir" ]; then
                    ln -sf "$toolbox_dir/jetbrains-toolbox" /usr/local/bin/jetbrains-toolbox
                    create_desktop_entry "JetBrains Toolbox" "$toolbox_dir/jetbrains-toolbox" "$toolbox_dir/jetbrains-toolbox.svg" "IDE Manager" "Development;"
                    print_success "JetBrains Toolbox installed"
                fi
            fi
        fi
        
        # Install individual IDEs via Snap
        if command_exists snap; then
            local jetbrains_ides=(
                "intellij-idea-community"
                "pycharm-community"
                "webstorm"
                "phpstorm"
                "goland"
                "clion"
                "rider"
                "rubymine"
                "datagrip"
            )
            
            echo -e "\n${CYAN}Available JetBrains IDEs:${RESET}"
            for i in "${!jetbrains_ides[@]}"; do
                echo -e "${CYAN}[$((i+1))]${RESET} ${jetbrains_ides[$i]}"
            done
            echo -e "${CYAN}[A]${RESET} Install all community editions"
            echo -e "${CYAN}[S]${RESET} Skip IDE installation"
            
            read -p "Select IDEs to install [1-${#jetbrains_ides[@]}/A/S]: " ide_choice
            
            case "${ide_choice^^}" in
                A)
                    install_snap_packages intellij-idea-community pycharm-community --classic
                    ;;
                S)
                    print_info "Skipping individual IDE installation"
                    ;;
                [1-9]*)
                    if [[ $ide_choice -ge 1 && $ide_choice -le ${#jetbrains_ides[@]} ]]; then
                        local selected_ide="${jetbrains_ides[$((ide_choice-1))]}"
                        install_snap_packages "$selected_ide" --classic
                    fi
                    ;;
            esac
        fi
        
        print_success "JetBrains IDEs installation completed"
    fi
}

# Install Sublime Text
install_sublime_text() {
    if confirm_install "Sublime Text" "Sophisticated text editor for code, markup and prose"; then
        print_section "Installing Sublime Text"
        
        # Add Sublime Text repository
        print_info "Adding Sublime Text repository..."
        curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /usr/share/keyrings/sublimehq-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/sublimehq-archive-keyring.gpg] https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        install_packages sublime-text
        
        print_success "Sublime Text installed"
    fi
}

# Install Atom (deprecated but may still be useful)
install_atom() {
    if confirm_install "GitHub Atom" "Hackable text editor (deprecated but still functional)"; then
        print_section "Installing GitHub Atom"
        
        print_warning "Note: Atom has been sunset by GitHub in favor of VS Code"
        print_info "Consider using VS Code, VSCodium, or Pulsar (Atom community fork) instead"
        
        if confirm_action "Continue with Atom installation" "Proceed despite deprecation"; then
            download_and_install "https://github.com/atom/atom/releases/download/v1.60.0/atom-amd64.deb" "atom.deb" "GitHub Atom"
        fi
    fi
}

# Install Pulsar (Atom community fork)
install_pulsar() {
    if confirm_install "Pulsar Editor" "Community-led fork of Atom editor"; then
        print_section "Installing Pulsar Editor"
        
        # Download latest Pulsar release
        local pulsar_url="https://github.com/pulsar-edit/pulsar/releases/latest/download/pulsar_1.106.0_amd64.deb"
        download_and_install "$pulsar_url" "pulsar.deb" "Pulsar Editor"
        
        print_success "Pulsar Editor installed"
    fi
}

# Install lightweight editors
install_lightweight_editors() {
    if confirm_install "Lightweight Text Editors" "Fast and simple text editors"; then
        print_section "Installing Lightweight Text Editors"
        
        local packages=(
            nano
            micro
            leafpad
            mousepad
            gedit
            kate
            kwrite
            pluma
            xed
            featherpad
            notepadqq
        )
        
        install_packages "${packages[@]}"
        
        # Install additional modern editors
        if confirm_action "Install modern terminal editors" "Helix, Kakoune, and other modern editors"; then
            local modern_editors=(
                helix
                kakoune
            )
            
            install_packages "${modern_editors[@]}"
            
            # Install via cargo if available
            if command_exists cargo && [ -n "$CURRENT_USER" ]; then
                sudo -u "$CURRENT_USER" cargo install --locked helix-term >> "$LOG_FILE" 2>&1 || true
            fi
        fi
        
        print_success "Lightweight text editors installed"
    fi
}

# Install specialized editors
install_specialized_editors() {
    if confirm_install "Specialized Editors" "Editors for specific file types and use cases"; then
        print_section "Installing Specialized Editors"
        
        # Markdown editors
        if confirm_action "Install Markdown editors" "Specialized Markdown editing tools"; then
            local markdown_editors=(
                remarkable
                ghostwriter
                typora
                mark-text
            )
            
            # Install available packages
            install_packages remarkable ghostwriter || true
            
            # Install Typora
            if confirm_action "Install Typora" "Live markdown editor (proprietary)"; then
                curl -fsSL https://typora.io/linux/public-key.asc | gpg --dearmor -o /usr/share/keyrings/typora-keyring.gpg
                echo "deb [arch=amd64 signed-by=/usr/share/keyrings/typora-keyring.gpg] https://typora.io/linux ./" | tee /etc/apt/sources.list.d/typora.list
                apt update >> "$LOG_FILE" 2>&1
                install_packages typora
            fi
        fi
        
        # LaTeX editors
        if confirm_action "Install LaTeX editors" "TeX and LaTeX document preparation"; then
            local latex_packages=(
                texlive-full
                texmaker
                texstudio
                kile
                gummi
                lyx
            )
            
            if confirm_action "Install full TeXLive distribution" "Complete LaTeX installation (large download)"; then
                install_packages "${latex_packages[@]}"
            else
                install_packages texlive texmaker
            fi
        fi
        
        # Hex editors
        if confirm_action "Install hex editors" "Binary file editing tools"; then
            local hex_editors=(
                hexedit
                ghex
                okteta
                bless
                wxhexeditor
            )
            
            install_packages "${hex_editors[@]}"
        fi
        
        print_success "Specialized editors installed"
    fi
}

# Install code formatting and linting tools
install_formatting_tools() {
    if confirm_install "Code Formatting & Linting" "Code quality and formatting tools"; then
        print_section "Installing Code Formatting & Linting Tools"
        
        local packages=(
            clang-format
            astyle
            indent
            xmllint
            tidy
            shellcheck
            yamllint
            jsonlint
        )
        
        install_packages "${packages[@]}"
        
        # Install language-specific formatters
        if command_exists npm; then
            print_info "Installing Node.js formatters..."
            npm install -g prettier eslint jshint jscs >> "$LOG_FILE" 2>&1 || true
        fi
        
        if command_exists pip3; then
            print_info "Installing Python formatters..."
            pip3 install black autopep8 yapf flake8 pylint mypy >> "$LOG_FILE" 2>&1 || true
        fi
        
        if command_exists cargo && [ -n "$CURRENT_USER" ]; then
            print_info "Installing Rust formatters..."
            sudo -u "$CURRENT_USER" cargo install rustfmt >> "$LOG_FILE" 2>&1 || true
        fi
        
        print_success "Code formatting and linting tools installed"
    fi
}

# Configure editor integrations
configure_editor_integrations() {
    if confirm_install "Editor Integrations" "Set up editor integrations and configurations"; then
        print_section "Configuring Editor Integrations"
        
        # Set up EditorConfig
        if [ -n "$CURRENT_USER" ]; then
            print_info "Setting up global EditorConfig for $CURRENT_USER..."
            sudo -u "$CURRENT_USER" bash -c 'cat > ~/.editorconfig << "EOF"
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{js,jsx,ts,tsx,json,css,scss,html,xml,yml,yaml}]
indent_style = space
indent_size = 2

[*.{py,java,c,cpp,h,hpp}]
indent_style = space
indent_size = 4

[*.{md,txt}]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
EOF'
        fi
        
        # Set up Git editor
        if [ -n "$CURRENT_USER" ] && command_exists git; then
            # Ask user for preferred editor
            echo -e "\n${CYAN}Select default Git editor:${RESET}"
            echo -e "${CYAN}[1]${RESET} nano"
            echo -e "${CYAN}[2]${RESET} vim"
            echo -e "${CYAN}[3]${RESET} code (VS Code)"
            echo -e "${CYAN}[4]${RESET} emacs"
            
            read -p "Enter your choice [1-4]: " editor_choice
            
            case "$editor_choice" in
                1) sudo -u "$CURRENT_USER" git config --global core.editor nano ;;
                2) sudo -u "$CURRENT_USER" git config --global core.editor vim ;;
                3) sudo -u "$CURRENT_USER" git config --global core.editor "code --wait" ;;
                4) sudo -u "$CURRENT_USER" git config --global core.editor emacs ;;
                *) sudo -u "$CURRENT_USER" git config --global core.editor nano ;;
            esac
            
            print_success "Git editor configured"
        fi
        
        print_success "Editor integrations configured"
    fi
}

# Main editors module execution
main() {
    print_header "Text Editors & IDEs Installation"
    
    install_vscode
    install_vscodium
    install_vim_neovim
    install_emacs
    install_jetbrains_ides
    install_sublime_text
    install_atom
    install_pulsar
    install_lightweight_editors
    install_specialized_editors
    install_formatting_tools
    configure_editor_integrations
    
    print_success "Text editors & IDEs installation completed"
    
    # Editors recommendations
    echo -e "\n${BOLD}${YELLOW}Editors Recommendations:${RESET}"
    echo -e "${CYAN}• Configure your preferred editor with plugins and themes${RESET}"
    echo -e "${CYAN}• Set up consistent code formatting across projects${RESET}"
    echo -e "${CYAN}• Learn keyboard shortcuts for efficient editing${RESET}"
    echo -e "${CYAN}• Use EditorConfig for consistent coding styles${RESET}"
    echo -e "${CYAN}• Set up linting and formatting on save${RESET}"
    echo -e "${CYAN}• Consider using a unified color scheme across tools${RESET}"
    echo -e "${CYAN}• Explore language-specific extensions and plugins${RESET}"
}

# Execute main function
main
