#!/bin/bash

#==============================================================================
# Security & Networking Tools Module
# Firewall, SSH hardening, VPN, and security utilities
#==============================================================================

# SSH server setup with enhanced security
setup_ssh_server() {
    if confirm_install "SSH Server Setup & Hardening" "Install and configure OpenSSH server with security hardening"; then
        print_section "Setting up SSH Server with Security Hardening"
        
        install_packages openssh-server
        
        print_info "Configuring SSH server..."
        enable_and_start_service ssh
        
        if configure_ssh_safely; then
            if systemctl restart ssh >> "$LOG_FILE" 2>&1; then
                print_success "SSH server configured and restarted successfully"
            else
                print_error "Failed to restart SSH service"
                # Restore backup if restart fails
                if restore_file "/etc/ssh/sshd_config"; then
                    systemctl restart ssh
                    print_info "SSH configuration restored from backup"
                fi
            fi
        fi
    fi
}

# Configure SSH safely with backup
configure_ssh_safely() {
    backup_file "/etc/ssh/sshd_config"
    
    local config_file="/etc/ssh/sshd_config"
    local temp_config="/tmp/sshd_config.tmp"
    
    cp "$config_file" "$temp_config"
    
    # Apply SSH hardening configuration
    cat >> "$temp_config" << 'EOF'

# Enhanced Security Configuration
Protocol 2
Port 22
AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::

# Authentication
PermitRootLogin no
MaxAuthTries 3
MaxSessions 2
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no

# Encryption and Algorithms
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-512
KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256

# Connection
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
TCPKeepAlive yes
Compression delayed

# Logging and Monitoring
SyslogFacility AUTH
LogLevel VERBOSE

# Miscellaneous
PrintMotd no
PrintLastLog yes
X11Forwarding no
X11DisplayOffset 10
AllowTcpForwarding yes
AllowStreamLocalForwarding no
GatewayPorts no
PermitTunnel no
Banner /etc/issue.net
DebianBanner no
EOF

    # Only disable password auth if SSH keys exist for the user
    if [ -n "$CURRENT_USER" ] && [ -d "/home/$CURRENT_USER/.ssh" ] && [ -f "/home/$CURRENT_USER/.ssh/authorized_keys" ]; then
        echo "PasswordAuthentication no" >> "$temp_config"
        print_info "Password authentication disabled (SSH keys detected)"
    else
        echo "PasswordAuthentication yes" >> "$temp_config"
        print_warning "SSH keys not found. Keeping password authentication enabled for safety."
        print_info "To set up SSH keys later, run: ssh-keygen -t ed25519"
    fi
    
    # Test SSH configuration
    if sshd -t -f "$temp_config" 2>/dev/null; then
        mv "$temp_config" "$config_file"
        print_success "SSH configuration updated successfully"
        return 0
    else
        print_error "SSH configuration test failed. Keeping original configuration."
        rm -f "$temp_config"
        return 1
    fi
}

# UFW firewall configuration
setup_firewall() {
    if confirm_install "UFW Firewall Setup" "Configure advanced firewall rules with UFW"; then
        print_section "Configuring UFW Firewall"
        
        install_packages ufw
        
        print_info "Configuring UFW firewall rules..."
        {
            # Reset to defaults
            ufw --force reset
            
            # Default policies
            ufw default deny incoming
            ufw default allow outgoing
            ufw default deny forward
            
            # Allow SSH
            ufw allow 22/tcp comment 'SSH'
            
            # Allow HTTP/HTTPS
            ufw allow 80/tcp comment 'HTTP'
            ufw allow 443/tcp comment 'HTTPS'
            
            # Allow common development ports (optional)
            if confirm_action "Allow common development ports" "Allow ports 3000, 8000, 8080 for development"; then
                ufw allow 3000/tcp comment 'Development'
                ufw allow 8000/tcp comment 'Development'
                ufw allow 8080/tcp comment 'Development'
            fi
            
            # Enable firewall
            ufw --force enable
        } >> "$LOG_FILE" 2>&1
        
        print_success "Firewall configured successfully"
        print_info "Current firewall status:"
        ufw status verbose
    fi
}

