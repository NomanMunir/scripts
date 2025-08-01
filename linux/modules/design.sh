#!/bin/bash

#==============================================================================
# Design & Graphics Tools Module
# Graphics design, CAD, 3D modeling, and creative software
#==============================================================================

# Install image editing and manipulation software
install_image_editors() {
    if confirm_install "Image Editing Software" "Professional image editing and manipulation tools"; then
        print_section "Installing Image Editing Software"
        
        local image_editors=(
            gimp
            gimp-data-extras
            gimp-plugin-registry
            gimp-gmic
            krita
            mypaint
            pinta
            mtpaint
            gpaint
            kolourpaint
            photoflare
            pixeluvo
            darktable
            rawtherapee
            luminance-hdr
        )
        
        install_packages "${image_editors[@]}"
        
        # Install additional GIMP plugins
        if confirm_action "Install additional GIMP plugins" "G'MIC, Resynthesizer, and other plugins"; then
            local gimp_plugins=(
                gimp-gmic
                gimp-plugin-registry
                gimp-texturize
                gimp-normalmap
            )
            install_packages "${gimp_plugins[@]}" || true
        fi
        
        # Install Adobe alternatives via Flatpak
        if command_exists flatpak && confirm_action "Install additional image editors via Flatpak" "More image editing options"; then
            local flatpak_image_apps=(
                "org.kde.krita"
                "com.github.PintaProject.Pinta"
                "org.photoflare.photoflare"
                "io.github.threedeyes.qpixmap"
            )
            install_flatpak_packages "${flatpak_image_apps[@]}"
        fi
        
        print_success "Image editing software installed"
    fi
}

# Install vector graphics software
install_vector_graphics() {
    if confirm_install "Vector Graphics Software" "Vector illustration and design tools"; then
        print_section "Installing Vector Graphics Software"
        
        local vector_tools=(
            inkscape
            karbon
            xfig
            dia
            pencil2d
            sk1
            sK1
            scribus
            calligra-suite
        )
        
        install_packages "${vector_tools[@]}"
        
        # Install Inkscape extensions
        if confirm_action "Install Inkscape extensions" "Additional Inkscape functionality"; then
            local inkscape_extensions=(
                python3-lxml
                python3-numpy
                python3-pil
            )
            install_packages "${inkscape_extensions[@]}"
        fi
        
        # Install additional vector tools via Snap/Flatpak
        if command_exists snap && confirm_action "Install additional vector tools" "More vector graphics options"; then
            install_snap_packages vectr boxy-svg
        fi
        
        print_success "Vector graphics software installed"
    fi
}

# Install 3D modeling and animation software
install_3d_software() {
    if confirm_install "3D Modeling & Animation" "3D creation, modeling, and rendering software"; then
        print_section "Installing 3D Modeling & Animation Software"
        
        local three_d_software=(
            blender
            freecad
            openscad
            meshlab
            makehuman
            art-of-illusion
            wings3d
            povray
            yafaray
            sweet3d
            k3d
        )
        
        install_packages "${three_d_software[@]}"
        
        # Install additional 3D tools
        if confirm_action "Install additional 3D software" "Specialized 3D modeling tools"; then
            # Install BRL-CAD
            install_packages brlcad || true
            
            # Install additional CAD tools
            local cad_tools=(
                qcad
                librecad
                kicad
                geda-gaf
            )
            install_packages "${cad_tools[@]}"
        fi
        
        # Install 3D printing tools
        if confirm_action "Install 3D printing software" "Slicers and 3D printing utilities"; then
            local printing_tools=(
                cura
                prusa-slicer
                openscad
                meshlab
                netfabb
            )
            
            # Install Cura via AppImage or Snap
            if command_exists snap; then
                install_snap_packages cura-slicer
            fi
            
            # Install other printing utilities
            install_packages openscad meshlab
        fi
        
        print_success "3D modeling and animation software installed"
    fi
}

# Install CAD software
install_cad_software() {
    if confirm_install "CAD Software" "Computer-Aided Design applications"; then
        print_section "Installing CAD Software"
        
        local cad_software=(
            freecad
            librecad
            qcad
            brlcad
            opencascade-tools
            calculix-ccx
            calculix-cgx
            gmsh
            netgen
            salome-platform
        )
        
        install_packages "${cad_software[@]}"
        
        # Install electrical CAD
        if confirm_action "Install electrical CAD software" "KiCad, gEDA, and circuit design"; then
            local electrical_cad=(
                kicad
                kicad-libraries
                geda-gaf
                geda-utils
                pcb-gtk
                ngspice
                qucs
                fritzing
            )
            install_packages "${electrical_cad[@]}"
        fi
        
        # Install additional engineering tools
        if confirm_action "Install engineering analysis tools" "FEA and simulation software"; then
            local analysis_tools=(
                calculix-ccx
                calculix-cgx
                gmsh
                paraview
                gnuplot
                octave
                scilab
            )
            install_packages "${analysis_tools[@]}"
        fi
        
        print_success "CAD software installed"
    fi
}

