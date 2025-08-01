# Windows Developer Setup Script v3.0

A modern, interactive software selection interface for Windows that provides a checkbox-style CLI for installing development tools and software using the latest Windows package managers.

## ✨ Features

- **🎯 Interactive Checkbox Interface**: Modern CLI with visual indicators for software selection
- **📦 Multiple Package Managers**: Support for winget, Chocolatey, and Scoop
- **🔧 Latest Technologies**: Includes cutting-edge development tools and frameworks
- **📱 Category Filtering**: Browse software by categories (development, browsers, databases, etc.)
- **⚡ Bulk Operations**: Select all/none with single keypress
- **🎮 Intuitive Navigation**: Vim-style (j/k) and arrow key navigation
- **📊 Progress Tracking**: Real-time installation progress and status
- **🛡️ Safe Installation**: Automatic package manager detection and installation
- **📝 Comprehensive Logging**: Detailed logs saved for troubleshooting

## 🖥️ System Requirements

- **OS**: Windows 10 version 1709 or later (Windows 11 recommended)
- **PowerShell**: Version 5.1 or later (PowerShell 7 recommended)
- **Privileges**: Administrator access required
- **Internet**: Active internet connection for package downloads

## 🚀 Quick Start

1. **Download or Clone**: Get the latest version of the script

   ```cmd
   git clone https://github.com/YourRepo/scripts.git
   cd scripts\windows
   ```

2. **Run as Administrator**: Right-click on `setup-dev.bat` and select "Run as administrator"
3. **Interactive Selection**: Use the checkbox interface to select your software
4. **Installation**: Confirm selections and watch the automated installation

## 🎮 Navigation Controls

| Key            | Action                           |
| -------------- | -------------------------------- |
| `↑/↓` or `j/k` | Navigate through software list   |
| `Space`        | Toggle selection (✓/✗)           |
| `Enter`        | Confirm selections and proceed   |
| `a`            | Select all visible items         |
| `n`            | Deselect all items               |
| `c`            | Filter by category               |
| `p`            | Show package manager information |
| `q`            | Quit selection                   |

## 📦 Software Categories

### 🛠️ Development Tools

- **Git for Windows** - Version control system
- **Visual Studio Code** - Modern code editor
- **Visual Studio 2022 Community** - Full-featured IDE
- **Docker Desktop** - Container platform
- **Node.js LTS** - JavaScript runtime
- **Python 3.12** - Programming language
- **NET 8 SDK** - Microsoft development framework
- **PowerShell 7** - Cross-platform shell
- **WSL** - Windows Subsystem for Linux
- **Rust** - Systems programming language
- **Go** - Google's programming language
- **OpenJDK 21** - Java development kit
- **Android Studio** - Android development IDE
- **Flutter SDK** - Cross-platform app framework

### 🌐 Browsers

- **Google Chrome** - Popular web browser
- **Mozilla Firefox** - Open-source browser
- **Microsoft Edge** - Modern Windows browser
- **Brave Browser** - Privacy-focused browser
- **Opera** - Feature-rich browser
- **Vivaldi** - Highly customizable browser

### 🗄️ Databases

- **MySQL Community** - Popular relational database
- **PostgreSQL** - Advanced open-source database
- **MongoDB Community** - NoSQL document database
- **Redis** - In-memory data store
- **SQL Server Express** - Microsoft database
- **SQLite Tools** - Lightweight database
- **DBeaver Community** - Universal database tool

### ☁️ Cloud & DevOps

- **AWS CLI v2** - Amazon Web Services CLI
- **Azure CLI** - Microsoft Azure CLI
- **Terraform** - Infrastructure as Code
- **Kubernetes CLI** - Container orchestration
- **Helm** - Kubernetes package manager
- **Vagrant** - Development environment manager

### 📝 Text Editors & IDEs

- **Notepad++** - Enhanced text editor
- **Sublime Text 4** - Sophisticated editor
- **JetBrains Toolbox** - IDE manager
- **Vim** - Classic text editor
- **Neovim** - Modern Vim

### 💬 Communication

- **Microsoft Teams** - Business communication
- **Slack** - Team collaboration
- **Discord** - Gaming and community chat
- **Zoom** - Video conferencing
- **Telegram Desktop** - Secure messaging
- **WhatsApp Desktop** - Messaging app

### 🎨 Multimedia & Design

- **VLC Media Player** - Universal media player
- **OBS Studio** - Streaming and recording
- **GIMP** - Image manipulation
- **Inkscape** - Vector graphics editor
- **Blender** - 3D creation suite
- **Audacity** - Audio editing
- **HandBrake** - Video transcoder
- **Paint.NET** - Image editor
- **Krita** - Digital painting

### 🔧 System Utilities

- **7-Zip** - File archiver
- **Microsoft PowerToys** - Windows utilities
- **Process Hacker** - Advanced process manager
- **WizTree** - Disk space analyzer
- **Everything** - File search utility
- **WinDirStat** - Disk usage visualizer

