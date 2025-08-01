#==============================================================================
# Interactive Multi-Selection Module for Windows
# Provides checkbox-style CLI interface for software selection using modern Windows package managers
#==============================================================================

# Requires PowerShell 5.1 or later
#Requires -Version 5.1

# Set console to UTF-8 for proper character display
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Color definitions using ANSI escape sequences (PowerShell 5.1+)
$Global:Colors = @{
    Reset      = "`e[0m"
    Bold       = "`e[1m"
    Dim        = "`e[2m"
    Red        = "`e[31m"
    Green      = "`e[32m"
    Yellow     = "`e[33m"
    Blue       = "`e[34m"
    Purple     = "`e[35m"
    Cyan       = "`e[36m"
    White      = "`e[37m"
}

# Global variables for interactive selection
$Global:SoftwareItems = @{}
$Global:SoftwareDescriptions = @{}
$Global:SoftwareCategories = @{}
$Global:SoftwarePackageManagers = @{}
$Global:SelectedSoftware = @{}
$Global:SoftwareList = @()
$Global:CurrentSelection = 0
$Global:CategoryFilter = ""
$Global:LogFile = "$env:TEMP\windows-setup-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"

# Initialize software catalog with latest technologies
function Initialize-SoftwareCatalog {
    Write-Log "Initializing software catalog..."
    
    # Development Tools
    Add-Software "git" "Git for Windows" "Distributed version control system" "development" "winget"
    Add-Software "vscode" "Visual Studio Code" "Modern code editor with extensions" "development" "winget"
    Add-Software "vsstudio" "Visual Studio 2022 Community" "Full-featured IDE for .NET development" "development" "winget"
    Add-Software "docker" "Docker Desktop" "Container platform for development" "development" "winget"
    Add-Software "nodejs" "Node.js LTS" "JavaScript runtime and package manager" "development" "winget"
    Add-Software "python" "Python 3.12" "Python programming language with pip" "development" "winget"
    Add-Software "dotnet" ".NET 8 SDK" "Latest .NET development framework" "development" "winget"
    Add-Software "powershell" "PowerShell 7" "Cross-platform PowerShell" "development" "winget"
    Add-Software "wsl" "Windows Subsystem for Linux" "Run Linux environments on Windows" "development" "windows-feature"
    Add-Software "rust" "Rust Programming Language" "Systems programming language with Cargo" "development" "winget"
    Add-Software "go" "Go Programming Language" "Modern programming language by Google" "development" "winget"
    Add-Software "java" "OpenJDK 21" "Java Development Kit" "development" "winget"
    Add-Software "androidstudio" "Android Studio" "Official Android development environment" "development" "winget"
    Add-Software "flutter" "Flutter SDK" "Google's UI toolkit for mobile apps" "development" "winget"
    
    # Browsers
    Add-Software "chrome" "Google Chrome" "Popular web browser" "browsers" "winget"
    Add-Software "firefox" "Mozilla Firefox" "Open-source web browser" "browsers" "winget"
    Add-Software "edge" "Microsoft Edge" "Modern web browser (usually pre-installed)" "browsers" "winget"
    Add-Software "brave" "Brave Browser" "Privacy-focused browser" "browsers" "winget"
    Add-Software "opera" "Opera Browser" "Feature-rich web browser" "browsers" "winget"
    Add-Software "vivaldi" "Vivaldi Browser" "Highly customizable browser" "browsers" "winget"
    
    # Databases
    Add-Software "mysql" "MySQL Community Server" "Popular relational database" "databases" "winget"
    Add-Software "postgresql" "PostgreSQL" "Advanced relational database" "databases" "winget"
    Add-Software "mongodb" "MongoDB Community" "NoSQL document database" "databases" "winget"
    Add-Software "redis" "Redis" "In-memory data structure store" "databases" "chocolatey"
    Add-Software "sqlserver" "SQL Server Express" "Microsoft SQL Server database" "databases" "winget"
    Add-Software "sqlite" "SQLite Tools" "Lightweight database engine" "databases" "winget"
    Add-Software "dbeaver" "DBeaver Community" "Universal database management tool" "databases" "winget"
    
    # Cloud & DevOps
    Add-Software "awscli" "AWS CLI v2" "Amazon Web Services command line interface" "cloud" "winget"
    Add-Software "azurecli" "Azure CLI" "Microsoft Azure command line interface" "cloud" "winget"
    Add-Software "terraform" "Terraform" "Infrastructure as Code tool" "cloud" "winget"
    Add-Software "kubectl" "Kubernetes CLI" "Kubernetes command line tool" "cloud" "winget"
    Add-Software "helm" "Helm" "Kubernetes package manager" "cloud" "chocolatey"
    Add-Software "vagrant" "Vagrant" "Development environment manager" "cloud" "winget"
    
    # Text Editors & IDEs
    Add-Software "notepadpp" "Notepad++" "Enhanced text editor" "editors" "winget"
    Add-Software "sublimetext" "Sublime Text 4" "Sophisticated text editor" "editors" "winget"
    Add-Software "atom" "Atom" "Hackable text editor (archived but still useful)" "editors" "winget"
    Add-Software "jetbrains-toolbox" "JetBrains Toolbox" "Manage JetBrains IDEs" "editors" "winget"
    Add-Software "vim" "Vim" "The ubiquitous text editor" "editors" "winget"
    Add-Software "neovim" "Neovim" "Hyperextensible Vim-based text editor" "editors" "winget"
    
    # Communication & Collaboration
    Add-Software "teams" "Microsoft Teams" "Business communication platform" "communication" "winget"
    Add-Software "slack" "Slack" "Team collaboration platform" "communication" "winget"
    Add-Software "discord" "Discord" "Voice and text chat platform" "communication" "winget"
    Add-Software "zoom" "Zoom" "Video conferencing software" "communication" "winget"
    Add-Software "skype" "Skype" "Video calling and messaging" "communication" "winget"
    Add-Software "telegram" "Telegram Desktop" "Secure messaging app" "communication" "winget"
    Add-Software "whatsapp" "WhatsApp Desktop" "Messaging application" "communication" "winget"
    
    # Multimedia & Design
    Add-Software "vlc" "VLC Media Player" "Universal media player" "multimedia" "winget"
    Add-Software "obs" "OBS Studio" "Live streaming and recording software" "multimedia" "winget"
    Add-Software "gimp" "GIMP" "GNU Image Manipulation Program" "multimedia" "winget"
    Add-Software "inkscape" "Inkscape" "Vector graphics editor" "multimedia" "winget"
    Add-Software "blender" "Blender" "3D creation suite" "multimedia" "winget"
    Add-Software "audacity" "Audacity" "Audio editing software" "multimedia" "winget"
    Add-Software "handbrake" "HandBrake" "Video transcoder" "multimedia" "winget"
    Add-Software "paint.net" "Paint.NET" "Image and photo editing software" "multimedia" "winget"
    Add-Software "krita" "Krita" "Digital painting application" "multimedia" "winget"
    
    # System Utilities
    Add-Software "7zip" "7-Zip" "File archiver with high compression ratio" "utilities" "winget"
    Add-Software "winrar" "WinRAR" "Archive manager" "utilities" "winget"
    Add-Software "powertoys" "Microsoft PowerToys" "Windows system utilities" "utilities" "winget"
    Add-Software "sysinternals" "Sysinternals Suite" "Windows troubleshooting utilities" "utilities" "winget"
    Add-Software "processhacker" "Process Hacker" "Advanced process manager" "utilities" "winget"
    Add-Software "wiztree" "WizTree" "Disk space analyzer" "utilities" "winget"
    Add-Software "everything" "Everything" "File search utility" "utilities" "winget"
    Add-Software "windirstat" "WinDirStat" "Disk usage analyzer" "utilities" "winget"
    Add-Software "treesizefree" "TreeSize Free" "Disk space manager" "utilities" "winget"
    
    # Terminal & Command Line
    Add-Software "windowsterminal" "Windows Terminal" "Modern terminal application" "terminal" "winget"
    Add-Software "alacritty" "Alacritty" "Cross-platform GPU-accelerated terminal" "terminal" "winget"
    Add-Software "hyper" "Hyper Terminal" "Electron-based terminal" "terminal" "winget"
    Add-Software "cmder" "Cmder" "Portable console emulator" "terminal" "chocolatey"
    Add-Software "conemu" "ConEmu" "Windows console emulator" "terminal" "winget"
    Add-Software "starship" "Starship" "Cross-shell prompt" "terminal" "winget"
    Add-Software "oh-my-posh" "Oh My Posh" "Prompt theme engine" "terminal" "winget"
    
    # Security & Privacy
    Add-Software "bitdefender" "Bitdefender Antivirus Free" "Antivirus protection" "security" "winget"
    Add-Software "malwarebytes" "Malwarebytes" "Anti-malware protection" "security" "winget"
    Add-Software "keepass" "KeePass" "Password manager" "security" "winget"
    Add-Software "bitwarden" "Bitwarden" "Password manager" "security" "winget"
    Add-Software "veracrypt" "VeraCrypt" "Disk encryption software" "security" "winget"
    Add-Software "wireshark" "Wireshark" "Network protocol analyzer" "security" "winget"
    Add-Software "nmap" "Nmap" "Network discovery and security auditing" "security" "winget"
    
    # Package Managers & Tools
    Add-Software "chocolatey" "Chocolatey" "Package manager for Windows" "package-managers" "manual"
    Add-Software "scoop" "Scoop" "Command-line installer for Windows" "package-managers" "manual"
    Add-Software "vcredist" "Visual C++ Redistributables" "Microsoft Visual C++ runtime libraries" "package-managers" "winget"
    Add-Software "directx" "DirectX Runtime" "DirectX End-User Runtime" "package-managers" "winget"
    
    # Gaming & Entertainment
    Add-Software "steam" "Steam" "Gaming platform" "gaming" "winget"
    Add-Software "epicgames" "Epic Games Launcher" "Epic Games Store client" "gaming" "winget"
    Add-Software "gog" "GOG Galaxy" "GOG Games client" "gaming" "winget"
    Add-Software "origin" "EA App" "Electronic Arts game launcher" "gaming" "winget"
    Add-Software "uplay" "Ubisoft Connect" "Ubisoft game launcher" "gaming" "winget"
    
    # File Transfer & Cloud Storage
    Add-Software "filezilla" "FileZilla" "FTP client" "file-transfer" "winget"
    Add-Software "winscp" "WinSCP" "SFTP/SCP client" "file-transfer" "winget"
    Add-Software "dropbox" "Dropbox" "Cloud storage service" "file-transfer" "winget"
    Add-Software "googledrive" "Google Drive" "Google cloud storage" "file-transfer" "winget"
    Add-Software "onedrive" "OneDrive" "Microsoft cloud storage (usually pre-installed)" "file-transfer" "winget"
    
    # Generate sorted software list
    $Global:SoftwareList = $Global:SoftwareItems.Keys | Sort-Object
    
    Write-Log "Software catalog initialized with $($Global:SoftwareList.Count) items"
}

