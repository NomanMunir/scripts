#!/bin/bash

#==============================================================================
# Virtualization & Containers Module
# Docker, VirtualBox, QEMU, and container technologies
#==============================================================================

# Install Docker and Docker Compose
install_docker() {
    if confirm_install "Docker & Docker Compose" "Container platform for development and deployment"; then
        print_section "Installing Docker & Docker Compose"
        
        # Remove old Docker installations
        apt remove -y docker docker-engine docker.io containerd runc >> "$LOG_FILE" 2>&1 || true
        
        # Install prerequisites
        local prereq_packages=(
            apt-transport-https
            ca-certificates
            curl
            gnupg
            lsb-release
        )
        install_packages "${prereq_packages[@]}"
        
        # Add Docker repository
        print_info "Adding Docker repository..."
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        apt update >> "$LOG_FILE" 2>&1
        
        # Install Docker
        local docker_packages=(
            docker-ce
            docker-ce-cli
            containerd.io
            docker-buildx-plugin
            docker-compose-plugin
        )
        install_packages "${docker_packages[@]}"
        
        # Start and enable Docker
        enable_and_start_service docker
        
        # Add user to docker group
        if [ -n "$CURRENT_USER" ]; then
            add_user_to_group "$CURRENT_USER" "docker"
            print_warning "User '$CURRENT_USER' needs to log out and back in for docker group changes to take effect"
        fi
        
        # Install Docker Compose standalone (v1 compatibility)
        if confirm_action "Install Docker Compose standalone" "Install docker-compose command for v1 compatibility"; then
            print_info "Installing Docker Compose standalone..."
            local compose_version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
            curl -L "https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
            print_success "Docker Compose standalone installed"
        fi
        
        # Install Docker Desktop for Linux
        if confirm_action "Install Docker Desktop" "GUI application for Docker management"; then
            local desktop_url="https://desktop.docker.com/linux/main/amd64/docker-desktop-4.25.2-amd64.deb"
            download_and_install "$desktop_url" "docker-desktop.deb" "Docker Desktop"
        fi
        
        print_success "Docker installation completed"
        print_info "Test Docker: docker run hello-world"
    fi
}

# Install Podman (Docker alternative)
install_podman() {
    if confirm_install "Podman" "Daemonless container engine"; then
        print_section "Installing Podman"
        
        local packages=(
            podman
            podman-compose
            buildah
            skopeo
            runc
        )
        
        install_packages "${packages[@]}"
        
        # Configure Podman for rootless containers
        if [ -n "$CURRENT_USER" ]; then
            print_info "Configuring Podman for rootless containers..."
            
            # Enable lingering for user
            loginctl enable-linger "$CURRENT_USER" >> "$LOG_FILE" 2>&1 || true
            
            # Configure subuid and subgid
            if ! grep -q "$CURRENT_USER" /etc/subuid; then
                echo "$CURRENT_USER:100000:65536" >> /etc/subuid
            fi
            if ! grep -q "$CURRENT_USER" /etc/subgid; then
                echo "$CURRENT_USER:100000:65536" >> /etc/subgid
            fi
            
            print_success "Podman configured for rootless operation"
        fi
        
        print_success "Podman installed"
    fi
}

# Install VirtualBox
install_virtualbox() {
    if confirm_install "Oracle VirtualBox" "Type-2 hypervisor for running virtual machines"; then
        print_section "Installing Oracle VirtualBox"
        
        # Add VirtualBox repository
        print_info "Adding VirtualBox repository..."
        curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor -o /usr/share/keyrings/virtualbox-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/virtualbox-keyring.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | tee /etc/apt/sources.list.d/virtualbox.list
        
        apt update >> "$LOG_FILE" 2>&1
        
        # Install VirtualBox
        local virtualbox_packages=(
            virtualbox-7.0
            virtualbox-ext-pack
            virtualbox-guest-additions-iso
        )
        
        install_packages "${virtualbox_packages[@]}"
        
        # Add user to vboxusers group
        if [ -n "$CURRENT_USER" ]; then
            add_user_to_group "$CURRENT_USER" "vboxusers"
        fi
        
        print_success "VirtualBox installed"
        print_info "Download VMs from: https://www.osboxes.org/"
    fi
}

