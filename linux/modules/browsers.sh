#!/bin/bash

#==============================================================================
# Web Browsers Module
# Modern web browsers and browser-related tools
#==============================================================================

# Install Firefox
install_firefox() {
    if confirm_install "Mozilla Firefox" "Open-source web browser with privacy focus"; then
        print_section "Installing Mozilla Firefox"
        
        local packages=(
            firefox
            firefox-locale-en
        )
        
        install_packages "${packages[@]}"
        
        # Install Firefox Developer Edition
        if confirm_action "Install Firefox Developer Edition" "Browser with developer tools and features"; then
            print_info "Installing Firefox Developer Edition..."
            
            # Download and install Firefox Developer Edition
            local firefox_dev_url="https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US"
            mkdir -p /opt/firefox-dev
            
            if curl -L "$firefox_dev_url" -o /tmp/firefox-dev.tar.bz2 >> "$LOG_FILE" 2>&1; then
                tar -xjf /tmp/firefox-dev.tar.bz2 -C /opt/firefox-dev --strip-components=1
                ln -sf /opt/firefox-dev/firefox /usr/local/bin/firefox-dev
                
                create_desktop_entry "Firefox Developer Edition" "/opt/firefox-dev/firefox" "/opt/firefox-dev/browser/chrome/icons/default/default128.png" "Web Browser for Developers" "Network;WebBrowser;"
                
                print_success "Firefox Developer Edition installed"
            else
                print_error "Failed to download Firefox Developer Edition"
            fi
            
            rm -f /tmp/firefox-dev.tar.bz2
        fi
        
        print_success "Firefox installation completed"
    fi
}

# Install Google Chrome
install_chrome() {
    if confirm_install "Google Chrome" "Popular web browser by Google"; then
        print_section "Installing Google Chrome"
        
        # Add Google Chrome repository
        print_info "Adding Google Chrome repository..."
        curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        # Ask for Chrome variant
        echo -e "\n${CYAN}Select Google Chrome variant:${RESET}"
        echo -e "${CYAN}[1]${RESET} Chrome Stable (recommended)"
        echo -e "${CYAN}[2]${RESET} Chrome Beta"
        echo -e "${CYAN}[3]${RESET} Chrome Unstable (Dev)"
        
        read -p "Enter your choice [1-3]: " chrome_choice
        
        case "$chrome_choice" in
            1) install_packages google-chrome-stable ;;
            2) install_packages google-chrome-beta ;;
            3) install_packages google-chrome-unstable ;;
            *) install_packages google-chrome-stable ;;
        esac
        
        print_success "Google Chrome installed"
    fi
}

# Install Chromium
install_chromium() {
    if confirm_install "Chromium Browser" "Open-source browser that Chrome is based on"; then
        print_section "Installing Chromium Browser"
        
        local packages=(
            chromium-browser
            chromium-codecs-ffmpeg-extra
        )
        
        install_packages "${packages[@]}"
        
        print_success "Chromium browser installed"
    fi
}

# Install Microsoft Edge
install_edge() {
    if confirm_install "Microsoft Edge" "Microsoft's modern web browser"; then
        print_section "Installing Microsoft Edge"
        
        # Add Microsoft Edge repository
        print_info "Adding Microsoft Edge repository..."
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-edge-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge-keyring.gpg] https://packages.microsoft.com/repos/edge stable main" | tee /etc/apt/sources.list.d/microsoft-edge.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        # Ask for Edge variant
        echo -e "\n${CYAN}Select Microsoft Edge variant:${RESET}"
        echo -e "${CYAN}[1]${RESET} Edge Stable (recommended)"
        echo -e "${CYAN}[2]${RESET} Edge Beta"
        echo -e "${CYAN}[3]${RESET} Edge Dev"
        
        read -p "Enter your choice [1-3]: " edge_choice
        
        case "$edge_choice" in
            1) install_packages microsoft-edge-stable ;;
            2) install_packages microsoft-edge-beta ;;
            3) install_packages microsoft-edge-dev ;;
            *) install_packages microsoft-edge-stable ;;
        esac
        
        print_success "Microsoft Edge installed"
    fi
}