# Install desktop publishing software
install_publishing_software() {
    if confirm_install "Desktop Publishing" "Layout, publishing, and document design tools"; then
        print_section "Installing Desktop Publishing Software"
        
        local publishing_tools=(
            scribus
            calligra-suite
            pagestream
            lyx
            texlive-full
            texmaker
            texstudio
            kile
            gummi
        )
        
        # Install main publishing tools
        install_packages scribus calligra-suite
        
        # Install LaTeX publishing system
        if confirm_action "Install LaTeX publishing system" "Complete LaTeX environment for professional documents"; then
            if confirm_action "Install full TeXLive" "Complete LaTeX distribution (large download ~4GB)"; then
                install_packages texlive-full
            else
                install_packages texlive texlive-latex-extra texlive-fonts-recommended
            fi
            
            # Install LaTeX editors
            local latex_editors=(
                texmaker
                texstudio
                kile
                gummi
                lyx
            )
            install_packages "${latex_editors[@]}"
        fi
        
        # Install additional publishing tools
        if confirm_action "Install additional publishing tools" "More document design options"; then
            local additional_tools=(
                abiword
                calligra-words
                focuswriter
                manuskript
                bibisco
            )
            install_packages "${additional_tools[@]}"
        fi
        
        print_success "Desktop publishing software installed"
    fi
}

# Install font management and typography tools
install_font_tools() {
    if confirm_install "Font Management & Typography" "Font managers and typography tools"; then
        print_section "Installing Font Management & Typography Tools"
        
        local font_tools=(
            font-manager
            fontforge
            fonttools
            gnome-font-viewer
            gucharmap
            unicode
            fontconfig
            fc-list
        )
        
        install_packages "${font_tools[@]}"
        
        # Install additional fonts
        if confirm_action "Install additional font collections" "Google Fonts, Adobe fonts, and more"; then
            local font_packages=(
                fonts-liberation
                fonts-liberation2
                fonts-dejavu
                fonts-opensymbol
                fonts-noto
                fonts-noto-color-emoji
                fonts-roboto
                fonts-lato
                fonts-open-sans
                fonts-ubuntu
                fonts-powerline
                fonts-font-awesome
                fonts-materialdesignicons-webfont
            )
            install_packages "${font_packages[@]}"
            
            # Install Google Fonts
            if confirm_action "Install Google Fonts collection" "Large collection of Google Fonts"; then
                if command_exists git; then
                    print_info "Downloading Google Fonts..."
                    git clone https://github.com/google/fonts.git /tmp/google-fonts >> "$LOG_FILE" 2>&1
                    
                    # Install to system fonts directory
                    mkdir -p /usr/share/fonts/truetype/google-fonts
                    find /tmp/google-fonts -name "*.ttf" -exec cp {} /usr/share/fonts/truetype/google-fonts/ \;
                    
                    # Update font cache
                    fc-cache -f -v >> "$LOG_FILE" 2>&1
                    
                    # Cleanup
                    rm -rf /tmp/google-fonts
                    
                    print_success "Google Fonts installed"
                fi
            fi
        fi
        
        print_success "Font management tools installed"
    fi
}

# Install color management and design utilities
install_design_utilities() {
    if confirm_install "Design Utilities" "Color pickers, design tools, and utilities"; then
        print_section "Installing Design Utilities"
        
        local design_utils=(
            gpick          # Color picker
            gcolor3        # Color chooser
            agave          # Color scheme designer
            colorhug-client # Color management
            argyllcms      # Color management
            xcalib         # Monitor calibration
            displaycal     # Display calibration
            ruler          # Screen ruler
            screenruler    # Desktop ruler
        )
        
        install_packages "${design_utils[@]}"
        
        # Install additional design utilities via Snap/Flatpak
        if command_exists snap && confirm_action "Install additional design utilities" "More design and utility tools"; then
            local snap_design_tools=(
                color-picker
                screen-ruler
                figma-linux
            )
            install_snap_packages "${snap_design_tools[@]}"
        fi
        
        # Install screen measurement tools
        if confirm_action "Install screen measurement tools" "Rulers, protractors, and measurement utilities"; then
            local measurement_tools=(
                kruler
                screenruler
                gmeasure
                xmeasure
            )
            install_packages "${measurement_tools[@]}"
        fi
        
        print_success "Design utilities installed"
    fi
}

