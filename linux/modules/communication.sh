#!/bin/bash

#==============================================================================
# Communication Tools Module
# Chat, video conferencing, email, and collaboration tools
#==============================================================================

# Install messaging and chat applications
install_messaging_apps() {
    if confirm_install "Messaging & Chat Applications" "Discord, Telegram, Signal, and other chat apps"; then
        print_section "Installing Messaging & Chat Applications"
        
        # Install via Snap (most reliable for these apps)
        if command_exists snap; then
            local snap_messaging_apps=(
                discord
                telegram-desktop
                signal-desktop
                slack
                element-desktop
                whatsdesk
                teams-for-linux
            )
            
            echo -e "\n${CYAN}Available messaging apps:${RESET}"
            for i in "${!snap_messaging_apps[@]}"; do
                echo -e "${CYAN}[$((i+1))]${RESET} ${snap_messaging_apps[$i]}"
            done
            echo -e "${CYAN}[A]${RESET} Install all messaging apps"
            echo -e "${CYAN}[S]${RESET} Skip messaging apps"
            
            read -p "Select apps to install [1-${#snap_messaging_apps[@]}/A/S]: " messaging_choice
            
            case "${messaging_choice^^}" in
                A)
                    install_snap_packages "${snap_messaging_apps[@]}"
                    ;;
                S)
                    print_info "Skipping messaging apps"
                    ;;
                [1-9]*)
                    if [[ $messaging_choice -ge 1 && $messaging_choice -le ${#snap_messaging_apps[@]} ]]; then
                        local selected_app="${snap_messaging_apps[$((messaging_choice-1))]}"
                        install_snap_packages "$selected_app"
                    fi
                    ;;
            esac
        fi
        
        # Install additional messaging apps via APT/Flatpak
        if confirm_action "Install additional messaging clients" "Pidgin, Hexchat, and IRC clients"; then
            local apt_messaging=(
                pidgin
                pidgin-otr
                hexchat
                irssi
                weechat
                xchat
                empathy
                kopete
            )
            
            install_packages "${apt_messaging[@]}"
        fi
        
        print_success "Messaging and chat applications installed"
    fi
}

# Install video conferencing applications
install_video_conferencing() {
    if confirm_install "Video Conferencing" "Zoom, Microsoft Teams, and other video call apps"; then
        print_section "Installing Video Conferencing Applications"
        
        # Install Zoom
        if confirm_action "Install Zoom" "Popular video conferencing platform"; then
            download_and_install "https://zoom.us/client/latest/zoom_amd64.deb" "zoom.deb" "Zoom"
        fi
        
        # Install Microsoft Teams
        if confirm_action "Install Microsoft Teams" "Microsoft's collaboration platform"; then
            # Add Microsoft repository if not already added
            if [ ! -f /etc/apt/sources.list.d/packages.microsoft.list ]; then
                curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
                echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/ms-teams stable main" | tee /etc/apt/sources.list.d/ms-teams.list
                apt update >> "$LOG_FILE" 2>&1
            fi
            install_packages teams
        fi
        
        # Install Skype
        if confirm_action "Install Skype" "Microsoft's communication platform"; then
            download_and_install "https://repo.skype.com/latest/skypeforlinux-64.deb" "skype.deb" "Skype"
        fi
        
        # Install Google Meet PWA and other alternatives
        if confirm_action "Install alternative video tools" "Jitsi Meet, BigBlueButton clients"; then
            # Install Jitsi Meet desktop
            if command_exists snap; then
                install_snap_packages jitsi-meet-desktop
            fi
            
            # Install other video tools
            local video_packages=(
                cheese          # Webcam testing
                kamoso          # KDE webcam app
                guvcview        # Webcam viewer
                obs-studio      # For streaming/recording
            )
            
            install_packages "${video_packages[@]}"
        fi
        
        print_success "Video conferencing applications installed"
    fi
}

# Install email clients
install_email_clients() {
    if confirm_install "Email Clients" "Thunderbird, Evolution, and other email applications"; then
        print_section "Installing Email Clients"
        
        local email_clients=(
            thunderbird
            thunderbird-locale-en
            evolution
            kmail
            claws-mail
            sylpheed
            mutt
            neomutt
            alpine
        )
        
        # Install GUI email clients
        if confirm_action "Install GUI email clients" "Thunderbird, Evolution, KMail"; then
            install_packages thunderbird evolution kmail
            
            # Install Thunderbird add-ons helpers
            local tb_addons=(
                lightning
                enigmail
            )
            install_packages "${tb_addons[@]}" || true
        fi
        
        # Install terminal email clients
        if confirm_action "Install terminal email clients" "Mutt, NeoMutt, Alpine"; then
            install_packages mutt neomutt alpine
        fi
        
        # Install Mailspring (modern email client)
        if confirm_action "Install Mailspring" "Modern, fast email client"; then
            install_snap_packages mailspring
        fi
        
        print_success "Email clients installed"
    fi
}

# Install collaboration tools
install_collaboration_tools() {
    if confirm_install "Collaboration Tools" "Project management, note-taking, and team tools"; then
        print_section "Installing Collaboration Tools"
        
        # Install note-taking applications
        if confirm_action "Install note-taking apps" "Obsidian, Joplin, and other note apps"; then
            local note_apps=()
            
            # Install via Snap/Flatpak
            if command_exists snap; then
                local snap_note_apps=(
                    obsidian
                    joplin-desktop
                    notion-snap
                    logseq
                    standardnotes
                )
                install_snap_packages "${snap_note_apps[@]}"
            fi
            
            # Install via APT
            local apt_note_apps=(
                cherrytree
                basket
                gnote
                tomboy
                xpad
                sticky
            )
            install_packages "${apt_note_apps[@]}"
        fi
        
        # Install project management tools
        if confirm_action "Install project management tools" "Taiga, OpenProject clients"; then
            # Most project management tools are web-based
            print_info "Installing project management utilities..."
            
            local pm_tools=(
                planner         # GNOME project management
                projectlibre    # MS Project alternative
                ganttproject    # Gantt chart software
            )
            
            install_packages "${pm_tools[@]}"
            
            # Install TaskWarrior for CLI task management
            install_packages task timewarrior
        fi
        
        # Install mind mapping tools
        if confirm_action "Install mind mapping software" "FreeMind, XMind, and diagram tools"; then
            local mindmap_tools=(
                freemind
                vym             # View Your Mind
                kdissert        # Mind mapping
                dia             # Diagram editor
                umbrello        # UML modeller
            )
            
            install_packages "${mindmap_tools[@]}"
            
            # Install draw.io desktop
            if command_exists snap; then
                install_snap_packages drawio
            fi
        fi
        
        print_success "Collaboration tools installed"
    fi
}

# Install file sharing and sync tools
install_file_sharing() {
    if confirm_install "File Sharing & Sync" "Cloud storage, file transfer, and sync tools"; then
        print_section "Installing File Sharing & Sync Tools"
        
        # Install cloud storage clients
        if confirm_action "Install cloud storage clients" "Dropbox, Google Drive, OneDrive"; then
            # Dropbox
            if confirm_action "Install Dropbox" "Dropbox cloud storage client"; then
                download_and_install "https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb" "dropbox.deb" "Dropbox"
            fi
            
            # Google Drive via rclone browser
            if confirm_action "Install Google Drive tools" "rclone and GUI tools for Google Drive"; then
                install_packages rclone
                
                # Install rclone browser
                if command_exists snap; then
                    install_snap_packages rclone-browser
                fi
            fi
            
            # Install Insync (Google Drive client)
            if confirm_action "Install Insync" "Premium Google Drive client"; then
                print_info "Adding Insync repository..."
                curl -fsSL https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key | gpg --dearmor -o /usr/share/keyrings/insync-keyring.gpg
                echo "deb [arch=amd64 signed-by=/usr/share/keyrings/insync-keyring.gpg] http://apt.insync.io/ubuntu $(lsb_release -cs) non-free contrib" | tee /etc/apt/sources.list.d/insync.list
                apt update >> "$LOG_FILE" 2>&1
                install_packages insync
            fi
        fi
        
        # Install file transfer tools
        if confirm_action "Install file transfer tools" "FileZilla, WinSCP alternatives, and transfer utilities"; then
            local transfer_tools=(
                filezilla
                gftp
                nautilus
                thunar
                rsync
                scp
                sftp
                lftp
                ncftp
                wget
                curl
                aria2
            )
            
            install_packages "${transfer_tools[@]}"
            
            # Install modern file transfer tools
            if command_exists cargo && [ -n "$CURRENT_USER" ]; then
                sudo -u "$CURRENT_USER" cargo install croc >> "$LOG_FILE" 2>&1 || true
            fi
        fi
        
        # Install sync tools
        if confirm_action "Install synchronization tools" "Syncthing, Unison, and other sync tools"; then
            local sync_tools=(
                syncthing
                syncthing-gtk
                unison
                unison-gtk
                grsync
                luckybackup
            )
            
            install_packages "${sync_tools[@]}"
            
            # Configure Syncthing
            if command_exists syncthing; then
                enable_and_start_service syncthing@"$CURRENT_USER" || true
                print_info "Syncthing web UI will be available at http://localhost:8384"
            fi
        fi
        
        print_success "File sharing and sync tools installed"
    fi
}

# Install VoIP and telephony tools
install_voip_tools() {
    if confirm_install "VoIP & Telephony" "Voice over IP and telephony applications"; then
        print_section "Installing VoIP & Telephony Tools"
        
        local voip_tools=(
            linphone
            ekiga
            jami
            mumble
            teamspeak3-client
            twinkle
            ring
        )
        
        # Install SIP clients
        if confirm_action "Install SIP clients" "Linphone, Ekiga, and other SIP clients"; then
            install_packages linphone ekiga twinkle
        fi
        
        # Install Jami (GNU Ring)
        if confirm_action "Install Jami" "Distributed communication platform"; then
            # Add Jami repository
            curl -fsSL https://dl.jami.net/ring-manual/ubuntu_18.04/jami-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/jami-keyring.gpg
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/jami-keyring.gpg] https://dl.jami.net/ring-manual/ubuntu_20.04/ ring main" | tee /etc/apt/sources.list.d/jami.list
            apt update >> "$LOG_FILE" 2>&1
            install_packages jami
        fi
        
        # Install gaming voice chat
        if confirm_action "Install gaming voice chat" "Mumble, TeamSpeak, and gaming communication"; then
            install_packages mumble
            
            # Install TeamSpeak via manual download
            if confirm_action "Install TeamSpeak 3" "TeamSpeak 3 client"; then
                print_info "TeamSpeak 3 requires manual download from teamspeak.com"
                print_info "Download the Linux client and install manually"
            fi
        fi
        
        print_success "VoIP and telephony tools installed"
    fi
}

# Install social media and content tools
install_social_media_tools() {
    if confirm_install "Social Media & Content Tools" "Social media clients and content creation"; then
        print_section "Installing Social Media & Content Tools"
        
        # Install social media clients
        if confirm_action "Install social media clients" "Twitter, Mastodon, and social clients"; then
            # Install via Snap
            if command_exists snap; then
                local social_apps=(
                    tweetdeck-unofficial
                    whalebird
                    tokodon
                )
                install_snap_packages "${social_apps[@]}"
            fi
            
            # Install terminal-based clients
            local terminal_social=(
                rainbowstream   # Twitter client
                toot           # Mastodon client
            )
            
            if command_exists pip3; then
                pip3 install rainbowstream >> "$LOG_FILE" 2>&1 || true
            fi
            
            install_packages toot || true
        fi
        
        # Install content creation tools
        if confirm_action "Install content creation tools" "Streaming, recording, and content tools"; then
            local content_tools=(
                obs-studio
                simplescreenrecorder
                kazam
                peek
                gifski
                gifsicle
                ffmpeg
            )
            
            install_packages "${content_tools[@]}"
        fi
        
        print_success "Social media and content tools installed"
    fi
}

# Configure communication integrations
configure_communication() {
    if confirm_install "Communication Integrations" "Set up notification systems and integrations"; then
        print_section "Configuring Communication Integrations"
        
        # Install notification tools
        local notification_tools=(
            libnotify-bin
            notify-osd
            dunst
            xfce4-notifyd
            notification-daemon
        )
        
        install_packages "${notification_tools[@]}"
        
        # Configure desktop notifications
        if [ -n "$CURRENT_USER" ]; then
            print_info "Configuring desktop notifications for $CURRENT_USER..."
            
            # Enable desktop notifications for applications
            sudo -u "$CURRENT_USER" bash -c 'cat > ~/.config/autostart/notification-setup.desktop << "EOF"
[Desktop Entry]
Type=Application
Name=Communication Notification Setup
Exec=sh -c "export DISPLAY=:0; notify-send '\''Communication Setup'\'' '\''Communication tools are ready!'\'' -t 3000"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF'
        fi
        
        # Set up email notifications
        if confirm_action "Configure email notifications" "Set up system email notifications"; then
            install_packages postfix mailutils
            
            print_info "Email system installed for notifications"
            print_warning "Configure /etc/postfix/main.cf for your email setup"
        fi
        
        print_success "Communication integrations configured"
    fi
}

# Main communication module execution
main() {
    print_header "Communication Tools Installation"
    
    install_messaging_apps
    install_video_conferencing
    install_email_clients
    install_collaboration_tools
    install_file_sharing
    install_voip_tools
    install_social_media_tools
    configure_communication
    
    print_success "Communication tools installation completed"
    
    # Communication recommendations
    echo -e "\n${BOLD}${YELLOW}Communication Recommendations:${RESET}"
    echo -e "${CYAN}• Configure email clients with your accounts${RESET}"
    echo -e "${CYAN}• Set up cloud storage sync for file collaboration${RESET}"
    echo -e "${CYAN}• Test video/audio devices with video conferencing apps${RESET}"
    echo -e "${CYAN}• Configure notification preferences for messaging apps${RESET}"
    echo -e "${CYAN}• Set up backup and sync for important communications${RESET}"
    echo -e "${CYAN}• Consider privacy settings for social media and chat apps${RESET}"
    echo -e "${CYAN}• Use end-to-end encryption for sensitive communications${RESET}"
}

# Execute main function
main
