# Firefox Offline Installer Script
# This script downloads and installs Firefox silently for all users
# Author: WindowsInstallers Repository
# License: MIT

<#
.SYNOPSIS
    Installs Firefox silently for all users on Windows.

.DESCRIPTION
    This script downloads the latest Firefox installer from Mozilla's official CDN
    and installs it silently without user interaction. The installation is configured
    for all users on the system.

.PARAMETER InstallerType
    The type of installer to use: 'EXE' (default) or 'MSI'.
    MSI installers are better for enterprise environments.

.PARAMETER InstallerPath
    Optional path to a pre-downloaded Firefox installer.
    If not provided, the script will download the latest version.

.PARAMETER InstallDir
    Optional custom installation directory.
    Default: C:\Program Files\Mozilla Firefox

.EXAMPLE
    .\Install-Firefox.ps1
    Downloads and installs Firefox using the default EXE installer.

.EXAMPLE
    .\Install-Firefox.ps1 -InstallerType MSI
    Downloads and installs Firefox using the MSI installer.

.EXAMPLE
    .\Install-Firefox.ps1 -InstallerPath "C:\Downloads\Firefox.exe"
    Installs Firefox from a pre-downloaded installer.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('EXE', 'MSI')]
    [string]$InstallerType = 'EXE',
    
    [Parameter(Mandatory=$false)]
    [string]$InstallerPath = '',
    
    [Parameter(Mandatory=$false)]
    [string]$InstallDir = 'C:\Program Files\Mozilla Firefox'
)

# Ensure script runs with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "This script requires administrator privileges. Please run as Administrator."
    exit 1
}

# Configuration
$tempDir = "$env:TEMP\FirefoxInstaller"
$logFile = "$tempDir\firefox-install.log"

# Create temp directory if it doesn't exist
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

# Function to write log messages
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# Function to download Firefox installer
function Download-Firefox {
    param(
        [string]$Type,
        [string]$Destination
    )
    
    Write-Log "Downloading Firefox $Type installer..."
    
    try {
        if ($Type -eq 'EXE') {
            # Firefox stub installer URL (will download full offline installer)
            $url = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US"
            $installerFile = Join-Path $Destination "Firefox-Installer.exe"
        } else {
            # MSI installer URL
            $url = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US"
            $installerFile = Join-Path $Destination "Firefox-Installer.msi"
        }
        
        # Download with progress
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $installerFile)
        
        Write-Log "Download completed: $installerFile"
        return $installerFile
    }
    catch {
        Write-Log "ERROR: Failed to download Firefox installer: $_"
        throw
    }
}

# Function to install Firefox from EXE
function Install-FirefoxEXE {
    param([string]$InstallerPath)
    
    Write-Log "Installing Firefox from EXE installer..."
    Write-Log "Installer path: $InstallerPath"
    
    # Firefox EXE installer silent installation arguments
    # -ms: Silent installation
    # /InstallDirectoryPath: Custom install directory (optional)
    # /MaintenanceService=false: Don't install maintenance service (optional)
    
    $arguments = @(
        '-ms',
        "/InstallDirectoryPath=`"$InstallDir`""
    )
    
    try {
        $process = Start-Process -FilePath $InstallerPath -ArgumentList $arguments -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Log "Firefox installation completed successfully."
            return $true
        } else {
            Write-Log "ERROR: Firefox installation failed with exit code: $($process.ExitCode)"
            return $false
        }
    }
    catch {
        Write-Log "ERROR: Failed to execute Firefox installer: $_"
        throw
    }
}

# Function to install Firefox from MSI
function Install-FirefoxMSI {
    param([string]$InstallerPath)
    
    Write-Log "Installing Firefox from MSI installer..."
    Write-Log "Installer path: $InstallerPath"
    
    # MSI installation arguments
    # /i: Install
    # /qn: Quiet mode, no user interaction
    # /norestart: Do not restart after installation
    # ALLUSERS=1: Install for all users
    # INSTALL_MAINTENANCE_SERVICE=false: Optional, disable maintenance service
    
    $arguments = @(
        '/i',
        "`"$InstallerPath`"",
        '/qn',
        '/norestart',
        'ALLUSERS=1',
        "INSTALLDIR=`"$InstallDir`""
    )
    
    try {
        $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $arguments -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Log "Firefox installation completed successfully."
            return $true
        } else {
            Write-Log "ERROR: Firefox installation failed with exit code: $($process.ExitCode)"
            return $false
        }
    }
    catch {
        Write-Log "ERROR: Failed to execute MSI installer: $_"
        throw
    }
}

# Main installation logic
try {
    Write-Log "========================================="
    Write-Log "Firefox Silent Installer"
    Write-Log "========================================="
    Write-Log "Installer Type: $InstallerType"
    Write-Log "Install Directory: $InstallDir"
    
    # Determine installer path
    if ([string]::IsNullOrEmpty($InstallerPath)) {
        Write-Log "No pre-downloaded installer provided. Downloading..."
        $InstallerPath = Download-Firefox -Type $InstallerType -Destination $tempDir
    } else {
        Write-Log "Using pre-downloaded installer: $InstallerPath"
        if (-not (Test-Path $InstallerPath)) {
            throw "Installer file not found: $InstallerPath"
        }
    }
    
    # Verify installer file exists
    if (-not (Test-Path $InstallerPath)) {
        throw "Installer file not found after download: $InstallerPath"
    }
    
    Write-Log "Installer file size: $((Get-Item $InstallerPath).Length / 1MB) MB"
    
    # Install Firefox based on type
    $installSuccess = $false
    if ($InstallerType -eq 'EXE') {
        $installSuccess = Install-FirefoxEXE -InstallerPath $InstallerPath
    } else {
        $installSuccess = Install-FirefoxMSI -InstallerPath $InstallerPath
    }
    
    if ($installSuccess) {
        Write-Log "========================================="
        Write-Log "Firefox installation completed successfully!"
        Write-Log "========================================="
        Write-Log "Installation log: $logFile"
        
        # Verify installation
        $firefoxExe = Join-Path $InstallDir "firefox.exe"
        if (Test-Path $firefoxExe) {
            Write-Log "Firefox executable found at: $firefoxExe"
        } else {
            Write-Log "WARNING: Firefox executable not found at expected location."
        }
        
        exit 0
    } else {
        throw "Installation failed. Check log file for details: $logFile"
    }
}
catch {
    Write-Log "========================================="
    Write-Log "ERROR: Installation failed!"
    Write-Log "Error details: $_"
    Write-Log "========================================="
    Write-Log "Log file: $logFile"
    exit 1
}
finally {
    # Cleanup: Optionally remove the downloaded installer
    # Uncomment the following lines if you want to clean up after installation
    # if (Test-Path $InstallerPath) {
    #     Write-Log "Cleaning up installer file..."
    #     Remove-Item -Path $InstallerPath -Force -ErrorAction SilentlyContinue
    # }
}