# Install animation and motion graphics software
install_animation_software() {
    if confirm_install "Animation & Motion Graphics" "2D animation, motion graphics, and video editing"; then
        print_section "Installing Animation & Motion Graphics Software"
        
        local animation_tools=(
            blender        # 3D animation
            synfig         # 2D animation
            pencil2d       # Traditional animation
            opentoonz      # Professional 2D animation
            krita          # Animation features
            stopmotion     # Stop motion animation
            qstopmotion    # Stop motion tool
        )
        
        install_packages "${animation_tools[@]}"
        
        # Install additional animation tools
        if confirm_action "Install professional animation software" "OpenToonz and advanced tools"; then
            # OpenToonz needs to be compiled or installed via Flatpak
            if command_exists flatpak; then
                install_flatpak_packages "io.github.OpenToonz"
            fi
            
            # Install Wick Editor (web-based, create launcher)
            if confirm_action "Create Wick Editor launcher" "Web-based animation tool"; then
                create_desktop_entry "Wick Editor" "xdg-open https://www.wickeditor.com/editor/" "/usr/share/pixmaps/web-browser.png" "Web-based Animation Tool" "Graphics;2DGraphics;"
            fi
        fi
        
        # Install video editing for motion graphics
        if confirm_action "Install video editing for motion graphics" "Advanced video editing tools"; then
            local video_tools=(
                kdenlive
                openshot
                flowblade
                natron         # Compositing
                davinci-resolve # Professional (manual install)
            )
            
            install_packages kdenlive openshot flowblade
            
            # Install Natron (compositing software)
            if confirm_action "Install Natron" "Professional compositing software"; then
                # Natron usually requires manual installation
                print_info "Natron requires manual download from natrongithub.github.io"
                print_info "Download the Linux version and install manually"
            fi
        fi
        
        print_success "Animation and motion graphics software installed"
    fi
}

# Install web design and UI/UX tools
install_web_design_tools() {
    if confirm_install "Web Design & UI/UX Tools" "Web design, prototyping, and UI design tools"; then
        print_section "Installing Web Design & UI/UX Tools"
        
        # Install design software suitable for web design
        local web_design_tools=(
            inkscape       # Vector graphics
            gimp          # Image editing
            scribus       # Layout
            bluefish      # Web editor
            kompozer      # Web composer
            seamonkey     # Web suite
        )
        
        install_packages "${web_design_tools[@]}"
        
        # Install modern web design tools via Snap/Flatpak
        if command_exists snap && confirm_action "Install modern UI/UX tools" "Figma, Adobe XD alternatives"; then
            local ui_tools=(
                figma-linux
                penpot-desktop
                akira
            )
            install_snap_packages "${ui_tools[@]}"
        fi
        
        # Install prototyping tools
        if confirm_action "Install prototyping tools" "Wireframing and prototyping software"; then
            local prototyping_tools=(
                pencil         # Prototyping tool
                balsamiq-mockups-3
                umbrello       # UML tool
                dia            # Diagram editor
            )
            
            install_packages pencil umbrello dia
            
            # Install MockFlow (create launcher for web app)
            if confirm_action "Create MockFlow launcher" "Web-based wireframing tool"; then
                create_desktop_entry "MockFlow" "xdg-open https://mockflow.com/" "/usr/share/pixmaps/web-browser.png" "Web-based Wireframing Tool" "Graphics;WebDevelopment;"
            fi
        fi
        
        print_success "Web design and UI/UX tools installed"
    fi
}

