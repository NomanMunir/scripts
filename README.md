# Developer Setup Script v3.0

This script automates the installation of essential development tools on **Linux (Debian/Ubuntu)** and **Windows** systems with a completely modular architecture, enhanced user experience, and comprehensive tool coverage.

## 🖥️ Platform Support

- **🐧 Linux**: Debian/Ubuntu systems with apt package manager
- **🪟 Windows**: Windows 10/11 with winget, Chocolatey, and Scoop support

## ✨ New Features in v3.0

- **🎯 Interactive Software Selection**: Modern checkbox-style CLI interface for selecting individual software packages (Linux & Windows)
- **Cross-Platform Support**: Works on Linux (Debian/Ubuntu) and Windows (10/11)
- **Multiple Package Managers**: Linux (apt, snap) and Windows (winget, Chocolatey, Scoop)
- **Latest Technologies**: Includes cutting-edge development tools (.NET 8, Python 3.12, Node.js LTS, etc.)
- **Modular Architecture**: Organized into separate modules for different tool categories
- **Comprehensive Tool Coverage**: 12+ specialized modules covering all developer needs
- **Professional User Interface**: Progress bars, colored output, and clear status messages
- **Enhanced Error Handling**: Comprehensive logging and failure tracking
- **Improved Security**: Safe SSH configuration with backup and validation
- **Better User Experience**: Interactive module selection and intelligent configuration
- **Complete Graphics Suite**: Full design and graphics tools support
- **Comprehensive Logging**: Detailed logs saved to system temp directories
- **Installation Summary**: Complete report with timing and failure tracking
- **Safety Features**: Configuration backups and rollback capabilities
- **Category-based Filtering**: Filter software by categories (development, browsers, databases, etc.)
- **Bulk Operations**: Select all or none with single keypress
- **Vim-style Navigation**: Use j/k or arrow keys for navigation

## 📌 How to Run the Script

### 🐧 Linux (Debian/Ubuntu)

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

### 🪟 Windows (10/11)

1. **Download or clone** the repository
2. **Navigate** to the `windows` folder
3. **Right-click** on `setup-dev.bat` and select "Run as administrator"

Or run manually:

```cmd
git clone https://github.com/NomanMunir/scripts.git
cd scripts\windows
# Right-click setup-dev.bat -> Run as administrator
```

## 🏗️ Installation Methods

### 🎯 Interactive Software Selection (Recommended)

The new interactive interface provides a modern, checkbox-style CLI for selecting individual software packages:

**Features:**

- Checkbox-style interface with visual indicators
- Category-based filtering (development, browsers, databases, etc.)
- Vim-style navigation (j/k) and arrow keys
- Bulk operations (select all/none)
- Real-time selection counter
- Individual software descriptions

**Navigation:**

- `↑/↓` or `j/k`: Navigate through software list
- `Space`: Toggle selection (✓/✗)
- `Enter`: Confirm selections and proceed
- `a`: Select all visible items
- `n`: Deselect all items
- `c`: Filter by category
- `q`: Quit selection

### 📦 Traditional Module-based Installation

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

### 🎯 Interactive Mode Software Catalog

When using the interactive selection, you can choose from the following software packages:

**Development Tools:**

- Git Version Control
- Visual Studio Code
- Docker & Docker Compose
- Node.js & NPM
- Python Development Environment
- Rust Programming Language
- Go Programming Language
- Java Development Kit

**Web Browsers:**

- Google Chrome
- Mozilla Firefox
- Microsoft Edge

**Database Systems:**

- MySQL/MariaDB
- PostgreSQL
- MongoDB
- Redis

**Multimedia Tools:**

- VLC Media Player
- GIMP (GNU Image Manipulation Program)
- OBS Studio

**Communication Tools:**

- Slack
- Discord
- Microsoft Teams

**System Utilities:**

- htop (Interactive process viewer)
- Neofetch (System information display)
- tmux (Terminal multiplexer)
- Zsh + Oh My Zsh (Enhanced shell)

**Security Tools:**

- UFW Firewall
- Fail2Ban (Intrusion prevention)
- SSH Server (with hardening)

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

### Interactive Mode (Recommended)

1. **System Verification**: Check compatibility and privileges
2. **User Setup**: Detect or create non-root user
3. **Interactive Selection**: Use the checkbox interface to select software
4. **Installation**: Install selected software with progress tracking
5. **Configuration**: Apply security hardening and optimization
6. **Summary**: Provide detailed installation report and recommendations

### Traditional Module Mode

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

## 🎯 Try the Interactive Demo

Want to see the new interactive features in action? Run the demo:

```bash
./demo-interactive.sh
```

This will show you all the new features and how to use the interactive selection interface.
