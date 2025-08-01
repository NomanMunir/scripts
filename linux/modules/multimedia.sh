#!/bin/bash

#==============================================================================
# Multimedia Tools & Codecs Module
# Video/audio codecs, players, editors, and multimedia libraries
#==============================================================================

# Install multimedia codecs and libraries
install_multimedia_codecs() {
    if confirm_install "Multimedia Codecs & Libraries" "Essential audio/video codecs and multimedia libraries"; then
        print_section "Installing Multimedia Codecs & Libraries"
        
        # Enable universe and multiverse repositories
        add-apt-repository universe -y >> "$LOG_FILE" 2>&1
        add-apt-repository multiverse -y >> "$LOG_FILE" 2>&1
        apt update >> "$LOG_FILE" 2>&1
        
        local packages=(
            ubuntu-restricted-extras
            ffmpeg
            gstreamer1.0-plugins-base
            gstreamer1.0-plugins-good
            gstreamer1.0-plugins-bad
            gstreamer1.0-plugins-ugly
            gstreamer1.0-libav
            gstreamer1.0-tools
            libavcodec-extra
            libdvd-pkg
            lame
            x264
            x265
            faac
            faad
            w64codecs
            libxvidcore4
        )
        
        install_packages "${packages[@]}"
        
        # Configure libdvd-pkg
        print_info "Configuring DVD support..."
        dpkg-reconfigure libdvd-pkg >> "$LOG_FILE" 2>&1
        
        print_success "Multimedia codecs and libraries installed"
    fi
}

# Install media players
install_media_players() {
    if confirm_install "Media Players" "VLC, MPV, and other multimedia players"; then
        print_section "Installing Media Players"
        
        local packages=(
            vlc
            vlc-plugin-base
            vlc-plugin-video-output
            mpv
            totem
            rhythmbox
            audacious
            clementine
            strawberry
            banshee
            parole
        )
        
        install_packages "${packages[@]}"
        
        # Install Spotify
        if confirm_action "Install Spotify" "Music streaming service"; then
            install_snap_packages spotify
        fi
        
        # Install YouTube Music Desktop App
        if confirm_action "Install YouTube Music" "YouTube Music desktop client"; then
            install_snap_packages youtube-music-desktop-app
        fi
        
        print_success "Media players installed"
    fi
}

# Install video editors
install_video_editors() {
    if confirm_install "Video Editing Software" "Professional and amateur video editing tools"; then
        print_section "Installing Video Editing Software"
        
        local packages=(
            kdenlive
            openshot
            pitivi
            flowblade
            avidemux
            handbrake
            winff
            devede
            dvdstyler
        )
        
        install_packages "${packages[@]}"
        
        # Install DaVinci Resolve (manual download required)
        if confirm_action "Install DaVinci Resolve" "Professional video editing software (requires manual activation)"; then
            print_info "DaVinci Resolve requires manual download from BlackMagic Design"
            print_info "Visit: https://www.blackmagicdesign.com/products/davinciresolve/"
            print_warning "Note: DaVinci Resolve has specific system requirements"
        fi
        
        # Install Blender (also useful for video editing)
        if confirm_action "Install Blender" "3D creation suite with video editing capabilities"; then
            install_packages blender
        fi
        
        print_success "Video editing software installed"
    fi
}

# Install audio editors and tools
install_audio_editors() {
    if confirm_install "Audio Editing & Production" "Audio editors, DAWs, and sound tools"; then
        print_section "Installing Audio Editing & Production Tools"
        
        local packages=(
            audacity
            ardour
            lmms
            rosegarden
            hydrogen
            qtractor
            seq24
            mixxx
            milkytracker
            soundconverter
            sox
            ecasound
            jack-tools
            qjackctl
            pavucontrol
            pulseeffects
            easyeffects
        )
        
        install_packages "${packages[@]}"
        
        # Install REAPER (trial version)
        if confirm_action "Install REAPER" "Professional DAW (60-day trial)"; then
            download_and_install "https://www.reaper.fm/files/6.x/reaper682_linux_x86_64.tar.xz" "reaper.tar.xz" "REAPER DAW"
            
            if [ -f "/tmp/setup-downloads/reaper.tar.xz" ]; then
                tar -xf "/tmp/setup-downloads/reaper.tar.xz" -C /opt/
                ln -sf /opt/reaper_linux_x86_64/REAPER/reaper /usr/local/bin/reaper
                create_desktop_entry "REAPER" "/opt/reaper_linux_x86_64/REAPER/reaper" "/opt/reaper_linux_x86_64/REAPER/Data/reaper.png" "Digital Audio Workstation" "Audio;AudioVideo;"
                print_success "REAPER installed"
            fi
        fi
        
        print_success "Audio editing and production tools installed"
    fi
}