# Install Opera
install_opera() {
    if confirm_install "Opera Browser" "Feature-rich browser with built-in tools"; then
        print_section "Installing Opera Browser"
        
        # Add Opera repository
        print_info "Adding Opera repository..."
        curl -fsSL https://deb.opera.com/archive.key | gpg --dearmor -o /usr/share/keyrings/opera-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/opera-keyring.gpg] https://deb.opera.com/opera-stable/ stable non-free" | tee /etc/apt/sources.list.d/opera.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        # Ask for Opera variant
        echo -e "\n${CYAN}Select Opera variant:${RESET}"
        echo -e "${CYAN}[1]${RESET} Opera Stable (recommended)"
        echo -e "${CYAN}[2]${RESET} Opera Beta"
        echo -e "${CYAN}[3]${RESET} Opera Developer"
        echo -e "${CYAN}[4]${RESET} Opera GX (Gaming Browser)"
        
        read -p "Enter your choice [1-4]: " opera_choice
        
        case "$opera_choice" in
            1) install_packages opera-stable ;;
            2) install_packages opera-beta ;;
            3) install_packages opera-developer ;;
            4) 
                if confirm_action "Install Opera GX" "Gaming-focused browser variant"; then
                    download_and_install "https://download3.operacdn.com/pub/opera_gx/70.0.3728.154/linux/opera-gx-stable_70.0.3728.154_amd64.deb" "opera-gx.deb" "Opera GX"
                fi
                ;;
            *) install_packages opera-stable ;;
        esac
        
        print_success "Opera browser installed"
    fi
}

# Install Brave Browser
install_brave() {
    if confirm_install "Brave Browser" "Privacy-focused browser with ad blocking"; then
        print_section "Installing Brave Browser"
        
        # Add Brave repository
        print_info "Adding Brave repository..."
        curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/brave-browser-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/brave-browser-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        install_packages brave-browser
        
        print_success "Brave browser installed"
    fi
}

# Install Vivaldi Browser
install_vivaldi() {
    if confirm_install "Vivaldi Browser" "Customizable browser for power users"; then
        print_section "Installing Vivaldi Browser"
        
        # Add Vivaldi repository
        print_info "Adding Vivaldi repository..."
        curl -fsSL https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/vivaldi-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vivaldi-keyring.gpg] https://repo.vivaldi.com/archive/deb/ stable main" | tee /etc/apt/sources.list.d/vivaldi.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        install_packages vivaldi-stable
        
        print_success "Vivaldi browser installed"
    fi
}

# Install Tor Browser
install_tor_browser() {
    if confirm_install "Tor Browser" "Privacy-focused browser for anonymous browsing"; then
        print_section "Installing Tor Browser"
        
        # Install Tor Browser via official method
        print_info "Installing Tor Browser..."
        
        # Add Tor repository
        curl -fsSL https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor -o /usr/share/keyrings/tor-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/tor-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/tor.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        install_packages tor torbrowser-launcher
        
        print_success "Tor Browser installed"
        print_info "Launch with: torbrowser-launcher"
        print_warning "Use Tor responsibly and in accordance with local laws"
    fi
}

# Install WebKit browsers
install_webkit_browsers() {
    if confirm_install "WebKit-based Browsers" "Lightweight browsers using WebKit engine"; then
        print_section "Installing WebKit-based Browsers"
        
        local packages=(
            epiphany-browser
            midori
            luakit
            qutebrowser
        )
        
        install_packages "${packages[@]}"
        
        # Install additional lightweight browsers
        if confirm_action "Install additional minimal browsers" "Text-based and minimal GUI browsers"; then
            local minimal_browsers=(
                lynx
                links
                elinks
                w3m
                surf
            )
            install_packages "${minimal_browsers[@]}"
        fi
        
        print_success "WebKit-based browsers installed"
    fi
}

# Install browser development tools
install_browser_dev_tools() {
    if confirm_install "Browser Development Tools" "Tools for web development and browser automation"; then
        print_section "Installing Browser Development Tools"
        
        # Install Selenium WebDriver tools
        local packages=(
            chromium-chromedriver
        )
        
        install_packages "${packages[@]}"
        
        # Install additional WebDriver support
        if command_exists python3; then
            print_info "Installing Selenium for Python..."
            python3 -m pip install selenium webdriver-manager >> "$LOG_FILE" 2>&1
        fi
        
        if command_exists npm; then
            print_info "Installing Puppeteer for Node.js..."
            npm install -g puppeteer >> "$LOG_FILE" 2>&1
        fi
        
        # Install browser testing tools
        if confirm_action "Install Playwright" "Modern web testing framework"; then
            if command_exists npm; then
                npm install -g @playwright/test >> "$LOG_FILE" 2>&1
                npx playwright install >> "$LOG_FILE" 2>&1
                print_success "Playwright installed"
            fi
        fi
        
        print_success "Browser development tools installed"
    fi
}