### 💻 Terminal & Command Line

- **Windows Terminal** - Modern terminal app
- **Alacritty** - GPU-accelerated terminal
- **Hyper Terminal** - Electron-based terminal
- **Cmder** - Portable console emulator
- **Starship** - Cross-shell prompt
- **Oh My Posh** - Prompt theme engine

### 🔒 Security & Privacy

- **Bitdefender Free** - Antivirus protection
- **Malwarebytes** - Anti-malware
- **KeePass** - Password manager
- **Bitwarden** - Cloud password manager
- **VeraCrypt** - Disk encryption
- **Wireshark** - Network analyzer
- **Nmap** - Network security scanner

### 🎮 Gaming Platforms

- **Steam** - Gaming platform
- **Epic Games Launcher** - Epic Games Store
- **GOG Galaxy** - DRM-free games
- **EA App** - Electronic Arts launcher
- **Ubisoft Connect** - Ubisoft games

### 📁 File Transfer & Cloud Storage

- **FileZilla** - FTP client
- **WinSCP** - SFTP/SCP client
- **Dropbox** - Cloud storage
- **Google Drive** - Google cloud storage
- **OneDrive** - Microsoft cloud storage

## 📦 Package Managers

The script supports multiple package managers and automatically handles their installation:

### 🟢 winget (Windows Package Manager)

- **Pre-installed** on Windows 10/11
- **Official** Microsoft package manager
- **Recommended** for most software

### 🔵 Chocolatey

- **Community-driven** package manager
- **Extensive** software catalog
- **Automatically installed** when needed

### 🟣 Scoop

- **Lightweight** package manager
- **User directory** installations
- **Developer-focused** packages

### 🟡 Manual Installation

- Some software requires **manual download**
- Script provides **guidance** for manual installs

## 🛠️ Advanced Usage

### Command Line Options

Run PowerShell directly for advanced options:

```powershell
# Run with execution policy bypass
PowerShell -ExecutionPolicy Bypass -File "interactive.ps1"

# Import as module for custom scripting
Import-Module ".\interactive.ps1"
Start-InteractiveSoftwareSelection
```

### Custom Configuration

Modify the software catalog in `interactive.ps1`:

```powershell
# Add custom software
Add-Software "custom-app" "Custom Application" "Description" "category" "winget"
```

### Scripted Installation

For automated environments:

```powershell
# Pre-select software programmatically
$Global:SelectedSoftware["git"] = $true
$Global:SelectedSoftware["vscode"] = $true
Install-SelectedSoftware
```

## 📝 Logging and Troubleshooting

### Log Files

- **Location**: `%TEMP%\windows-setup-YYYY-MM-DD_HH-mm-ss.log`
- **Content**: Detailed installation progress and errors
- **Format**: Timestamped entries with status information

### Common Issues

1. **Administrator Rights**: Ensure you're running as Administrator
2. **PowerShell Version**: Update to PowerShell 7 for best compatibility
3. **Internet Connection**: Verify connectivity for package downloads
4. **Windows Version**: Some packages require Windows 10/11
5. **Antivirus Software**: May block package manager installations

### Manual Package Manager Installation

If automatic installation fails:

**Chocolatey**:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

**Scoop**:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

## 🔄 Updates and Maintenance

### Keeping Software Updated

**winget**:

```cmd
winget upgrade --all
```

**Chocolatey**:

```cmd
choco upgrade all -y
```

**Scoop**:

```cmd
scoop update *
```

### Script Updates

Check the repository regularly for:

- New software additions
- Package manager improvements
- Bug fixes and enhancements
- Windows compatibility updates

## 🤝 Contributing

We welcome contributions to improve the Windows setup script:

1. **Fork** the repository
2. **Create** a feature branch
3. **Add** new software or improvements
4. **Test** thoroughly on different Windows versions
5. **Submit** a pull request

### Adding New Software

1. Add to the software catalog in `Initialize-SoftwareCatalog`
2. Add winget/chocolatey/scoop package mapping
3. Add any post-installation configuration
4. Update this README

## 📋 Comparison with Linux Version

| Feature          | Windows                   | Linux              |
| ---------------- | ------------------------- | ------------------ |
| Package Managers | winget, Chocolatey, Scoop | apt, snap, flatpak |
| Interface        | PowerShell CLI            | Bash CLI           |
| Software Count   | 80+ packages              | 80+ packages       |
| Auto-Updates     | Supported                 | Supported          |
| Categories       | 12 categories             | 8 categories       |
| Installation     | Silent/Automated          | Silent/Automated   |

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Microsoft** for winget and PowerShell
- **Chocolatey Community** for the extensive package repository
- **Scoop Community** for developer-focused packages
- **All software vendors** for creating amazing tools

---

**Note**: This script installs software from third-party sources. Always review software before installation and ensure you trust the sources. The script maintainers are not responsible for any issues that may arise from installed software.