# Install graphics and image editors
install_graphics_editors() {
    if confirm_install "Graphics & Image Editing" "Image editors, vector graphics, and design tools"; then
        print_section "Installing Graphics & Image Editing Software"
        
        local packages=(
            gimp
            gimp-data-extras
            gimp-plugin-registry
            inkscape
            krita
            mypaint
            darktable
            rawtherapee
            luminance-hdr
            hugin
            imagemagick
            graphicsmagick
            optipng
            jpegoptim
            pngquant
            exiftool
            shotwell
            digikam
            gwenview
            gthumb
        )
        
        install_packages "${packages[@]}"
        
        # Install Adobe alternatives via Flatpak
        if command_exists flatpak; then
            if confirm_action "Install additional graphics software via Flatpak" "Figma, Pinta, and other tools"; then
                local flatpak_packages=(
                    "io.github.Figma_Linux.figma_linux"
                    "com.github.PintaProject.Pinta"
                    "org.kde.kolourpaint"
                    "org.photoflare.photoflare"
                )
                
                install_flatpak_packages "${flatpak_packages[@]}"
            fi
        fi
        
        print_success "Graphics and image editing software installed"
    fi
}

# Install 3D modeling and animation software
install_3d_software() {
    if confirm_install "3D Modeling & Animation" "3D creation, modeling, and rendering tools"; then
        print_section "Installing 3D Modeling & Animation Software"
        
        local packages=(
            blender
            freecad
            openscad
            meshlab
            makehuman
            art-of-illusion
            wings3d
            povray
            yafaray
        )
        
        install_packages "${packages[@]}"
        
        # Install additional 3D software
        if confirm_action "Install Sweet Home 3D" "Interior design software"; then
            install_packages sweethome3d
        fi
        
        print_success "3D modeling and animation software installed"
    fi
}

# Install screen recording and streaming tools
install_recording_tools() {
    if confirm_install "Screen Recording & Streaming" "Screen capture, recording, and streaming software"; then
        print_section "Installing Screen Recording & Streaming Tools"
        
        local packages=(
            obs-studio
            simplescreenrecorder
            vokoscreen-ng
            recordmydesktop
            gtk-recordmydesktop
            kazam
            peek
            flameshot
            shutter
            gnome-screenshot
            maim
            scrot
            byzanz
        )
        
        install_packages "${packages[@]}"
        
        # Install additional streaming tools
        if confirm_action "Install streaming plugins and tools" "Additional OBS plugins and streaming utilities"; then
            # OBS plugins are typically installed via OBS or manually
            print_info "OBS plugins can be installed through OBS Studio's Tools > Plugin Manager"
            
            # Install Streamlabs OBS (if available)
            if confirm_action "Install Streamlabs OBS" "Enhanced streaming software"; then
                install_flatpak_packages "com.streamlabs.StreamlabsOBS" || true
            fi
        fi
        
        print_success "Screen recording and streaming tools installed"
    fi
}

# Install media conversion tools
install_conversion_tools() {
    if confirm_install "Media Conversion Tools" "Format converters and media manipulation utilities"; then
        print_section "Installing Media Conversion Tools"
        
        local packages=(
            ffmpeg
            mencoder
            transcode
            handbrake
            winff
            soundconverter
            brasero
            k3b
            xfburn
            devede
            imagination
            frei0r-plugins
        )
        
        install_packages "${packages[@]}"
        
        # Install youtube-dl/yt-dlp
        if confirm_action "Install yt-dlp" "YouTube and media downloader"; then
            print_info "Installing yt-dlp..."
            curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
            chmod +x /usr/local/bin/yt-dlp
            print_success "yt-dlp installed"
        fi
        
        print_success "Media conversion tools installed"
    fi
}