# Install browser extensions and utilities
install_browser_utilities() {
    if confirm_install "Browser Utilities & Extensions" "Browser management and extension tools"; then
        print_section "Installing Browser Utilities"
        
        # Install browser sync tools
        local packages=(
            firefox-esr
            browser-plugin-freshplayer-pepperflash
        )
        
        install_packages "${packages[@]}" || true
        
        # Install browser profile managers
        if confirm_action "Install browser profile management tools" "Tools for managing multiple browser profiles"; then
            print_info "Installing browser profile management tools..."
            
            # These are typically manual setups or extensions
            print_info "Browser profile management can be done through:"
            print_info "- Firefox: about:profiles"
            print_info "- Chrome: --profile-directory flag"
            print_info "- Consider using browser containers or separate user accounts"
        fi
        
        print_success "Browser utilities installed"
    fi
}

# Configure default browser
configure_default_browser() {
    if confirm_install "Default Browser Configuration" "Set system default browser"; then
        print_section "Configuring Default Browser"
        
        # List installed browsers
        local browsers=()
        
        command_exists firefox && browsers+=("firefox")
        command_exists google-chrome && browsers+=("google-chrome")
        command_exists google-chrome-stable && browsers+=("google-chrome-stable")
        command_exists chromium-browser && browsers+=("chromium-browser")
        command_exists microsoft-edge && browsers+=("microsoft-edge")
        command_exists opera && browsers+=("opera")
        command_exists brave-browser && browsers+=("brave-browser")
        command_exists vivaldi && browsers+=("vivaldi")
        
        if [ ${#browsers[@]} -gt 1 ]; then
            echo -e "\n${CYAN}Available browsers:${RESET}"
            for i in "${!browsers[@]}"; do
                echo -e "${CYAN}[$((i+1))]${RESET} ${browsers[$i]}"
            done
            
            read -p "Select default browser [1-${#browsers[@]}]: " browser_choice
            
            if [[ $browser_choice -ge 1 && $browser_choice -le ${#browsers[@]} ]]; then
                local selected_browser="${browsers[$((browser_choice-1))]}"
                
                print_info "Setting $selected_browser as default browser..."
                update-alternatives --install /usr/bin/x-www-browser x-www-browser "/usr/bin/$selected_browser" 10
                update-alternatives --set x-www-browser "/usr/bin/$selected_browser"
                
                if [ -n "$CURRENT_USER" ]; then
                    sudo -u "$CURRENT_USER" xdg-settings set default-web-browser "$selected_browser.desktop" 2>/dev/null || true
                fi
                
                print_success "$selected_browser set as default browser"
            fi
        else
            print_info "Only one browser detected or none selected"
        fi
    fi
}

# Install browser security tools
install_browser_security() {
    if confirm_install "Browser Security Tools" "Privacy and security enhancement tools"; then
        print_section "Installing Browser Security Tools"
        
        # Install privacy tools
        local packages=(
            tor
            proxychains4
            privoxy
        )
        
        install_packages "${packages[@]}"
        
        # Configure basic privacy settings
        print_info "Browser security recommendations:"
        echo -e "${CYAN}• Install uBlock Origin extension${RESET}"
        echo -e "${CYAN}• Install Privacy Badger extension${RESET}"
        echo -e "${CYAN}• Install HTTPS Everywhere extension${RESET}"
        echo -e "${CYAN}• Consider using Firefox containers${RESET}"
        echo -e "${CYAN}• Enable DNS over HTTPS in browser settings${RESET}"
        echo -e "${CYAN}• Use VPN services for additional privacy${RESET}"
        
        print_success "Browser security tools installed"
    fi
}

# Main browsers module execution
main() {
    print_header "Web Browsers Installation"
    
    install_firefox
    install_chrome
    install_chromium
    install_edge
    install_opera
    install_brave
    install_vivaldi
    install_tor_browser
    install_webkit_browsers
    install_browser_dev_tools
    install_browser_utilities
    install_browser_security
    configure_default_browser
    
    print_success "Web browsers installation completed"
    
    # Browser recommendations
    echo -e "\n${BOLD}${YELLOW}Browser Recommendations:${RESET}"
    echo -e "${CYAN}• Configure browser sync for bookmarks and settings${RESET}"
    echo -e "${CYAN}• Install essential extensions (adblocker, password manager)${RESET}"
    echo -e "${CYAN}• Set up different browsers for different purposes${RESET}"
    echo -e "${CYAN}• Consider using browser profiles for work/personal separation${RESET}"
    echo -e "${CYAN}• Enable hardware acceleration for better performance${RESET}"
    echo -e "${CYAN}• Regular browser updates are handled automatically${RESET}"
}

# Execute main function
main