# Install VMware Workstation Player (free)
install_vmware_player() {
    if confirm_install "VMware Workstation Player" "Free VMware virtualization software"; then
        print_section "Installing VMware Workstation Player"
        
        # Download VMware Workstation Player
        print_info "VMware Workstation Player requires manual download"
        print_info "Please visit: https://www.vmware.com/products/workstation-player.html"
        print_info "Download the .bundle file and run it manually"
        
        # Install dependencies
        local vmware_deps=(
            build-essential
            linux-headers-$(uname -r)
            gcc
            make
        )
        
        install_packages "${vmware_deps[@]}"
        
        print_warning "Complete VMware installation manually after downloading"
    fi
}

# Install QEMU/KVM
install_qemu_kvm() {
    if confirm_install "QEMU/KVM" "Kernel-based virtual machine hypervisor"; then
        print_section "Installing QEMU/KVM"
        
        # Check for virtualization support
        if ! grep -qE "(vmx|svm)" /proc/cpuinfo; then
            print_warning "Hardware virtualization not detected. KVM may not work properly."
        fi
        
        local qemu_packages=(
            qemu-kvm
            qemu-system
            qemu-utils
            libvirt-daemon-system
            libvirt-clients
            bridge-utils
            virt-manager
            virt-viewer
            ovmf
            gir1.2-spiceclientgtk-3.0
        )
        
        install_packages "${qemu_packages[@]}"
        
        # Enable and start libvirt
        enable_and_start_service libvirtd
        
        # Add user to libvirt group
        if [ -n "$CURRENT_USER" ]; then
            add_user_to_group "$CURRENT_USER" "libvirt"
            add_user_to_group "$CURRENT_USER" "kvm"
        fi
        
        # Enable nested virtualization (if supported)
        if confirm_action "Enable nested virtualization" "Allow VMs to run hypervisors"; then
            echo "options kvm_intel nested=1" > /etc/modprobe.d/kvm.conf
            echo "options kvm_amd nested=1" >> /etc/modprobe.d/kvm.conf
            print_info "Nested virtualization enabled (requires reboot)"
        fi
        
        print_success "QEMU/KVM installed"
        print_info "Use virt-manager for GUI VM management"
    fi
}

# Install container orchestration tools
install_orchestration() {
    if confirm_install "Container Orchestration" "Kubernetes, Docker Swarm, and related tools"; then
        print_section "Installing Container Orchestration Tools"
        
        # Install kubectl
        if confirm_action "Install kubectl" "Kubernetes command-line tool"; then
            print_info "Installing kubectl..."
            curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
            apt update >> "$LOG_FILE" 2>&1
            install_packages kubectl
        fi
        
        # Install Minikube
        if confirm_action "Install Minikube" "Local Kubernetes development environment"; then
            print_info "Installing Minikube..."
            curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
            install -o root -g root -m 0755 minikube-linux-amd64 /usr/local/bin/minikube
            rm minikube-linux-amd64
            print_success "Minikube installed"
        fi
        
        # Install Kind
        if confirm_action "Install Kind" "Kubernetes in Docker"; then
            print_info "Installing Kind..."
            curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
            chmod +x ./kind
            mv ./kind /usr/local/bin/kind
            print_success "Kind installed"
        fi
        
        # Install k3s
        if confirm_action "Install k3s" "Lightweight Kubernetes distribution"; then
            print_info "Installing k3s..."
            curl -sfL https://get.k3s.io | sh -s - >> "$LOG_FILE" 2>&1
            print_success "k3s installed"
        fi
        
        # Install Helm
        if confirm_action "Install Helm" "Kubernetes package manager"; then
            print_info "Installing Helm..."
            curl https://baltocdn.com/helm/signing.asc | gpg --dearmor -o /usr/share/keyrings/helm-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm-keyring.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
            apt update >> "$LOG_FILE" 2>&1
            install_packages helm
        fi
        
        print_success "Container orchestration tools installed"
    fi
}

