@echo off
setlocal enabledelayedexpansion

REM ==============================================================================
REM Windows Developer Setup Script - PowerShell Entry Point
REM Provides modern interactive software selection interface for Windows
REM ==============================================================================

echo.
echo =============================================================================
echo                    Windows Developer Setup Script v3.0
echo =============================================================================
echo.
echo This script provides an interactive interface for installing development
echo tools and software on Windows using modern package managers.
echo.
echo Features:
echo   - Interactive checkbox-style software selection
echo   - Support for winget, Chocolatey, and Scoop package managers
echo   - Latest development tools and technologies
echo   - Comprehensive software catalog with 80+ applications
echo   - Category-based filtering and bulk operations
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script requires administrator privileges.
    echo Please right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

REM Check PowerShell version
powershell -Command "if ($PSVersionTable.PSVersion.Major -lt 5) { exit 1 }"
if %errorLevel% neq 0 (
    echo [ERROR] PowerShell 5.1 or later is required.
    echo Please update PowerShell from https://github.com/PowerShell/PowerShell
    echo.
    pause
    exit /b 1
)

REM Check Windows version
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%VERSION%" LSS "10.0" (
    echo [WARNING] Windows 10 or later is recommended for best compatibility.
    echo Some features may not work on older versions.
    echo.
    pause
)

echo [INFO] Launching PowerShell interactive interface...
echo.

REM Launch the PowerShell interactive script
powershell -ExecutionPolicy Bypass -File "%~dp0interactive.ps1"

echo.
echo Setup completed. Check the log files for detailed information.
pause
