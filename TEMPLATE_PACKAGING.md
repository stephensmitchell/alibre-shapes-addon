# Template Package Builder

This script helps package the Visual Studio template for distribution.

## Manual Packaging

### For Individual Installation

1. **Create a ZIP file** from the ProjectTemplate directory:
   ```
   ProjectTemplate.zip
   ├── AlibreAddOn.cs
   ├── AlibreAddonTemplate.vstemplate
   ├── ProjectTemplate.adc
   ├── ProjectTemplate.csproj
   ├── ProjectTemplate.sln
   ├── README.md
   ├── TemplateParameters.md
   ├── __TemplateIcon.ico
   └── Scripts/
       └── src/
           └── $safeprojectname$/
               ├── alibre_setup.py
               └── Template.py
   ```

2. **Copy the ZIP file** to Visual Studio templates directory:
   - `%USERPROFILE%\Documents\Visual Studio 2022\Templates\ProjectTemplates\Visual C#\`

### For VSIX Distribution

To create a distributable VSIX extension:

1. **Create a new VSIX project** in Visual Studio
2. **Add the template files** to the VSIX project
3. **Configure the extension manifest** (source.extension.vsixmanifest):

```xml
<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011" xmlns:d="http://schemas.microsoft.com/developer/vsx-schema-design/2011">
  <Metadata>
    <Identity Id="AlibreScriptAddon.Template" Version="1.0" Language="en-US" Publisher="YourName" />
    <DisplayName>Alibre Design Script Addon Template</DisplayName>
    <Description>Visual Studio project template for creating Alibre Design Script-based addons</Description>
    <MoreInfo>https://github.com/stephensmitchell/alibre-shapes-addon</MoreInfo>
    <License>LICENSE</License>
    <Tags>Alibre;CAD;Addon;Python;Script</Tags>
  </Metadata>
  <Installation>
    <InstallationTarget Id="Microsoft.VisualStudio.Community" Version="[16.0,18.0)" />
    <InstallationTarget Id="Microsoft.VisualStudio.Pro" Version="[16.0,18.0)" />
    <InstallationTarget Id="Microsoft.VisualStudio.Enterprise" Version="[16.0,18.0)" />
  </Installation>
  <Dependencies>
    <Dependency Id="Microsoft.Framework.NDP" DisplayName="Microsoft .NET Framework" d:Source="Manual" Version="[4.8.1,)" />
  </Dependencies>
  <Prerequisites>
    <Prerequisite Id="Microsoft.VisualStudio.Component.CoreEditor" Version="[16.0,18.0)" DisplayName="Visual Studio core editor" />
  </Prerequisites>
  <Assets>
    <Asset Type="ProjectTemplate" d:Source="File" Path="ProjectTemplates" d:TargetPath="ProjectTemplates\AlibreScriptAddon.zip" />
  </Assets>
</PackageManifest>
```

## PowerShell Package Script

Create `PackageTemplate.ps1`:

```powershell
# PowerShell script to package the template
param(
    [string]$OutputPath = ".\Output",
    [switch]$CreateVSIX = $false
)

Write-Host "Packaging Alibre Script Addon Template..." -ForegroundColor Green

# Create output directory
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# Create ZIP package for manual installation
$zipPath = Join-Path $OutputPath "AlibreScriptAddon.zip"
Write-Host "Creating ZIP package: $zipPath" -ForegroundColor Yellow

# Compress the ProjectTemplate directory
Compress-Archive -Path "ProjectTemplate\*" -DestinationPath $zipPath -Force

Write-Host "Template package created successfully!" -ForegroundColor Green
Write-Host "Install by copying to: %USERPROFILE%\Documents\Visual Studio 2022\Templates\ProjectTemplates\Visual C#\" -ForegroundColor Cyan

if ($CreateVSIX) {
    Write-Host "VSIX creation requires Visual Studio SDK and manual setup." -ForegroundColor Yellow
    Write-Host "See TEMPLATE_PACKAGING.md for detailed instructions." -ForegroundColor Yellow
}
```

## Batch Script Alternative

Create `PackageTemplate.bat`:

```batch
@echo off
echo Packaging Alibre Script Addon Template...

if not exist "Output" mkdir Output

echo Creating ZIP package...
powershell -Command "Compress-Archive -Path 'ProjectTemplate\*' -DestinationPath 'Output\AlibreScriptAddon.zip' -Force"

echo.
echo Template package created successfully!
echo Install by copying Output\AlibreScriptAddon.zip to:
echo %USERPROFILE%\Documents\Visual Studio 2022\Templates\ProjectTemplates\Visual C#\
echo.
pause
```

## Verification Steps

After packaging:

1. **Test the ZIP package**:
   - Copy to Visual Studio templates directory
   - Restart Visual Studio
   - Create new project and verify template appears

2. **Test template functionality**:
   - Create project from template
   - Verify all files are generated correctly
   - Check parameter substitution worked
   - Attempt to build the project

3. **Validate template structure**:
   - All required files present
   - Folder structure correct
   - No broken references

## Distribution Checklist

- [ ] Template files properly parameterized
- [ ] .vstemplate file configured correctly
- [ ] All dependencies included
- [ ] Documentation updated
- [ ] Package tested in clean environment
- [ ] Installation instructions verified
- [ ] Example project builds successfully

## Troubleshooting Package Issues

### Template not appearing in Visual Studio
- Check ZIP file structure (files should be at root level)
- Verify .vstemplate file is valid XML
- Clear Visual Studio template cache
- Restart Visual Studio

### Parameter substitution not working
- Check parameter names match exactly
- Verify case sensitivity
- Ensure parameters are surrounded by dollar signs

### Build errors in generated project
- Verify all referenced assemblies are available
- Check target framework compatibility
- Ensure all template files are included in package