# Install photography and image management tools
install_photography_tools() {
    if confirm_install "Photography Tools" "Photo management, RAW processing, and photography utilities"; then
        print_section "Installing Photography Tools"
        
        local photo_tools=(
            darktable      # RAW processor
            rawtherapee    # RAW processor
            shotwell       # Photo manager
            digikam        # Professional photo management
            rapid-photo-downloader # Photo import
            gthumb         # Image viewer/organizer
            gwenview       # KDE image viewer
            nomacs         # Image viewer
            photoqt        # Image viewer
            hugin          # Panorama creator
            luminance-hdr  # HDR processor
            enfuse         # Exposure fusion
            exiftool       # Metadata editor
        )
        
        install_packages "${photo_tools[@]}"
        
        # Install additional photography utilities
        if confirm_action "Install additional photography utilities" "Specialized photo tools"; then
            local additional_photo_tools=(
                gphoto2        # Camera control
                entangle       # Camera tethering
                photoflare     # Photo editor
                fotoxx         # Photo editor
                rawstudio      # RAW converter
                ufraw          # RAW converter
            )
            install_packages "${additional_photo_tools[@]}"
        fi
        
        # Install photo enhancement tools
        if confirm_action "Install photo enhancement tools" "Noise reduction, sharpening, etc."; then
            # Most are integrated into the main tools above
            print_info "Photo enhancement plugins are included with darktable and GIMP"
            
            # Install additional enhancement tools
            local enhancement_tools=(
                imagemagick    # Command-line image processing
                graphicsmagick # GraphicsMagick
                optipng        # PNG optimizer
                jpegoptim      # JPEG optimizer
                pngquant       # PNG quantizer
            )
            install_packages "${enhancement_tools[@]}"
        fi
        
        print_success "Photography tools installed"
    fi
}

# Configure graphics drivers and acceleration
configure_graphics_drivers() {
    if confirm_install "Graphics Drivers & Acceleration" "GPU drivers and hardware acceleration"; then
        print_section "Configuring Graphics Drivers & Acceleration"
        
        # Detect graphics hardware
        local gpu_info=$(lspci | grep -i vga)
        print_info "Detected graphics hardware: $gpu_info"
        
        # Install Mesa and common graphics libraries
        local graphics_libs=(
            mesa-utils
            mesa-vulkan-drivers
            libgl1-mesa-dri
            libglx-mesa0
            libgl1-mesa-glx
            libegl1-mesa
            libgles2-mesa
            va-driver-all
            vdpau-driver-all
        )
        
        install_packages "${graphics_libs[@]}"
        
        # NVIDIA drivers
        if echo "$gpu_info" | grep -qi nvidia; then
            if confirm_action "Install NVIDIA proprietary drivers" "Better performance for NVIDIA GPUs"; then
                local nvidia_packages=(
                    nvidia-driver-535
                    nvidia-settings
                    nvidia-prime
                    libnvidia-encode-535
                    libnvidia-decode-535
                )
                install_packages "${nvidia_packages[@]}"
                print_warning "Reboot required for NVIDIA drivers to take effect"
            fi
        fi
        
        # AMD drivers
        if echo "$gpu_info" | grep -qi amd; then
            print_info "AMD drivers are included in the kernel and Mesa"
            local amd_packages=(
                firmware-amd-graphics
                libdrm-amdgpu1
                xserver-xorg-video-amdgpu
            )
            install_packages "${amd_packages[@]}" || true
        fi
        
        # Intel drivers
        if echo "$gpu_info" | grep -qi intel; then
            local intel_packages=(
                intel-media-va-driver
                i965-va-driver
                intel-gpu-tools
            )
            install_packages "${intel_packages[@]}"
        fi
        
        print_success "Graphics drivers and acceleration configured"
    fi
}

# Main design module execution
main() {
    print_header "Design & Graphics Tools Installation"
    
    install_image_editors
    install_vector_graphics
    install_3d_software
    install_cad_software
    install_publishing_software
    install_font_tools
    install_design_utilities
    install_animation_software
    install_web_design_tools
    install_photography_tools
    configure_graphics_drivers
    
    print_success "Design & graphics tools installation completed"
    
    # Design recommendations
    echo -e "\n${BOLD}${YELLOW}Design & Graphics Recommendations:${RESET}"
    echo -e "${CYAN}• Configure color profiles for accurate color reproduction${RESET}"
    echo -e "${CYAN}• Install additional fonts for better typography options${RESET}"
    echo -e "${CYAN}• Set up graphics tablet drivers if using drawing tablets${RESET}"
    echo -e "${CYAN}• Configure monitor calibration for color accuracy${RESET}"
    echo -e "${CYAN}• Learn keyboard shortcuts for efficient workflow${RESET}"
    echo -e "${CYAN}• Set up backup solutions for design projects${RESET}"
    echo -e "${CYAN}• Consider external storage for large design files${RESET}"
    echo -e "${CYAN}• Update graphics drivers regularly for best performance${RESET}"
}

# Execute main function
main