# Install container registries and tools
install_container_tools() {
    if confirm_install "Container Tools & Registries" "Registry tools and container utilities"; then
        print_section "Installing Container Tools"
        
        # Install registry tools
        local container_tools=(
            docker-registry
            dive           # Container image analyzer
            ctop           # Container monitoring
            lazydocker     # Docker TUI
        )
        
        # Install available packages
        install_packages docker-registry || true
        
        # Install dive
        if confirm_action "Install dive" "Tool for exploring Docker images"; then
            local dive_url="https://github.com/wagoodman/dive/releases/latest/download/dive_0.10.0_linux_amd64.deb"
            download_and_install "$dive_url" "dive.deb" "dive"
        fi
        
        # Install ctop
        if confirm_action "Install ctop" "Top-like interface for containers"; then
            curl -L https://github.com/bcicen/ctop/releases/latest/download/ctop-0.7.7-linux-amd64 -o /usr/local/bin/ctop
            chmod +x /usr/local/bin/ctop
            print_success "ctop installed"
        fi
        
        # Install lazydocker
        if confirm_action "Install lazydocker" "Terminal UI for Docker"; then
            curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
            print_success "lazydocker installed"
        fi
        
        # Install Portainer
        if confirm_action "Install Portainer" "Docker management web UI"; then
            print_info "Installing Portainer..."
            if command_exists docker; then
                docker volume create portainer_data >> "$LOG_FILE" 2>&1
                docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.19.4 >> "$LOG_FILE" 2>&1
                print_success "Portainer installed and running on https://localhost:9443"
            else
                print_warning "Docker not available for Portainer installation"
            fi
        fi
        
        print_success "Container tools installed"
    fi
}

# Install development environments
install_dev_environments() {
    if confirm_install "Development Environments" "Vagrant, DevContainers, and development tools"; then
        print_section "Installing Development Environments"
        
        # Install Vagrant
        if confirm_action "Install Vagrant" "Tool for building portable development environments"; then
            print_info "Installing Vagrant..."
            local vagrant_url="https://releases.hashicorp.com/vagrant/2.4.0/vagrant_2.4.0-1_amd64.deb"
            download_and_install "$vagrant_url" "vagrant.deb" "Vagrant"
            
            # Install useful Vagrant plugins
            if [ -n "$CURRENT_USER" ]; then
                print_info "Installing Vagrant plugins..."
                sudo -u "$CURRENT_USER" vagrant plugin install vagrant-vbguest >> "$LOG_FILE" 2>&1 || true
                sudo -u "$CURRENT_USER" vagrant plugin install vagrant-disksize >> "$LOG_FILE" 2>&1 || true
            fi
        fi
        
        # Install Dev Container CLI
        if confirm_action "Install Dev Container CLI" "Development containers CLI tool"; then
            if command_exists npm; then
                npm install -g @devcontainers/cli >> "$LOG_FILE" 2>&1
                print_success "Dev Container CLI installed"
            else
                print_warning "npm not available for Dev Container CLI installation"
            fi
        fi
        
        # Install Distrobox
        if confirm_action "Install Distrobox" "Use any Linux distribution inside terminal"; then
            print_info "Installing Distrobox..."
            curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix /usr/local >> "$LOG_FILE" 2>&1
            print_success "Distrobox installed"
        fi
        
        print_success "Development environments installed"
    fi
}