# Install webcam and camera tools
install_camera_tools() {
    if confirm_install "Camera & Webcam Tools" "Webcam software, camera control, and photo management"; then
        print_section "Installing Camera & Webcam Tools"
        
        local packages=(
            cheese
            guvcview
            camorama
            v4l-utils
            gphoto2
            libgphoto2-dev
            entangle
            rapid-photo-downloader
            photoqt
            nomacs
            mirage
            feh
            sxiv
        )
        
        install_packages "${packages[@]}"
        
        # Install camera-specific software
        if confirm_action "Install additional camera software" "Advanced camera control and RAW processing"; then
            local camera_packages=(
                darktable
                rawtherapee
                luminance-hdr
                hugin
                dcraw
                ufraw
            )
            install_packages "${camera_packages[@]}"
        fi
        
        print_success "Camera and webcam tools installed"
    fi
}

# Install multimedia development libraries
install_multimedia_dev() {
    if confirm_install "Multimedia Development Libraries" "Libraries for multimedia application development"; then
        print_section "Installing Multimedia Development Libraries"
        
        local packages=(
            libavcodec-dev
            libavformat-dev
            libavutil-dev
            libswscale-dev
            libavfilter-dev
            libavdevice-dev
            libsdl2-dev
            libsdl2-image-dev
            libsdl2-mixer-dev
            libsdl2-ttf-dev
            libsfml-dev
            liballegro5-dev
            libopencv-dev
            python3-opencv
            libgstreamer1.0-dev
            libgstreamer-plugins-base1.0-dev
            libjack-jackd2-dev
            libpulse-dev
            libasound2-dev
            libportaudio2
            libportmidi-dev
        )
        
        install_packages "${packages[@]}"
        
        print_success "Multimedia development libraries installed"
    fi
}

# Configure audio system optimizations
configure_audio_system() {
    if confirm_install "Audio System Optimization" "Configure JACK, PulseAudio, and low-latency audio"; then
        print_section "Configuring Audio System"
        
        local packages=(
            jackd2
            qjackctl
            pulseaudio-module-jack
            a2jmidid
            jack-capture
            jack-mixer
            jack-rack
            patchage
        )
        
        install_packages "${packages[@]}"
        
        # Add user to audio group
        if [ -n "$CURRENT_USER" ]; then
            add_user_to_group "$CURRENT_USER" "audio"
            add_user_to_group "$CURRENT_USER" "pulse"
            add_user_to_group "$CURRENT_USER" "pulse-access"
        fi
        
        # Configure audio system limits for low latency
        print_info "Configuring audio system for low latency..."
        cat >> /etc/security/limits.conf << 'EOF'

# Audio production optimizations
@audio - rtprio 85
@audio - memlock unlimited
@audio - nice -10
EOF

        print_success "Audio system optimization completed"
        print_info "User needs to log out and back in for audio group changes to take effect"
    fi
}

# Main multimedia module execution
main() {
    print_header "Multimedia Tools & Codecs Installation"
    
    install_multimedia_codecs
    install_media_players
    install_video_editors
    install_audio_editors
    install_graphics_editors
    install_3d_software
    install_recording_tools
    install_conversion_tools
    install_camera_tools
    install_multimedia_dev
    configure_audio_system
    
    print_success "Multimedia tools & codecs installation completed"
    
    # Multimedia recommendations
    echo -e "\n${BOLD}${YELLOW}Multimedia Recommendations:${RESET}"
    echo -e "${CYAN}• Test audio/video playback with sample files${RESET}"
    echo -e "${CYAN}• Configure audio production settings if using DAW software${RESET}"
    echo -e "${CYAN}• Install additional codecs if needed for specific formats${RESET}"
    echo -e "${CYAN}• Use hardware acceleration when available for video editing${RESET}"
    echo -e "${CYAN}• Consider external audio interfaces for professional audio work${RESET}"
    echo -e "${CYAN}• Configure JACK for low-latency audio if doing music production${RESET}"
}

# Execute main function
main
