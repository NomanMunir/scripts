@echo off
setlocal enabledelayedexpansion

REM ==============================================================================
REM Windows Interactive Software Selection Demo
REM Demo script to showcase the new checkbox-style CLI interface for Windows
REM ==============================================================================

echo.
echo ═══════════════════════════════════════════════════════════════════════════
echo                    Windows Interactive Features Demo
echo ═══════════════════════════════════════════════════════════════════════════
echo.

echo 🎯 New Interactive Software Selection Interface for Windows
echo.
echo Features:
echo   ✓ Checkbox-style interface for multiple selections
echo   ✓ Category-based filtering (development, browsers, databases, etc.)
echo   ✓ Support for winget, Chocolatey, and Scoop package managers
echo   ✓ 80+ modern software packages and tools
echo   ✓ Vim-style navigation (j/k) and arrow keys
echo   ✓ Visual progress indicators with descriptions
echo   ✓ Bulk operations (select all/none)
echo   ✓ Real-time selection counter
echo   ✓ Package manager auto-detection and installation
echo.

echo 🎮 Navigation Controls:
echo   ↑/↓ or k/j: Navigate through software list
echo   Space: Toggle selection (✓/✗)
echo   Enter: Confirm selections and proceed
echo   a: Select all visible items
echo   n: Deselect all items
echo   c: Filter by category
echo   p: Show package manager info
echo   q: Quit selection
echo.

echo 📦 Available Software Categories:
echo   🛠️ [development] Git, VS Code, Docker, Node.js, Python, .NET, WSL
echo   🌐 [browsers] Chrome, Firefox, Edge, Brave, Opera, Vivaldi
echo   🗄️ [databases] MySQL, PostgreSQL, MongoDB, Redis, SQL Server
echo   ☁️ [cloud] AWS CLI, Azure CLI, Terraform, Kubernetes, Helm
echo   📝 [editors] Notepad++, Sublime Text, JetBrains Toolbox, Vim
echo   💬 [communication] Teams, Slack, Discord, Zoom, Telegram
echo   🎨 [multimedia] VLC, OBS Studio, GIMP, Blender, Audacity
echo   🔧 [utilities] 7-Zip, PowerToys, Everything, WizTree
echo   💻 [terminal] Windows Terminal, Alacritty, Starship, Oh My Posh
echo   🔒 [security] Bitdefender, KeePass, Bitwarden, Wireshark
echo   🎮 [gaming] Steam, Epic Games, GOG Galaxy, EA App
echo   📁 [file-transfer] FileZilla, WinSCP, Dropbox, Google Drive
echo.

echo 📦 Package Manager Support:
echo   🟢 winget - Windows Package Manager (official, pre-installed)
echo   🔵 Chocolatey - Community package manager (extensive catalog)
echo   🟣 Scoop - Lightweight, developer-focused packages
echo   🟡 Manual - Guided manual installation when needed
echo.

echo 🚀 How to Use:
echo 1. Run the setup script: setup-dev.bat (as Administrator)
echo 2. Use the interactive interface to select your software
echo 3. Press Enter to confirm and start installation
echo 4. Enjoy your fully configured development environment!
echo.

echo 💡 Benefits over manual installation:
echo   ✓ No more searching for download links
echo   ✓ Automatic dependency management
echo   ✓ Silent installations with no user prompts
echo   ✓ Multiple selections in one go
echo   ✓ Modern, intuitive interface
echo   ✓ Consistent installation across machines
echo   ✓ Support for latest software versions
echo.

echo 🔄 System Requirements:
echo   • Windows 10 version 1709+ (Windows 11 recommended)
echo   • PowerShell 5.1+ (PowerShell 7 recommended)
echo   • Administrator privileges
echo   • Active internet connection
echo.

echo ⚡ Latest Technologies Included:
echo   • .NET 8 SDK (latest LTS)
echo   • Python 3.12 (latest stable)
echo   • Node.js LTS (with npm, yarn, pnpm)
echo   • Docker Desktop (with WSL2 backend)
echo   • Visual Studio 2022 Community
echo   • OpenJDK 21 (latest LTS)
echo   • PowerShell 7 (cross-platform)
echo   • Windows Terminal (modern terminal app)
echo   • WSL2 (Windows Subsystem for Linux)
echo.

echo Ready to try it? Run: setup-dev.bat (as Administrator)
echo.
pause