# Install and configure Fail2Ban
setup_fail2ban() {
    if confirm_install "Fail2Ban Intrusion Prevention" "Protect against brute-force attacks"; then
        print_section "Installing and Configuring Fail2Ban"
        
        install_packages fail2ban
        
        print_info "Configuring Fail2ban..."
        
        # Create custom jail configuration
        cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
# Ban settings
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd
destemail = root@localhost
sender = root@localhost
mta = sendmail
protocol = tcp
chain = <known/chain>

# Actions
action = %(action_mw)s

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200
findtime = 600

[apache-auth]
enabled = false
port = http,https
filter = apache-auth
logpath = /var/log/apache*/*error.log
maxretry = 6

[nginx-http-auth]
enabled = false
port = http,https
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 6

[postfix]
enabled = false
port = smtp,465,submission
filter = postfix
logpath = /var/log/mail.log
maxretry = 3

[dovecot]
enabled = false
port = pop3,pop3s,imap,imaps,submission,465,sieve
filter = dovecot
logpath = /var/log/mail.log
maxretry = 3
EOF
        
        enable_and_start_service fail2ban
        print_success "Fail2ban configured for SSH protection"
    fi
}

# Install security auditing tools
install_security_tools() {
    if confirm_install "Security Auditing Tools" "Tools: lynis, chkrootkit, rkhunter, clamav, aide"; then
        print_section "Installing Security Auditing Tools"
        
        local packages=(
            lynis
            chkrootkit
            rkhunter
            clamav
            clamav-daemon
            aide
            unhide
            debsums
            acct
            psad
            logwatch
            tiger
        )
        
        install_packages "${packages[@]}"
        
        # Configure ClamAV
        print_info "Configuring ClamAV antivirus..."
        {
            freshclam
            systemctl enable clamav-daemon
            systemctl start clamav-daemon
        } >> "$LOG_FILE" 2>&1
        
        # Initialize AIDE database
        print_info "Initializing AIDE database (this may take a while)..."
        aide --init >> "$LOG_FILE" 2>&1 || true
        if [ -f /var/lib/aide/aide.db.new ]; then
            mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
            print_success "AIDE database initialized"
        fi
        
        print_success "Security auditing tools installed"
    fi
}

# Install VPN tools
install_vpn_tools() {
    if confirm_install "VPN Tools" "OpenVPN, WireGuard, and VPN clients"; then
        print_section "Installing VPN Tools"
        
        local packages=(
            openvpn
            easy-rsa
            wireguard
            wireguard-tools
            strongswan
            network-manager-openvpn
            network-manager-vpnc
            network-manager-strongswan
        )
        
        install_packages "${packages[@]}"
        
        # Enable IP forwarding for VPN server setup
        if confirm_action "Enable IP forwarding" "Required for VPN server functionality"; then
            echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
            echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf
            sysctl -p >> "$LOG_FILE" 2>&1
            print_success "IP forwarding enabled"
        fi
    fi
}

# Install network analysis tools
install_network_tools() {
    if confirm_install "Network Analysis Tools" "Tools: wireshark, nmap, netcat, socat, iperf3"; then
        print_section "Installing Network Analysis Tools"
        
        local packages=(
            wireshark
            nmap
            netcat-openbsd
            socat
            iperf3
            tcpdump
            ettercap-text-only
            dsniff
            nikto
            sqlmap
            dirb
            masscan
            zmap
            hping3
            arping
            fping
        )
        
        install_packages "${packages[@]}"
        
        # Add user to wireshark group for packet capture
        if [ -n "$CURRENT_USER" ]; then
            add_user_to_group "$CURRENT_USER" "wireshark"
        fi
    fi
}

# Install encryption tools
install_encryption_tools() {
    if confirm_install "Encryption & Cryptography Tools" "Tools: gpg, openssl, cryptsetup, veracrypt"; then
        print_section "Installing Encryption & Cryptography Tools"
        
        local packages=(
            gnupg
            gnupg2
            openssl
            cryptsetup
            ecryptfs-utils
            encfs
            steghide
            hashcat
            john
            hydra
            aircrack-ng
        )
        
        install_packages "${packages[@]}"
        
        # Install VeraCrypt
        if confirm_action "Install VeraCrypt" "Cross-platform disk encryption software"; then
            local veracrypt_url="https://launchpad.net/veracrypt/trunk/1.25.9/+download/veracrypt-1.25.9-Ubuntu-22.04-amd64.deb"
            download_and_install "$veracrypt_url" "veracrypt.deb" "VeraCrypt"
        fi
    fi
}

# Configure automatic security updates
setup_auto_updates() {
    if confirm_install "Automatic Security Updates" "Configure unattended-upgrades for automatic security patches"; then
        print_section "Setting up Automatic Security Updates"
        
        install_packages unattended-upgrades apt-listchanges
        
        print_info "Configuring automatic updates..."
        
        # Configure unattended-upgrades
        cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::Package-Blacklist {
};

Unattended-Upgrade::DevRelease "auto";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "false";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-WithUsers "false";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
Unattended-Upgrade::SyslogEnable "true";
Unattended-Upgrade::SyslogFacility "daemon";
Unattended-Upgrade::Verbose "false";
EOF

        # Enable automatic updates
        echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
        echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
        echo 'APT::Periodic::Download-Upgradeable-Packages "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
        echo 'APT::Periodic::AutocleanInterval "7";' >> /etc/apt/apt.conf.d/20auto-upgrades
        
        enable_and_start_service unattended-upgrades
        print_success "Automatic security updates configured"
    fi
}

# Main security module execution
main() {
    print_header "Security & Networking Tools Installation"
    
    setup_ssh_server
    setup_firewall
    setup_fail2ban
    install_security_tools
    install_vpn_tools
    install_network_tools
    install_encryption_tools
    setup_auto_updates
    
    print_success "Security & networking tools installation completed"
    
    # Security recommendations
    echo -e "\n${BOLD}${YELLOW}Security Recommendations:${RESET}"
    echo -e "${CYAN}• Run security audits: lynis audit system${RESET}"
    echo -e "${CYAN}• Check for rootkits: rkhunter --check${RESET}"
    echo -e "${CYAN}• Scan for malware: clamscan -r /home${RESET}"
    echo -e "${CYAN}• Review firewall rules: ufw status verbose${RESET}"
    echo -e "${CYAN}• Monitor failed login attempts: journalctl -u ssh${RESET}"
}

# Execute main function
main
