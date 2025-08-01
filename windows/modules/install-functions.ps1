#==============================================================================
# Windows Software Installation Module
# Contains all installation functions for the interactive software selection
#==============================================================================

# Import the interactive module if not already loaded
if (-not (Get-Module -Name "Interactive" -ErrorAction SilentlyContinue)) {
    Import-Module "$PSScriptRoot\interactive.ps1" -Force
}

# Installation functions for each software category
function Install-DevelopmentTools {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "git" {
                Write-InstallProgress "Git for Windows"
                winget install --id Git.Git --silent --accept-package-agreements --accept-source-agreements
                # Configure Git with some sensible defaults
                git config --global init.defaultBranch main
                git config --global core.autocrlf input
                git config --global pull.rebase false
            }
            "vscode" {
                Write-InstallProgress "Visual Studio Code"
                winget install --id Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements
                # Install useful VS Code extensions
                Install-VSCodeExtensions
            }
            "vsstudio" {
                Write-InstallProgress "Visual Studio 2022 Community"
                winget install --id Microsoft.VisualStudio.2022.Community --silent --accept-package-agreements --accept-source-agreements
            }
            "docker" {
                Write-InstallProgress "Docker Desktop"
                winget install --id Docker.DockerDesktop --silent --accept-package-agreements --accept-source-agreements
                Write-Host "Note: Docker Desktop requires a restart to complete installation" -ForegroundColor Yellow
            }
            "nodejs" {
                Write-InstallProgress "Node.js LTS"
                winget install --id OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements
                # Install global npm packages
                RefreshEnv
                npm install -g npm@latest
                npm install -g yarn pnpm
            }
            "python" {
                Write-InstallProgress "Python 3.12"
                winget install --id Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements
                # Install common Python packages
                RefreshEnv
                pip install --upgrade pip
                pip install virtualenv pipenv poetry
            }
            "dotnet" {
                Write-InstallProgress ".NET 8 SDK"
                winget install --id Microsoft.DotNet.SDK.8 --silent --accept-package-agreements --accept-source-agreements
            }
            "powershell" {
                Write-InstallProgress "PowerShell 7"
                winget install --id Microsoft.PowerShell --silent --accept-package-agreements --accept-source-agreements
            }
            "wsl" {
                Write-InstallProgress "Windows Subsystem for Linux"
                Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
                Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
                Write-Host "WSL installed. Install a Linux distribution from Microsoft Store." -ForegroundColor Green
            }
            "rust" {
                Write-InstallProgress "Rust Programming Language"
                winget install --id Rustlang.Rustup --silent --accept-package-agreements --accept-source-agreements
            }
            "go" {
                Write-InstallProgress "Go Programming Language"
                winget install --id GoLang.Go --silent --accept-package-agreements --accept-source-agreements
            }
            "java" {
                Write-InstallProgress "OpenJDK 21"
                winget install --id Eclipse.Temurin.21.JDK --silent --accept-package-agreements --accept-source-agreements
            }
            "androidstudio" {
                Write-InstallProgress "Android Studio"
                winget install --id Google.AndroidStudio --silent --accept-package-agreements --accept-source-agreements
            }
            "flutter" {
                Write-InstallProgress "Flutter SDK"
                winget install --id Google.Flutter --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-Browsers {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "chrome" {
                Write-InstallProgress "Google Chrome"
                winget install --id Google.Chrome --silent --accept-package-agreements --accept-source-agreements
            }
            "firefox" {
                Write-InstallProgress "Mozilla Firefox"
                winget install --id Mozilla.Firefox --silent --accept-package-agreements --accept-source-agreements
            }
            "edge" {
                Write-InstallProgress "Microsoft Edge"
                winget install --id Microsoft.Edge --silent --accept-package-agreements --accept-source-agreements
            }
            "brave" {
                Write-InstallProgress "Brave Browser"
                winget install --id BraveSoftware.BraveBrowser --silent --accept-package-agreements --accept-source-agreements
            }
            "opera" {
                Write-InstallProgress "Opera Browser"
                winget install --id Opera.Opera --silent --accept-package-agreements --accept-source-agreements
            }
            "vivaldi" {
                Write-InstallProgress "Vivaldi Browser"
                winget install --id VivaldiTechnologies.Vivaldi --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-Databases {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "mysql" {
                Write-InstallProgress "MySQL Community Server"
                winget install --id Oracle.MySQL --silent --accept-package-agreements --accept-source-agreements
            }
            "postgresql" {
                Write-InstallProgress "PostgreSQL"
                winget install --id PostgreSQL.PostgreSQL --silent --accept-package-agreements --accept-source-agreements
            }
            "mongodb" {
                Write-InstallProgress "MongoDB Community"
                winget install --id MongoDB.MongoDBCommunityServer --silent --accept-package-agreements --accept-source-agreements
            }
            "redis" {
                Write-InstallProgress "Redis"
                if (Test-PackageManager "chocolatey") {
                    choco install redis-64 -y
                } else {
                    Write-Host "Redis installation requires Chocolatey. Installing Chocolatey first..." -ForegroundColor Yellow
                    Install-PackageManager "chocolatey"
                    choco install redis-64 -y
                }
            }
            "sqlserver" {
                Write-InstallProgress "SQL Server Express"
                winget install --id Microsoft.SQLServer.2022.Express --silent --accept-package-agreements --accept-source-agreements
            }
            "sqlite" {
                Write-InstallProgress "SQLite Tools"
                winget install --id SQLite.SQLite --silent --accept-package-agreements --accept-source-agreements
            }
            "dbeaver" {
                Write-InstallProgress "DBeaver Community"
                winget install --id dbeaver.dbeaver --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-CloudTools {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "awscli" {
                Write-InstallProgress "AWS CLI v2"
                winget install --id Amazon.AWSCLI --silent --accept-package-agreements --accept-source-agreements
            }
            "azurecli" {
                Write-InstallProgress "Azure CLI"
                winget install --id Microsoft.AzureCLI --silent --accept-package-agreements --accept-source-agreements
            }
            "terraform" {
                Write-InstallProgress "Terraform"
                winget install --id HashiCorp.Terraform --silent --accept-package-agreements --accept-source-agreements
            }
            "kubectl" {
                Write-InstallProgress "Kubernetes CLI"
                winget install --id Kubernetes.kubectl --silent --accept-package-agreements --accept-source-agreements
            }
            "helm" {
                Write-InstallProgress "Helm"
                if (Test-PackageManager "chocolatey") {
                    choco install kubernetes-helm -y
                } else {
                    Install-PackageManager "chocolatey"
                    choco install kubernetes-helm -y
                }
            }
            "vagrant" {
                Write-InstallProgress "Vagrant"
                winget install --id Hashicorp.Vagrant --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-Editors {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "notepadpp" {
                Write-InstallProgress "Notepad++"
                winget install --id Notepad++.Notepad++ --silent --accept-package-agreements --accept-source-agreements
            }
            "sublimetext" {
                Write-InstallProgress "Sublime Text 4"
                winget install --id SublimeHQ.SublimeText.4 --silent --accept-package-agreements --accept-source-agreements
            }
            "atom" {
                Write-InstallProgress "Atom"
                winget install --id GitHub.Atom --silent --accept-package-agreements --accept-source-agreements
            }
            "jetbrains-toolbox" {
                Write-InstallProgress "JetBrains Toolbox"
                winget install --id JetBrains.Toolbox --silent --accept-package-agreements --accept-source-agreements
            }
            "vim" {
                Write-InstallProgress "Vim"
                winget install --id vim.vim --silent --accept-package-agreements --accept-source-agreements
            }
            "neovim" {
                Write-InstallProgress "Neovim"
                winget install --id Neovim.Neovim --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-CommunicationTools {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "teams" {
                Write-InstallProgress "Microsoft Teams"
                winget install --id Microsoft.Teams --silent --accept-package-agreements --accept-source-agreements
            }
            "slack" {
                Write-InstallProgress "Slack"
                winget install --id SlackTechnologies.Slack --silent --accept-package-agreements --accept-source-agreements
            }
            "discord" {
                Write-InstallProgress "Discord"
                winget install --id Discord.Discord --silent --accept-package-agreements --accept-source-agreements
            }
            "zoom" {
                Write-InstallProgress "Zoom"
                winget install --id Zoom.Zoom --silent --accept-package-agreements --accept-source-agreements
            }
            "skype" {
                Write-InstallProgress "Skype"
                winget install --id Microsoft.Skype --silent --accept-package-agreements --accept-source-agreements
            }
            "telegram" {
                Write-InstallProgress "Telegram Desktop"
                winget install --id Telegram.TelegramDesktop --silent --accept-package-agreements --accept-source-agreements
            }
            "whatsapp" {
                Write-InstallProgress "WhatsApp Desktop"
                winget install --id WhatsApp.WhatsApp --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-MultimediaTools {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "vlc" {
                Write-InstallProgress "VLC Media Player"
                winget install --id VideoLAN.VLC --silent --accept-package-agreements --accept-source-agreements
            }
            "obs" {
                Write-InstallProgress "OBS Studio"
                winget install --id OBSProject.OBSStudio --silent --accept-package-agreements --accept-source-agreements
            }
            "gimp" {
                Write-InstallProgress "GIMP"
                winget install --id GIMP.GIMP --silent --accept-package-agreements --accept-source-agreements
            }
            "inkscape" {
                Write-InstallProgress "Inkscape"
                winget install --id Inkscape.Inkscape --silent --accept-package-agreements --accept-source-agreements
            }
            "blender" {
                Write-InstallProgress "Blender"
                winget install --id BlenderFoundation.Blender --silent --accept-package-agreements --accept-source-agreements
            }
            "audacity" {
                Write-InstallProgress "Audacity"
                winget install --id Audacity.Audacity --silent --accept-package-agreements --accept-source-agreements
            }
            "handbrake" {
                Write-InstallProgress "HandBrake"
                winget install --id HandBrake.HandBrake --silent --accept-package-agreements --accept-source-agreements
            }
            "paint.net" {
                Write-InstallProgress "Paint.NET"
                winget install --id dotPDN.PaintDotNet --silent --accept-package-agreements --accept-source-agreements
            }
            "krita" {
                Write-InstallProgress "Krita"
                winget install --id KDE.Krita --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-SystemUtilities {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "7zip" {
                Write-InstallProgress "7-Zip"
                winget install --id 7zip.7zip --silent --accept-package-agreements --accept-source-agreements
            }
            "winrar" {
                Write-InstallProgress "WinRAR"
                winget install --id RARLab.WinRAR --silent --accept-package-agreements --accept-source-agreements
            }
            "powertoys" {
                Write-InstallProgress "Microsoft PowerToys"
                winget install --id Microsoft.PowerToys --silent --accept-package-agreements --accept-source-agreements
            }
            "sysinternals" {
                Write-InstallProgress "Sysinternals Suite"
                winget install --id Microsoft.Sysinternals.ProcessMonitor --silent --accept-package-agreements --accept-source-agreements
                winget install --id Microsoft.Sysinternals.ProcessExplorer --silent --accept-package-agreements --accept-source-agreements
            }
            "processhacker" {
                Write-InstallProgress "Process Hacker"
                winget install --id ProcessHacker.ProcessHacker --silent --accept-package-agreements --accept-source-agreements
            }
            "wiztree" {
                Write-InstallProgress "WizTree"
                winget install --id AntibodySoftware.WizTree --silent --accept-package-agreements --accept-source-agreements
            }
            "everything" {
                Write-InstallProgress "Everything"
                winget install --id voidtools.Everything --silent --accept-package-agreements --accept-source-agreements
            }
            "windirstat" {
                Write-InstallProgress "WinDirStat"
                winget install --id WinDirStat.WinDirStat --silent --accept-package-agreements --accept-source-agreements
            }
            "treesizefree" {
                Write-InstallProgress "TreeSize Free"
                winget install --id JAMSoftware.TreeSize.Free --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-TerminalTools {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "windowsterminal" {
                Write-InstallProgress "Windows Terminal"
                winget install --id Microsoft.WindowsTerminal --silent --accept-package-agreements --accept-source-agreements
            }
            "alacritty" {
                Write-InstallProgress "Alacritty"
                winget install --id Alacritty.Alacritty --silent --accept-package-agreements --accept-source-agreements
            }
            "hyper" {
                Write-InstallProgress "Hyper Terminal"
                winget install --id Hyper.Hyper --silent --accept-package-agreements --accept-source-agreements
            }
            "cmder" {
                Write-InstallProgress "Cmder"
                if (Test-PackageManager "chocolatey") {
                    choco install cmder -y
                } else {
                    Install-PackageManager "chocolatey"
                    choco install cmder -y
                }
            }
            "conemu" {
                Write-InstallProgress "ConEmu"
                winget install --id Maximus5.ConEmu --silent --accept-package-agreements --accept-source-agreements
            }
            "starship" {
                Write-InstallProgress "Starship"
                winget install --id Starship.Starship --silent --accept-package-agreements --accept-source-agreements
            }
            "oh-my-posh" {
                Write-InstallProgress "Oh My Posh"
                winget install --id JanDeDobbeleer.OhMyPosh --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-SecurityTools {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "bitdefender" {
                Write-InstallProgress "Bitdefender Antivirus Free"
                winget install --id Bitdefender.Bitdefender --silent --accept-package-agreements --accept-source-agreements
            }
            "malwarebytes" {
                Write-InstallProgress "Malwarebytes"
                winget install --id Malwarebytes.Malwarebytes --silent --accept-package-agreements --accept-source-agreements
            }
            "keepass" {
                Write-InstallProgress "KeePass"
                winget install --id DominikReichl.KeePass --silent --accept-package-agreements --accept-source-agreements
            }
            "bitwarden" {
                Write-InstallProgress "Bitwarden"
                winget install --id Bitwarden.Bitwarden --silent --accept-package-agreements --accept-source-agreements
            }
            "veracrypt" {
                Write-InstallProgress "VeraCrypt"
                winget install --id IDRIX.VeraCrypt --silent --accept-package-agreements --accept-source-agreements
            }
            "wireshark" {
                Write-InstallProgress "Wireshark"
                winget install --id WiresharkFoundation.Wireshark --silent --accept-package-agreements --accept-source-agreements
            }
            "nmap" {
                Write-InstallProgress "Nmap"
                winget install --id Insecure.Nmap --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-PackageManagers {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "chocolatey" {
                Write-InstallProgress "Chocolatey"
                Install-PackageManager "chocolatey"
            }
            "scoop" {
                Write-InstallProgress "Scoop"
                Install-PackageManager "scoop"
            }
            "vcredist" {
                Write-InstallProgress "Visual C++ Redistributables"
                winget install --id Microsoft.VCRedist.2015+.x64 --silent --accept-package-agreements --accept-source-agreements
                winget install --id Microsoft.VCRedist.2015+.x86 --silent --accept-package-agreements --accept-source-agreements
            }
            "directx" {
                Write-InstallProgress "DirectX Runtime"
                winget install --id Microsoft.DirectX --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-GamingPlatforms {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "steam" {
                Write-InstallProgress "Steam"
                winget install --id Valve.Steam --silent --accept-package-agreements --accept-source-agreements
            }
            "epicgames" {
                Write-InstallProgress "Epic Games Launcher"
                winget install --id EpicGames.EpicGamesLauncher --silent --accept-package-agreements --accept-source-agreements
            }
            "gog" {
                Write-InstallProgress "GOG Galaxy"
                winget install --id GOG.Galaxy --silent --accept-package-agreements --accept-source-agreements
            }
            "origin" {
                Write-InstallProgress "EA App"
                winget install --id ElectronicArts.EADesktop --silent --accept-package-agreements --accept-source-agreements
            }
            "uplay" {
                Write-InstallProgress "Ubisoft Connect"
                winget install --id Ubisoft.Connect --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

function Install-FileTransferTools {
    param([array]$SelectedItems)
    
    foreach ($item in $SelectedItems) {
        switch ($item) {
            "filezilla" {
                Write-InstallProgress "FileZilla"
                winget install --id TimKosse.FileZilla.Client --silent --accept-package-agreements --accept-source-agreements
            }
            "winscp" {
                Write-InstallProgress "WinSCP"
                winget install --id WinSCP.WinSCP --silent --accept-package-agreements --accept-source-agreements
            }
            "dropbox" {
                Write-InstallProgress "Dropbox"
                winget install --id Dropbox.Dropbox --silent --accept-package-agreements --accept-source-agreements
            }
            "googledrive" {
                Write-InstallProgress "Google Drive"
                winget install --id Google.GoogleDrive --silent --accept-package-agreements --accept-source-agreements
            }
            "onedrive" {
                Write-InstallProgress "OneDrive"
                winget install --id Microsoft.OneDrive --silent --accept-package-agreements --accept-source-agreements
            }
        }
    }
}

# Helper functions
function Write-InstallProgress {
    param([string]$SoftwareName)
    Write-Host "Installing $SoftwareName..." -ForegroundColor Cyan
}

function Install-VSCodeExtensions {
    Write-Host "Installing useful VS Code extensions..." -ForegroundColor Yellow
    $extensions = @(
        "ms-vscode.powershell",
        "ms-python.python",
        "ms-dotnettools.csharp",
        "bradlc.vscode-tailwindcss",
        "esbenp.prettier-vscode",
        "ms-vscode.vscode-json",
        "redhat.vscode-yaml",
        "ms-vscode-remote.remote-wsl",
        "GitHub.copilot",
        "gitpod.gitpod-desktop"
    )
    
    foreach ($ext in $extensions) {
        try {
            code --install-extension $ext --force
        } catch {
            Write-Host "Failed to install extension: $ext" -ForegroundColor Yellow
        }
    }
}

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

function Install-PackageManager {
    param([string]$PackageManager)
    
    switch ($PackageManager) {
        "chocolatey" {
            Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            RefreshEnv
        }
        "scoop" {
            Write-Host "Installing Scoop..." -ForegroundColor Yellow
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-RestMethod get.scoop.sh | Invoke-Expression
        }
    }
}

function RefreshEnv {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
