# PowerShell Template Packaging Script
# Creates distributable packages for the Alibre Script Addon Template

param(
    [string]$OutputPath = ".\Output",
    [switch]$Verbose = $false
)

Write-Host "=== Alibre Script Addon Template Packager ===" -ForegroundColor Green
Write-Host

# Create output directory
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
    Write-Host "Created output directory: $OutputPath" -ForegroundColor Yellow
}

# Verify template structure first
Write-Host "Verifying template structure..." -ForegroundColor Cyan

$requiredFiles = @(
    "ProjectTemplate\AlibreAddonTemplate.vstemplate",
    "ProjectTemplate\AlibreAddOn.cs",
    "ProjectTemplate\ProjectTemplate.csproj",
    "ProjectTemplate\ProjectTemplate.adc",
    "ProjectTemplate\ProjectTemplate.sln",
    "ProjectTemplate\Scripts\src\`$safeprojectname`$\alibre_setup.py",
    "ProjectTemplate\Scripts\src\`$safeprojectname`$\Template.py"
)

$missing = @()
foreach ($file in $requiredFiles) {
    if (!(Test-Path $file)) {
        $missing += $file
    }
}

if ($missing.Count -gt 0) {
    Write-Host "❌ ERROR: Missing required files:" -ForegroundColor Red
    foreach ($file in $missing) {
        Write-Host "  - $file" -ForegroundColor Red
    }
    exit 1
}

Write-Host "✅ Template structure verified" -ForegroundColor Green

# Create ZIP package for manual installation
$zipPath = Join-Path $OutputPath "AlibreScriptAddon.zip"
Write-Host "Creating ZIP package: $zipPath" -ForegroundColor Yellow

try {
    # Remove existing ZIP if it exists
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
    
    # Create the ZIP package
    Compress-Archive -Path "ProjectTemplate\*" -DestinationPath $zipPath -Force
    
    Write-Host "✅ ZIP package created successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ ERROR creating ZIP package: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify the ZIP package
Write-Host "Verifying ZIP package contents..." -ForegroundColor Cyan

try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    
    $expectedEntries = @(
        "AlibreAddonTemplate.vstemplate",
        "AlibreAddOn.cs",
        "ProjectTemplate.csproj",
        "ProjectTemplate.adc"
    )
    
    $zipEntries = $zip.Entries | ForEach-Object { $_.FullName }
    
    foreach ($entry in $expectedEntries) {
        if ($zipEntries -contains $entry) {
            if ($Verbose) { Write-Host "  ✅ $entry" -ForegroundColor Gray }
        } else {
            Write-Host "  ❌ Missing: $entry" -ForegroundColor Red
        }
    }
    
    $zip.Dispose()
    Write-Host "✅ ZIP package verification complete" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not verify ZIP contents: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Create installation instructions
$instructionsPath = Join-Path $OutputPath "INSTALLATION_INSTRUCTIONS.txt"
$instructions = @"
Alibre Script Addon Template - Installation Instructions
======================================================

Manual Installation:
1. Extract or copy 'AlibreScriptAddon.zip' to:
   %USERPROFILE%\Documents\Visual Studio 2022\Templates\ProjectTemplates\Visual C#\

   For other Visual Studio versions, use the appropriate year folder.

2. Restart Visual Studio

3. Create a new project and search for "Alibre" or browse to Visual C# templates

4. Select "Alibre Design Script Addon" template

Alternative Installation (Extract ZIP):
1. Extract the ZIP file contents to your Visual Studio templates folder
2. Follow steps 2-4 above

Template Location Examples:
- VS 2022: %USERPROFILE%\Documents\Visual Studio 2022\Templates\ProjectTemplates\Visual C#\
- VS 2019: %USERPROFILE%\Documents\Visual Studio 2019\Templates\ProjectTemplates\Visual C#\

Troubleshooting:
- If template doesn't appear, restart Visual Studio
- Check that the .vstemplate file is in the correct location
- Clear Visual Studio template cache if needed

For more information, see:
- TEMPLATE_INSTALLATION.md
- USAGE_GUIDE.md
- README.md

Generated: $(Get-Date)
"@

Set-Content -Path $instructionsPath -Value $instructions -Encoding UTF8
Write-Host "✅ Installation instructions created: $instructionsPath" -ForegroundColor Green

# Create package summary
Write-Host
Write-Host "=== Package Summary ===" -ForegroundColor Green
Write-Host "Package location: $zipPath" -ForegroundColor White
Write-Host "Package size: $([math]::Round((Get-Item $zipPath).Length / 1KB, 2)) KB" -ForegroundColor White
Write-Host "Installation guide: $instructionsPath" -ForegroundColor White
Write-Host

Write-Host "📦 Template packaging complete!" -ForegroundColor Green
Write-Host
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Test the template by installing it in Visual Studio" -ForegroundColor White
Write-Host "2. Create a test project from the template" -ForegroundColor White
Write-Host "3. Verify the generated project builds successfully" -ForegroundColor White
Write-Host "4. Distribute the ZIP file to users" -ForegroundColor White
Write-Host

Write-Host "Installation command for users:" -ForegroundColor Yellow
Write-Host "Copy '$zipPath' to %USERPROFILE%\Documents\Visual Studio 2022\Templates\ProjectTemplates\Visual C#\" -ForegroundColor White