# Helper function to add software to catalog
function Add-Software {
    param(
        [string]$Key,
        [string]$Name,
        [string]$Description,
        [string]$Category,
        [string]$PackageManager
    )
    
    $Global:SoftwareItems[$Key] = $Name
    $Global:SoftwareDescriptions[$Key] = $Description
    $Global:SoftwareCategories[$Key] = $Category
    $Global:SoftwarePackageManagers[$Key] = $PackageManager
}

# Logging function
function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $Global:LogFile -Append -Encoding UTF8
}

# Console control functions
function Hide-Cursor {
    [Console]::CursorVisible = $false
}

function Show-Cursor {
    [Console]::CursorVisible = $true
}

function Set-CursorPosition {
    param([int]$Top, [int]$Left = 0)
    [Console]::SetCursorPosition($Left, $Top)
}

function Clear-Screen {
    Clear-Host
}

# Draw the interactive selection interface
function Draw-Interface {
    Clear-Screen
    
    # Header
    Write-Host "$($Colors.Bold)$($Colors.Blue)╔══════════════════════════════════════════════════════════════════════╗$($Colors.Reset)"
    Write-Host "$($Colors.Bold)$($Colors.Blue)║                    Windows Software Selection Interface              ║$($Colors.Reset)"
    Write-Host "$($Colors.Bold)$($Colors.Blue)╚══════════════════════════════════════════════════════════════════════╝$($Colors.Reset)"
    Write-Host ""
    
    # Instructions
    Write-Host "$($Colors.Cyan)Instructions:$($Colors.Reset)"
    Write-Host "  $($Colors.Yellow)↑/↓$($Colors.Reset) or $($Colors.Yellow)k/j$($Colors.Reset): Navigate"
    Write-Host "  $($Colors.Yellow)Space$($Colors.Reset): Toggle selection"
    Write-Host "  $($Colors.Yellow)Enter$($Colors.Reset): Confirm selections"
    Write-Host "  $($Colors.Yellow)a$($Colors.Reset): Select all"
    Write-Host "  $($Colors.Yellow)n$($Colors.Reset): Select none"
    Write-Host "  $($Colors.Yellow)c$($Colors.Reset): Filter by category"
    Write-Host "  $($Colors.Yellow)p$($Colors.Reset): Show package manager info"
    Write-Host "  $($Colors.Yellow)q$($Colors.Reset): Quit"
    Write-Host ""
    
    # Category filter info
    if ($Global:CategoryFilter) {
        Write-Host "$($Colors.Purple)Filtered by category: $($Global:CategoryFilter)$($Colors.Reset) (press 'c' to change)"
        Write-Host ""
    }
    
    # Get visible items
    $visibleItems = Get-VisibleItems
    
    if ($visibleItems.Count -eq 0) {
        Write-Host "$($Colors.Red)No software found for category: $($Global:CategoryFilter)$($Colors.Reset)"
        return
    }
    
    # Draw software items
    for ($i = 0; $i -lt $visibleItems.Count; $i++) {
        $item = $visibleItems[$i]
        $selectedMarker = if ($Global:SelectedSoftware[$item]) { "$($Colors.Green)[✓]$($Colors.Reset)" } else { "$($Colors.Red)[ ]$($Colors.Reset)" }
        $cursorMarker = if ($i -eq $Global:CurrentSelection) { "$($Colors.Yellow)▶ $($Colors.Reset)" } else { "  " }
        
        # Category badge with color
        $category = $Global:SoftwareCategories[$item]
        $categoryColor = Get-CategoryColor $category
        
        # Package manager badge
        $packageManager = $Global:SoftwarePackageManagers[$item]
        $pmColor = Get-PackageManagerColor $packageManager
        
        Write-Host "$cursorMarker$selectedMarker $categoryColor[$category]$($Colors.Reset) $pmColor($packageManager)$($Colors.Reset) $($Colors.Bold)$($Global:SoftwareItems[$item])$($Colors.Reset)"
        Write-Host "    $($Colors.Dim)$($Global:SoftwareDescriptions[$item])$($Colors.Reset)"
        Write-Host ""
    }
    
    # Footer with selection count
    $selectedCount = ($Global:SelectedSoftware.Values | Where-Object { $_ }).Count
    Write-Host "$($Colors.Bold)$($Colors.Cyan)Selected: $selectedCount items$($Colors.Reset)"
}

