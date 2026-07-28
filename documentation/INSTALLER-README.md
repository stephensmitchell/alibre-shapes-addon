# Installer Setup Guide

This project now includes both **Advanced Installer** and **Inno Setup** installer configurations for maximum flexibility and distribution options.

## Overview

- **Advanced Installer** (`alibre-shapes-addon.aip`) - Professional MSI-based installer
- **Inno Setup** (`alibre-shapes-addon.iss`) - Free, lightweight EXE-based installer

## Prerequisites

### For Advanced Installer
- Advanced Installer (Professional or higher)
- Visual Studio or MSBuild

### For Inno Setup
- [Inno Setup 6](https://jrsoftware.org/isinfo.php) (free download)
- .NET Framework 4.8.1 SDK or higher

## Building the Project

First, ensure your .NET project is built:

```bash
dotnet build src\alibre-shapes-addon.csproj -c Debug -f net481
```

## Using Inno Setup (Recommended for Open Source Distribution)

### Quick Build
Run the provided PowerShell script:
```powershell
.\build-installer.ps1
```

Or use the batch file:
```cmd
build-installer.bat
```

### Manual Build
1. Open `alibre-shapes-addon.iss` in Inno Setup Compiler
2. Press `F9` or click **Build** → **Compile**
3. The installer will be created in the `installer/` directory

### Output
- File: `installer/alibre-shapes-addon-setup-v2.0.exe`
- Size: Approximately 5-15 MB (depending on included libraries)
- Type: Self-extracting executable installer

## Using Advanced Installer

1. Open `alibre-shapes-addon.aip` in Advanced Installer
2. Update file paths if necessary (they may need to be relative to your build output)
3. Build the project to generate an MSI installer

## Installer Features

### Inno Setup Installer Features
- ✅ Automatic .NET Framework 4.8.1 requirement check
- ✅ Registry registration for Alibre Design addon discovery
- ✅ Proper uninstall support
- ✅ x64 architecture validation
- ✅ Modern wizard interface
- ✅ Compression with LZMA
- ✅ Digital signature support (when certificates are available)

### Advanced Installer Features
- ✅ MSI-based installation (enterprise-friendly)
- ✅ Windows Installer compliance
- ✅ Advanced deployment options
- ✅ Group Policy deployment support

## Installation Paths

Both installers will install the addon to:
```
%ProgramFiles%\Alibre Design\Addons\Alibre Shapes Addon\
```

## Registry Entries

The installers register the addon with Alibre Design using these registry entries:
```
HKLM\SOFTWARE\Alibre, LLC\Alibre Design\Addons\Alibre Shapes Addon\
  - Path: [InstallDir]\alibre-shapes-addon.adc
  - Description: Alibre Script-based addon for shape operations
  - Version: 2.0
```

## Customization

### Updating Version Numbers
1. **Inno Setup**: Edit the `#define MyAppVersion` line in `alibre-shapes-addon.iss`
2. **Advanced Installer**: Update the ProductVersion property in the .aip file
3. **Configuration**: Update version in `installer-config.json`

### Adding/Removing Files
1. **Inno Setup**: Modify the `[Files]` section in `alibre-shapes-addon.iss`
2. **Advanced Installer**: Use the Advanced Installer GUI to add/remove files

### Changing Installation Directory
1. **Inno Setup**: Modify the `DefaultDirName` in the `[Setup]` section
2. **Advanced Installer**: Change the APPDIR directory in the project

## Distribution

### Inno Setup
- Distribute the single `.exe` file from the `installer/` directory
- Can be uploaded to GitHub releases, websites, etc.
- Users run the executable

### Advanced Installer
- Distribute the `.msi` file
- Can be deployed via Group Policy in enterprise environments
- Supports administrative installations

## Troubleshooting

### Common Issues

1. **"Inno Setup not found"**
   - Download and install from https://jrsoftware.org/isinfo.php
   - Ensure it's installed in the default location

2. **".NET Framework error"**
   - The target machine needs .NET Framework 4.8.1 or higher
   - The installer will check this automatically

3. **"Build failed"**
   - Ensure the .NET project builds successfully first
   - Check that all file paths in the installer script are correct

4. **"Access denied during installation"**
   - Run the installer as Administrator
   - This is required for registry writes and Program Files access

### File Paths
If you move the project or change the build output directory, update these files:
- `alibre-shapes-addon.iss` - Update all Source paths in the `[Files]` section
- `build-installer.ps1` - Update the project path if needed

## Testing

1. Build and install using the Inno Setup installer
2. Launch Alibre Design
3. Check that the addon appears in the Addons menu
4. Test the addon functionality
5. Uninstall to verify clean removal

## Advanced Configuration

The `installer-config.json` file contains centralized configuration that can be used to generate installer scripts dynamically. This is useful for:
- CI/CD pipelines
- Multiple product variants
- Automated version updates

## Support

For issues with the installers:
1. Check the build output and error messages
2. Verify all prerequisites are installed
3. Submit issues to the GitHub repository with detailed error information
