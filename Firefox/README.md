# Firefox Offline Installer

This folder contains a PowerShell script for installing Firefox silently and offline on Windows systems.

## Features

- **Silent Installation**: No user interaction required
- **All Users Installation**: Installs Firefox for all users on the system
- **Flexible Installer Types**: Supports both EXE and MSI installers
- **Automatic Download**: Can download the latest Firefox installer from Mozilla
- **Offline Installation**: Can use pre-downloaded installer files
- **Detailed Logging**: Creates installation logs for troubleshooting
- **Administrator Check**: Ensures script runs with proper privileges

## Requirements

- Windows 10 or later (64-bit)
- PowerShell 5.1 or later
- Administrator privileges
- Internet connection (only if downloading the installer)

## Usage

### Basic Installation (EXE Installer)

```powershell
# Run PowerShell as Administrator
.\Install-Firefox.ps1
```

This will:
1. Download the latest Firefox EXE installer
2. Install Firefox silently to `C:\Program Files\Mozilla Firefox`
3. Configure Firefox for all users

### Installation with MSI Installer

```powershell
# MSI installers are recommended for enterprise environments
.\Install-Firefox.ps1 -InstallerType MSI
```

### Offline Installation (Pre-downloaded Installer)

```powershell
# If you already have the Firefox installer downloaded
.\Install-Firefox.ps1 -InstallerPath "C:\Downloads\Firefox-Installer.exe"
```

### Custom Installation Directory

```powershell
# Install to a custom location
.\Install-Firefox.ps1 -InstallDir "D:\Programs\Mozilla Firefox"
```

### Combined Options

```powershell
# Use MSI installer with custom directory
.\Install-Firefox.ps1 -InstallerType MSI -InstallDir "D:\Programs\Firefox"
```

## Installation Methods

### EXE Installer (Default)

- **Pros**: 
  - Simpler to use
  - Official Mozilla distribution method
  - Smaller initial download size
- **Cons**: 
  - Less control over installation options

**Silent Installation Arguments**:
- `-ms`: Silent installation mode
- `/InstallDirectoryPath`: Custom installation directory

### MSI Installer

- **Pros**: 
  - Better for enterprise environments
  - More control with Group Policy
  - Standard Windows installation method
  - Better for deployment tools (SCCM, Intune)
- **Cons**: 
  - Slightly larger file size
  - May not always be up-to-date with latest version

**MSI Installation Arguments**:
- `/qn`: Quiet, no user interface
- `ALLUSERS=1`: Install for all users
- `INSTALLDIR`: Custom installation directory

## Downloading Firefox Installers Manually

### EXE Installer
- **URL**: https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US
- **File Name**: Firefox Installer.exe
- **Size**: ~1-2 MB (stub installer that downloads full package)

### MSI Installer
- **URL**: https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US
- **File Name**: Firefox Setup.msi
- **Size**: ~50-60 MB (full installer)

### For specific versions or languages:
Visit the official Mozilla FTP server: https://ftp.mozilla.org/pub/firefox/releases/

## Log Files

Installation logs are saved to:
```
%TEMP%\FirefoxInstaller\firefox-install.log
```

Check this log file if you encounter any issues during installation.

## Troubleshooting

### "Script requires administrator privileges"
- Right-click PowerShell and select "Run as Administrator"
- Or run: `Start-Process powershell -Verb RunAs`

### "Execution policy error"
If you get an execution policy error, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Download fails
- Check your internet connection
- Check if your firewall/proxy blocks downloads from mozilla.org
- Try downloading manually and use the `-InstallerPath` parameter

### Installation fails
- Check the log file at `%TEMP%\FirefoxInstaller\firefox-install.log`
- Ensure no other Firefox installation is running
- Close Firefox if it's currently running
- Try running the script again

## Unattended Deployment

For IT administrators deploying to multiple machines:

1. **Using Group Policy**:
   - Place the MSI installer on a network share
   - Use the script with `-InstallerPath` pointing to the network location
   - Deploy via GPO startup/shutdown scripts

2. **Using Configuration Management Tools**:
   - SCCM: Use the MSI installer with this script
   - Intune: Package the script with the installer
   - PDQ Deploy: Use the script as a deployment package

3. **Batch Deployment**:
   ```powershell
   # On each target machine
   Invoke-Command -ComputerName PC1,PC2,PC3 -FilePath .\Install-Firefox.ps1
   ```

## Security Notes

- Always download installers from official Mozilla sources
- Verify the script hasn't been tampered with
- Review the script before running in production
- The script requires admin privileges for system-wide installation

## License

This script is provided as-is for use in the WindowsInstallers repository.

## Contributing

If you find issues or have improvements, please submit a pull request or open an issue in the repository.

## Additional Resources

- [Firefox Enterprise Downloads](https://www.mozilla.org/en-US/firefox/enterprise/)
- [Firefox ESR (Extended Support Release)](https://www.mozilla.org/en-US/firefox/enterprise/#download)
- [Mozilla Support](https://support.mozilla.org/)
- [Firefox Release Notes](https://www.mozilla.org/en-US/firefox/releases/)