# Get category color
function Get-CategoryColor {
    param([string]$Category)
    
    switch ($Category) {
        "development" { return $Colors.Blue }
        "browsers" { return $Colors.Green }
        "databases" { return $Colors.Purple }
        "multimedia" { return $Colors.Cyan }
        "communication" { return $Colors.Yellow }
        "utilities" { return $Colors.White }
        "security" { return $Colors.Red }
        "terminal" { return "$($Colors.Bold)$($Colors.Green)" }
        "cloud" { return "$($Colors.Bold)$($Colors.Cyan)" }
        "editors" { return "$($Colors.Bold)$($Colors.Blue)" }
        "gaming" { return "$($Colors.Bold)$($Colors.Purple)" }
        "file-transfer" { return "$($Colors.Bold)$($Colors.Yellow)" }
        "package-managers" { return "$($Colors.Bold)$($Colors.White)" }
        default { return $Colors.Reset }
    }
}

# Get package manager color
function Get-PackageManagerColor {
    param([string]$PackageManager)
    
    switch ($PackageManager) {
        "winget" { return $Colors.Green }
        "chocolatey" { return $Colors.Blue }
        "scoop" { return $Colors.Purple }
        "manual" { return $Colors.Yellow }
        "windows-feature" { return $Colors.Cyan }
        default { return $Colors.Reset }
    }
}

