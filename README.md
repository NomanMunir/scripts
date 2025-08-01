# Developer Setup Script v3.0

This script automates the installation of essential development tools on a fresh **Debian/Ubuntu** system with a completely modular architecture, enhanced user experience, and comprehensive tool coverage.

## ✨ New Features in v3.0

- **Modular Architecture**: Organized into separate modules for different tool categories
- **Comprehensive Tool Coverage**: 12 specialized modules covering all developer needs
- **Professional User Interface**: Progress bars, colored output, and clear status messages
- **Enhanced Error Handling**: Comprehensive logging and failure tracking
- **Improved Security**: Safe SSH configuration with backup and validation
- **Better User Experience**: Interactive module selection and intelligent configuration
- **Complete Graphics Suite**: Full design and graphics tools support
- **Comprehensive Logging**: Detailed logs saved to `/var/log/dev-setup-*.log`
- **Installation Summary**: Complete report with timing and failure tracking
- **Safety Features**: Configuration backups and rollback capabilities

## 📌 How to Run the Script

Run the following command in your terminal to execute the setup script:

```bash
cd /path/to/scripts/linux
sudo ./setup-dev.sh
```

Or download and run it manually:

```bash
git clone https://github.com/NomanMunir/scripts.git
cd scripts/linux
chmod +x setup-dev.sh
sudo ./setup-dev.sh
```

## 🏗️ Modular Architecture

The script is organized into the following modules:

### Available Modules

1. **Core System Components** (`core.sh`)

   - Essential system utilities and tools
   - Compression tools, text utilities, monitoring

2. **Security & Networking Tools** (`security.sh`)

   - SSH hardening, firewall, VPN clients
   - Security auditing and network tools

3. **Development Tools & Languages** (`development.sh`)

   - Programming languages (Python, Node.js, Rust, Go, Java, .NET)
   - Compilers, build tools, and package managers

4. **Database Systems** (`databases.sh`)

   - SQL and NoSQL databases
   - Database administration tools

5. **Multimedia Tools & Codecs** (`multimedia.sh`)

   - Audio/video players, editors, codecs
   - Recording and streaming tools

6. **Web Browsers** (`browsers.sh`)

   - Multiple browser options
   - Browser development tools

7. **System Utilities & CLI Tools** (`utils.sh`)

   - Modern CLI tools and terminal enhancers
   - System monitoring and productivity tools

8. **Text Editors & IDEs** (`editors.sh`)

   - Code editors, IDEs, and development environments
   - Configuration and plugin setup

9. **Virtualization & Containers** (`virtualization.sh`)

   - Docker, VirtualBox, QEMU/KVM
   - Container orchestration tools

10. **Communication Tools** (`communication.sh`)

    - Messaging apps, video conferencing
    - Email clients and collaboration tools

11. **Design & Graphics Tools** (`design.sh`) 🆕
    - Image editing (GIMP, Krita, Inkscape)
    - 3D modeling and CAD software
    - Desktop publishing and typography tools
    - Animation and motion graphics
    - Photography and web design tools

Each module can be selected independently, allowing you to install only what you need.

### Shell & Productivity

- **Enhanced Shell**: `zsh` with `Oh My Zsh` framework
- **CLI Tools**: `tmux`, `bat`, `fzf`, `ripgrep`, `jq`, `tree`, `vim`
- **Fonts**: Powerline fonts for better terminal experience

### System Enhancements

- **Time Sync**: `chrony` for accurate time synchronization
- **Security**: Enhanced `fail2ban` configuration
- **Updates**: `unattended-upgrades` for automatic security patches
- **Performance**: Configurable swap file setup

## 🔧 Key Improvements

### User Management

- Intelligent detection of existing non-root users
- Safe user creation with validation
- Proper sudo group assignment

### Security Enhancements

- SSH configuration backup before modifications
- Smart SSH key detection for safe password auth disabling
- Enhanced fail2ban rules with custom timeouts
- UFW firewall with sensible defaults

### Error Handling

- Comprehensive error checking for all operations
- Package installation failure tracking
- Service startup validation
- Configuration rollback on failures

### User Experience

- Progress tracking with visual indicators
- Detailed installation descriptions
- Color-coded status messages
- Comprehensive installation summary
- Post-installation recommendations

## 📊 Installation Process

The script follows this structured approach:

1. **System Verification**: Check compatibility and privileges
2. **User Setup**: Detect or create non-root user
3. **System Update**: Update package lists and upgrade system
4. **Component Installation**: Install selected components with error tracking
5. **Configuration**: Apply security hardening and optimization
6. **Summary**: Provide detailed installation report and recommendations

## 🛡️ Security Features

- **SSH Hardening**: Disable root login, configure logging
- **Firewall Configuration**: UFW with essential ports
- **Fail2ban Protection**: SSH brute-force protection
- **Automatic Updates**: Security patch automation
- **Safe Configuration**: Backup and validation before changes

## 📝 Logging

All installation activities are logged to `/var/log/dev-setup-YYYYMMDD-HHMMSS.log` including:

- Package installation results
- Service configuration changes
- Error messages and troubleshooting info
- Timing information for performance analysis

## 🔄 Customization

The script provides interactive prompts for each component, allowing you to:

- Skip unnecessary components
- Customize installation parameters (e.g., swap file size)
- Choose between automatic and manual configuration

## 📋 Post-Installation

After running the script:

1. **Reboot** your system (recommended)
2. **Log out and back in** as your user to apply group changes
3. **Set up SSH keys**: `ssh-keygen -t ed25519`
4. **Configure Git**: Set your name and email for version control
5. **Test Docker**: `docker run hello-world` (if virtualization module was installed)
6. **Secure MariaDB**: `mysql_secure_installation` (if databases module was installed)
7. **Configure graphics drivers**: Update graphics drivers for design tools (if design module was installed)
8. **Set up development environment**: Configure your preferred IDE and tools
9. **Install additional fonts**: Add custom fonts for design work
10. **Configure monitor calibration**: Set up color profiles for design accuracy

## 🆘 Troubleshooting

If you encounter issues:

1. Check the log file for detailed error information
2. Ensure you're running on a supported Debian/Ubuntu system
3. Verify you have root privileges (`sudo`)
4. Check network connectivity for package downloads

## 📄 License

MIT License - Feel free to modify and distribute