# Install cloud and deployment tools
install_cloud_tools() {
    if confirm_install "Cloud & Deployment Tools" "Cloud CLI tools and deployment utilities"; then
        print_section "Installing Cloud & Deployment Tools"
        
        # Install Terraform
        if confirm_action "Install Terraform" "Infrastructure as Code tool"; then
            print_info "Installing Terraform..."
            curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
            apt update >> "$LOG_FILE" 2>&1
            install_packages terraform
        fi
        
        # Install AWS CLI
        if confirm_action "Install AWS CLI" "Amazon Web Services command-line interface"; then
            print_info "Installing AWS CLI..."
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip -q awscliv2.zip
            ./aws/install >> "$LOG_FILE" 2>&1
            rm -rf aws awscliv2.zip
            print_success "AWS CLI installed"
        fi
        
        # Install Google Cloud CLI
        if confirm_action "Install Google Cloud CLI" "Google Cloud Platform tools"; then
            print_info "Installing Google Cloud CLI..."
            curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
            echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
            apt update >> "$LOG_FILE" 2>&1
            install_packages google-cloud-cli
        fi
        
        # Install Azure CLI
        if confirm_action "Install Azure CLI" "Microsoft Azure command-line interface"; then
            print_info "Installing Azure CLI..."
            curl -sL https://aka.ms/InstallAzureCLIDeb | bash >> "$LOG_FILE" 2>&1
            print_success "Azure CLI installed"
        fi
        
        # Install Ansible
        if confirm_action "Install Ansible" "IT automation and configuration management"; then
            install_packages ansible ansible-core
        fi
        
        print_success "Cloud and deployment tools installed"
    fi
}

# Configure virtualization optimizations
configure_virtualization() {
    if confirm_install "Virtualization Optimizations" "Performance tuning and optimizations"; then
        print_section "Configuring Virtualization Optimizations"
        
        # Enable IOMMU (if supported)
        if confirm_action "Enable IOMMU" "Enable IOMMU for better VM performance"; then
            print_info "Configuring IOMMU..."
            
            # Check CPU vendor
            if grep -q "Intel" /proc/cpuinfo; then
                sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&intel_iommu=on /' /etc/default/grub
            elif grep -q "AMD" /proc/cpuinfo; then
                sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&amd_iommu=on /' /etc/default/grub
            fi
            
            update-grub >> "$LOG_FILE" 2>&1
            print_info "IOMMU configuration added (requires reboot)"
        fi
        
        # Optimize for containers
        if confirm_action "Optimize for containers" "System optimizations for container workloads"; then
            print_info "Applying container optimizations..."
            
            # Increase file descriptor limits
            cat >> /etc/security/limits.conf << 'EOF'

# Container optimizations
* soft nofile 65536
* hard nofile 65536
root soft nofile 65536
root hard nofile 65536
EOF
            
            # Optimize kernel parameters
            cat >> /etc/sysctl.conf << 'EOF'

# Container and virtualization optimizations
vm.max_map_count=262144
fs.inotify.max_user_watches=524288
fs.inotify.max_user_instances=8192
kernel.pid_max=4194304
EOF
            
            sysctl -p >> "$LOG_FILE" 2>&1
            print_success "Container optimizations applied"
        fi
        
        print_success "Virtualization optimizations configured"
    fi
}

# Main virtualization module execution
main() {
    print_header "Virtualization & Containers Installation"
    
    install_docker
    install_podman
    install_virtualbox
    install_vmware_player
    install_qemu_kvm
    install_orchestration
    install_container_tools
    install_dev_environments
    install_cloud_tools
    configure_virtualization
    
    print_success "Virtualization & containers installation completed"
    
    # Virtualization recommendations
    echo -e "\n${BOLD}${YELLOW}Virtualization Recommendations:${RESET}"
    echo -e "${CYAN}• Test Docker: docker run hello-world${RESET}"
    echo -e "${CYAN}• Users need to log out/in for group changes to take effect${RESET}"
    echo -e "${CYAN}• Enable hardware virtualization in BIOS/UEFI${RESET}"
    echo -e "${CYAN}• Consider using VM snapshots before major changes${RESET}"
    echo -e "${CYAN}• Allocate appropriate resources to VMs and containers${RESET}"
    echo -e "${CYAN}• Use container orchestration for production deployments${RESET}"
    echo -e "${CYAN}• Regular backup of VM images and container volumes${RESET}"
}

# Execute main function
main