# Get visible items based on category filter
function Get-VisibleItems {
    if ($Global:CategoryFilter) {
        return $Global:SoftwareList | Where-Object { $Global:SoftwareCategories[$_] -eq $Global:CategoryFilter }
    } else {
        return $Global:SoftwareList
    }
}

# Handle keyboard input
function Handle-Input {
    $visibleItems = Get-VisibleItems
    $maxIndex = $visibleItems.Count - 1
    
    if ($maxIndex -lt 0) {
        return $false
    }
    
    while ($true) {
        $key = [Console]::ReadKey($true)
        
        switch ($key.Key) {
            "UpArrow" {
                if ($Global:CurrentSelection -gt 0) { $Global:CurrentSelection-- }
            }
            "DownArrow" {
                if ($Global:CurrentSelection -lt $maxIndex) { $Global:CurrentSelection++ }
            }
            default {
                switch ($key.KeyChar) {
                    'k' {
                        if ($Global:CurrentSelection -gt 0) { $Global:CurrentSelection-- }
                    }
                    'j' {
                        if ($Global:CurrentSelection -lt $maxIndex) { $Global:CurrentSelection++ }
                    }
                    ' ' {
                        $currentItem = $visibleItems[$Global:CurrentSelection]
                        $Global:SelectedSoftware[$currentItem] = -not $Global:SelectedSoftware[$currentItem]
                    }
                    'a' {
                        foreach ($item in $visibleItems) {
                            $Global:SelectedSoftware[$item] = $true
                        }
                    }
                    'n' {
                        foreach ($item in $visibleItems) {
                            $Global:SelectedSoftware[$item] = $false
                        }
                    }
                    'c' {
                        Show-CategoryMenu
                        $visibleItems = Get-VisibleItems
                        $maxIndex = $visibleItems.Count - 1
                        $Global:CurrentSelection = 0
                    }
                    'p' {
                        Show-PackageManagerInfo
                    }
                    "`r" { # Enter key
                        return $true
                    }
                    'q' {
                        return $false
                    }
                }
            }
        }
        
        Draw-Interface
    }
}

# Show category selection menu
function Show-CategoryMenu {
    Clear-Screen
    Write-Host "$($Colors.Bold)$($Colors.Blue)Select Category Filter:$($Colors.Reset)`n"
    
    $categories = @("all", "development", "browsers", "databases", "cloud", "editors", "communication", "multimedia", "terminal", "utilities", "security", "gaming", "file-transfer", "package-managers")
    $currentCatSelection = 0
    
    while ($true) {
        Set-CursorPosition 3 0
        
        for ($i = 0; $i -lt $categories.Count; $i++) {
            $cat = $categories[$i]
            $marker = if ($i -eq $currentCatSelection) { "$($Colors.Yellow)▶ $($Colors.Reset)" } else { "  " }
            
            if ($cat -eq "all") {
                Write-Host "$marker$($Colors.Bold)All Categories$($Colors.Reset)"
            } else {
                $categoryColor = Get-CategoryColor $cat
                Write-Host "$marker$categoryColor$($Colors.Bold)$($cat.Substring(0,1).ToUpper() + $cat.Substring(1))$($Colors.Reset)"
            }
        }
        
        Write-Host "`n$($Colors.Cyan)Press Enter to select, q to cancel$($Colors.Reset)"
        
        $key = [Console]::ReadKey($true)
        
        switch ($key.Key) {
            "UpArrow" {
                if ($currentCatSelection -gt 0) { $currentCatSelection-- }
            }
            "DownArrow" {
                if ($currentCatSelection -lt ($categories.Count - 1)) { $currentCatSelection++ }
            }
            default {
                switch ($key.KeyChar) {
                    'k' {
                        if ($currentCatSelection -gt 0) { $currentCatSelection-- }
                    }
                    'j' {
                        if ($currentCatSelection -lt ($categories.Count - 1)) { $currentCatSelection++ }
                    }
                    "`r" { # Enter
                        $selectedCat = $categories[$currentCatSelection]
                        $Global:CategoryFilter = if ($selectedCat -eq "all") { "" } else { $selectedCat }
                        return
                    }
                    'q' {
                        return
                    }
                }
            }
        }
    }
}

# Show package manager information
function Show-PackageManagerInfo {
    Clear-Screen
    Write-Host "$($Colors.Bold)$($Colors.Blue)Package Managers Information:$($Colors.Reset)`n"
    
    Write-Host "$($Colors.Green)winget$($Colors.Reset) - Windows Package Manager (built into Windows 10/11)"
    Write-Host "  Official Microsoft package manager, pre-installed on modern Windows"
    Write-Host ""
    
    Write-Host "$($Colors.Blue)chocolatey$($Colors.Reset) - The Package Manager for Windows"
    Write-Host "  Community-driven package manager, requires separate installation"
    Write-Host ""
    
    Write-Host "$($Colors.Purple)scoop$($Colors.Reset) - A command-line installer for Windows"
    Write-Host "  Lightweight package manager, installs to user directory"
    Write-Host ""
    
    Write-Host "$($Colors.Yellow)manual$($Colors.Reset) - Manual installation required"
    Write-Host "  Some software requires manual download and installation"
    Write-Host ""
    
    Write-Host "$($Colors.Cyan)windows-feature$($Colors.Reset) - Windows optional features"
    Write-Host "  Built-in Windows features that can be enabled/disabled"
    Write-Host ""
    
    Write-Host "$($Colors.Cyan)Press any key to return...$($Colors.Reset)"
    [Console]::ReadKey($true) | Out-Null
}

# Main interactive selection function
function Start-InteractiveSoftwareSelection {
    Write-Host "$($Colors.Bold)$($Colors.Green)Initializing Windows Software Selection Interface...$($Colors.Reset)"
    
    Initialize-SoftwareCatalog
    
    # Initialize all software as unselected
    foreach ($item in $Global:SoftwareList) {
        $Global:SelectedSoftware[$item] = $false
    }
    
    try {
        Hide-Cursor
        Draw-Interface
        
        if (Handle-Input) {
            Show-Cursor
            Clear-Screen
            
            # Show selected items
            Write-Host "$($Colors.Bold)$($Colors.Green)Selected Software:$($Colors.Reset)`n"
            $hasSelections = $false
            
            foreach ($item in $Global:SoftwareList) {
                if ($Global:SelectedSoftware[$item]) {
                    $packageManager = $Global:SoftwarePackageManagers[$item]
                    $pmColor = Get-PackageManagerColor $packageManager
                    Write-Host "  $($Colors.Green)✓$($Colors.Reset) $($Global:SoftwareItems[$item]) $pmColor($packageManager)$($Colors.Reset)"
                    Write-Host "    $($Colors.Dim)$($Global:SoftwareDescriptions[$item])$($Colors.Reset)"
                    $hasSelections = $true
                }
            }
            
            if (-not $hasSelections) {
                Write-Host "$($Colors.Yellow)No software selected.$($Colors.Reset)"
                return $false
            }
            
            Write-Host ""
            $confirmation = Read-Host "Proceed with Installation? (y/N)"
            return ($confirmation -eq 'y' -or $confirmation -eq 'Y')
        } else {
            Show-Cursor
            Clear-Screen
            Write-Host "$($Colors.Yellow)Installation cancelled.$($Colors.Reset)"
            return $false
        }
    } finally {
        Show-Cursor
    }
}

# Get list of selected software
function Get-SelectedSoftware {
    return $Global:SoftwareList | Where-Object { $Global:SelectedSoftware[$_] }
}

# Check if package manager is available
function Test-PackageManager {
    param([string]$PackageManager)
    
    switch ($PackageManager) {
        "winget" {
            try {
                $null = Get-Command winget -ErrorAction Stop
                return $true
            } catch {
                return $false
            }
        }
        "chocolatey" {
            try {
                $null = Get-Command choco -ErrorAction Stop
                return $true
            } catch {
                return $false
            }
        }
        "scoop" {
            try {
                $null = Get-Command scoop -ErrorAction Stop
                return $true
            } catch {
                return $false
            }
        }
        default {
            return $true
        }
    }
}

# Install package manager if needed
function Install-PackageManager {
    param([string]$PackageManager)
    
    switch ($PackageManager) {
        "chocolatey" {
            Write-Host "$($Colors.Yellow)Installing Chocolatey...$($Colors.Reset)"
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            RefreshEnv
        }
        "scoop" {
            Write-Host "$($Colors.Yellow)Installing Scoop...$($Colors.Reset)"
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-RestMethod get.scoop.sh | Invoke-Expression
        }
        "winget" {
            Write-Host "$($Colors.Red)winget should be pre-installed on Windows 10/11. Please update Windows or install from Microsoft Store.$($Colors.Reset)"
        }
    }
}

# Install selected software
function Install-SelectedSoftware {
    $selectedItems = Get-SelectedSoftware
    
    if ($selectedItems.Count -eq 0) {
        Write-Host "$($Colors.Yellow)No software selected for installation$($Colors.Reset)"
        return
    }
    
    Write-Host "$($Colors.Bold)$($Colors.Blue)Installing Selected Software$($Colors.Reset)`n"
    Write-Log "Starting installation of $($selectedItems.Count) software packages"
    
    # Import installation functions
    $installFunctionsPath = "$PSScriptRoot\modules\install-functions.ps1"
    if (Test-Path $installFunctionsPath) {
        . $installFunctionsPath
    } else {
        Write-Host "$($Colors.Red)Installation functions not found. Using basic installation methods.$($Colors.Reset)"
    }
    
    $totalItems = $selectedItems.Count
    $currentItem = 0
    $failedInstallations = @()
    
    # Group items by category for better organization
    $categoryGroups = @{}
    foreach ($item in $selectedItems) {
        $category = $Global:SoftwareCategories[$item]
        if (-not $categoryGroups.ContainsKey($category)) {
            $categoryGroups[$category] = @()
        }
        $categoryGroups[$category] += $item
    }
    
    # Install by category
    foreach ($category in $categoryGroups.Keys) {
        $categoryItems = $categoryGroups[$category]
        Write-Host "`n$($Colors.Bold)$($Colors.Blue)Installing $($category.ToUpper()) tools...$($Colors.Reset)"
        
        foreach ($item in $categoryItems) {
            $currentItem++
            $softwareName = $Global:SoftwareItems[$item]
            $packageManager = $Global:SoftwarePackageManagers[$item]
            
            Write-Host "[$currentItem/$totalItems] Installing $softwareName..." -ForegroundColor Cyan
            Write-Log "Installing $softwareName using $packageManager"
            
            # Check if package manager is available
            if (-not (Test-PackageManager $packageManager)) {
                Write-Host "$($Colors.Yellow)Package manager '$packageManager' not available. Installing...$($Colors.Reset)"
                Install-PackageManager $packageManager
            }
            
            try {
                switch ($packageManager) {
                    "winget" {
                        $wingetId = Get-WingetId $item
                        if ($wingetId) {
                            winget install --id $wingetId --silent --accept-package-agreements --accept-source-agreements
                        } else {
                            throw "No winget ID found for $item"
                        }
                    }
                    "chocolatey" {
                        $chocoPackage = Get-ChocolateyPackage $item
                        if ($chocoPackage) {
                            choco install $chocoPackage -y
                        } else {
                            throw "No chocolatey package found for $item"
                        }
                    }
                    "scoop" {
                        $scoopPackage = Get-ScoopPackage $item
                        if ($scoopPackage) {
                            scoop install $scoopPackage
                        } else {
                            throw "No scoop package found for $item"
                        }
                    }
                    "windows-feature" {
                        Install-WindowsFeature $item
                    }
                    "manual" {
                        Install-ManualSoftware $item
                    }
                    default {
                        throw "Unknown package manager: $packageManager"
                    }
                }
                
                Write-Host "$($Colors.Green)✓ $softwareName installed successfully$($Colors.Reset)"
                Write-Log "$softwareName installed successfully"
                
                # Post-installation configuration
                Set-PostInstallConfiguration $item
                
            } catch {
                Write-Host "$($Colors.Red)✗ Failed to install $softwareName`: $($_.Exception.Message)$($Colors.Reset)"
                Write-Log "Failed to install $softwareName`: $($_.Exception.Message)"
                $failedInstallations += $item
            }
            
            Start-Sleep -Milliseconds 500  # Small delay for better UX
        }
    }
    
    # Installation summary
    Write-Host "`n$($Colors.Bold)$($Colors.Green)Installation Summary:$($Colors.Reset)"
    Write-Host "Successfully installed: $($totalItems - $failedInstallations.Count)/$totalItems packages"
    
    if ($failedInstallations.Count -gt 0) {
        Write-Host "$($Colors.Red)Failed installations:$($Colors.Reset)"
        foreach ($failed in $failedInstallations) {
            Write-Host "  - $($Global:SoftwareItems[$failed])"
        }
    }
    
    # Show post-installation recommendations
    Show-PostInstallationRecommendations $selectedItems
    
    Write-Host "`nLog file saved to: $Global:LogFile"
    Write-Log "Installation process completed. Total: $totalItems, Failed: $($failedInstallations.Count)"
}

# Refresh environment variables (for chocolatey)
function RefreshEnv {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Get winget package ID for software item
function Get-WingetId {
    param([string]$Item)
    
    $wingetIds = @{
        "git" = "Git.Git"
        "vscode" = "Microsoft.VisualStudioCode"
        "vsstudio" = "Microsoft.VisualStudio.2022.Community"
        "docker" = "Docker.DockerDesktop"
        "nodejs" = "OpenJS.NodeJS.LTS"
        "python" = "Python.Python.3.12"
        "dotnet" = "Microsoft.DotNet.SDK.8"
        "powershell" = "Microsoft.PowerShell"
        "rust" = "Rustlang.Rustup"
        "go" = "GoLang.Go"
        "java" = "Eclipse.Temurin.21.JDK"
        "androidstudio" = "Google.AndroidStudio"
        "flutter" = "Google.Flutter"
        "chrome" = "Google.Chrome"
        "firefox" = "Mozilla.Firefox"
        "edge" = "Microsoft.Edge"
        "brave" = "BraveSoftware.BraveBrowser"
        "opera" = "Opera.Opera"
        "vivaldi" = "VivaldiTechnologies.Vivaldi"
        "mysql" = "Oracle.MySQL"
        "postgresql" = "PostgreSQL.PostgreSQL"
        "mongodb" = "MongoDB.MongoDBCommunityServer"
        "sqlserver" = "Microsoft.SQLServer.2022.Express"
        "sqlite" = "SQLite.SQLite"
        "dbeaver" = "dbeaver.dbeaver"
        "awscli" = "Amazon.AWSCLI"
        "azurecli" = "Microsoft.AzureCLI"
        "terraform" = "HashiCorp.Terraform"
        "kubectl" = "Kubernetes.kubectl"
        "vagrant" = "Hashicorp.Vagrant"
        "notepadpp" = "Notepad++.Notepad++"
        "sublimetext" = "SublimeHQ.SublimeText.4"
        "atom" = "GitHub.Atom"
        "jetbrains-toolbox" = "JetBrains.Toolbox"
        "vim" = "vim.vim"
        "neovim" = "Neovim.Neovim"
        "teams" = "Microsoft.Teams"
        "slack" = "SlackTechnologies.Slack"
        "discord" = "Discord.Discord"
        "zoom" = "Zoom.Zoom"
        "skype" = "Microsoft.Skype"
        "telegram" = "Telegram.TelegramDesktop"
        "whatsapp" = "WhatsApp.WhatsApp"
        "vlc" = "VideoLAN.VLC"
        "obs" = "OBSProject.OBSStudio"
        "gimp" = "GIMP.GIMP"
        "inkscape" = "Inkscape.Inkscape"
        "blender" = "BlenderFoundation.Blender"
        "audacity" = "Audacity.Audacity"
        "handbrake" = "HandBrake.HandBrake"
        "paint.net" = "dotPDN.PaintDotNet"
        "krita" = "KDE.Krita"
        "7zip" = "7zip.7zip"
        "winrar" = "RARLab.WinRAR"
        "powertoys" = "Microsoft.PowerToys"
        "processhacker" = "ProcessHacker.ProcessHacker"
        "wiztree" = "AntibodySoftware.WizTree"
        "everything" = "voidtools.Everything"
        "windirstat" = "WinDirStat.WinDirStat"
        "treesizefree" = "JAMSoftware.TreeSize.Free"
        "windowsterminal" = "Microsoft.WindowsTerminal"
        "alacritty" = "Alacritty.Alacritty"
        "hyper" = "Hyper.Hyper"
        "conemu" = "Maximus5.ConEmu"
        "starship" = "Starship.Starship"
        "oh-my-posh" = "JanDeDobbeleer.OhMyPosh"
        "bitdefender" = "Bitdefender.Bitdefender"
        "malwarebytes" = "Malwarebytes.Malwarebytes"
        "keepass" = "DominikReichl.KeePass"
        "bitwarden" = "Bitwarden.Bitwarden"
        "veracrypt" = "IDRIX.VeraCrypt"
        "wireshark" = "WiresharkFoundation.Wireshark"
        "nmap" = "Insecure.Nmap"
        "vcredist" = "Microsoft.VCRedist.2015+.x64"
        "directx" = "Microsoft.DirectX"
        "steam" = "Valve.Steam"
        "epicgames" = "EpicGames.EpicGamesLauncher"
        "gog" = "GOG.Galaxy"
        "origin" = "ElectronicArts.EADesktop"
        "uplay" = "Ubisoft.Connect"
        "filezilla" = "TimKosse.FileZilla.Client"
        "winscp" = "WinSCP.WinSCP"
        "dropbox" = "Dropbox.Dropbox"
        "googledrive" = "Google.GoogleDrive"
        "onedrive" = "Microsoft.OneDrive"
    }
    
    return $wingetIds[$Item]
}

# Get chocolatey package name for software item
function Get-ChocolateyPackage {
    param([string]$Item)
    
    $chocoPackages = @{
        "redis" = "redis-64"
        "helm" = "kubernetes-helm"
        "cmder" = "cmder"
    }
    
    return $chocoPackages[$Item]
}

# Get scoop package name for software item
function Get-ScoopPackage {
    param([string]$Item)
    
    $scoopPackages = @{
        # Add scoop-specific packages here if needed
    }
    
    return $scoopPackages[$Item]
}

# Install Windows features
function Install-WindowsFeature {
    param([string]$Item)
    
    switch ($Item) {
        "wsl" {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
            Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
            Write-Host "$($Colors.Green)WSL installed. Install a Linux distribution from Microsoft Store.$($Colors.Reset)"
        }
    }
}

# Install software that requires manual installation
function Install-ManualSoftware {
    param([string]$Item)
    
    switch ($Item) {
        "chocolatey" {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            RefreshEnv
        }
        "scoop" {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-RestMethod get.scoop.sh | Invoke-Expression
        }
    }
}

# Post-installation configuration
function Set-PostInstallConfiguration {
    param([string]$Item)
    
    switch ($Item) {
        "git" {
            git config --global init.defaultBranch main
            git config --global core.autocrlf input
            git config --global pull.rebase false
        }
        "nodejs" {
            RefreshEnv
            npm install -g npm@latest
        }
        "python" {
            RefreshEnv
            pip install --upgrade pip
        }
        "vscode" {
            # Install essential VS Code extensions
            $extensions = @(
                "ms-vscode.powershell",
                "ms-python.python",
                "ms-dotnettools.csharp",
                "esbenp.prettier-vscode"
            )
            foreach ($ext in $extensions) {
                try {
                    code --install-extension $ext --force
                } catch {
                    Write-Host "Note: VS Code extensions will be available after restart" -ForegroundColor Yellow
                }
            }
        }
    }
}

# Show post-installation recommendations
function Show-PostInstallationRecommendations {
    param([array]$SelectedItems)
    
    Write-Host "`n$($Colors.Bold)$($Colors.Yellow)📋 Post-Installation Recommendations:$($Colors.Reset)"
    
    if ("docker" -in $SelectedItems) {
        Write-Host "$($Colors.Cyan)• Docker Desktop requires a restart to complete installation$($Colors.Reset)"
    }
    
    if ("wsl" -in $SelectedItems) {
        Write-Host "$($Colors.Cyan)• Install a Linux distribution from Microsoft Store for WSL$($Colors.Reset)"
    }
    
    if ("vscode" -in $SelectedItems) {
        Write-Host "$($Colors.Cyan)• Configure VS Code with your preferred settings and extensions$($Colors.Reset)"
    }
    
    if ("git" -in $SelectedItems) {
        Write-Host "$($Colors.Cyan)• Configure Git with your name and email: git config --global user.name 'Your Name'$($Colors.Reset)"
    }
    
    if ("nodejs" -in $SelectedItems) {
        Write-Host "$($Colors.Cyan)• Consider installing global packages: npm install -g yarn pnpm typescript$($Colors.Reset)"
    }
    
    if ("python" -in $SelectedItems) {
        Write-Host "$($Colors.Cyan)• Consider installing common packages: pip install requests numpy pandas$($Colors.Reset)"
    }
    
    Write-Host "$($Colors.Cyan)• Restart your computer to ensure all changes take effect$($Colors.Reset)"
    Write-Host "$($Colors.Cyan)• Update Windows regularly for security and compatibility$($Colors.Reset)"
}

# Main entry point
function Main {
    # Check if running as administrator
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "$($Colors.Red)This script requires administrator privileges. Please run as Administrator.$($Colors.Reset)"
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    # Initialize logging
    Write-Log "Starting Windows Interactive Software Selection"
    Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-Log "OS: $((Get-WmiObject Win32_OperatingSystem).Caption)"
    
    if (Start-InteractiveSoftwareSelection) {
        Install-SelectedSoftware
    }
    
    Write-Host "`n$($Colors.Green)Thank you for using Windows Interactive Software Selection!$($Colors.Reset)"
    Read-Host "Press Enter to exit"
}

# Export main function for external calling
Export-ModuleMember -Function Main

# Run main if script is executed directly
if ($MyInvocation.InvocationName -ne '.') {
    Main
}
