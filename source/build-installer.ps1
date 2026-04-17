# Build Alibre Shapes Addon Installer with Inno Setup
# PowerShell script to compile the Inno Setup installer

Write-Host "Building Alibre Shapes Addon Installer with Inno Setup..." -ForegroundColor Green
Write-Host ""

# Check if Inno Setup is installed
$isccPath = ""
$possiblePaths = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $isccPath = $path
        break
    }
}

if (-not $isccPath) {
    Write-Host "ERROR: Inno Setup 6 not found!" -ForegroundColor Red
    Write-Host "Please download and install Inno Setup from: https://jrsoftware.org/isinfo.php" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Found Inno Setup at: $isccPath" -ForegroundColor Cyan

# Create installer directory if it doesn't exist
if (-not (Test-Path "installer")) {
    New-Item -ItemType Directory -Path "installer" | Out-Null
    Write-Host "Created installer directory" -ForegroundColor Cyan
}

# Build the project first (optional)
Write-Host "Building .NET project..." -ForegroundColor Yellow
try {
    $buildResult = & dotnet build "src\alibre-shapes-addon.csproj" -c Debug -f net481
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed with exit code $LASTEXITCODE"
    }
    Write-Host "Build completed successfully" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Compiling Inno Setup script..." -ForegroundColor Yellow

try {
    & $isccPath "alibre-shapes-addon.iss"
    if ($LASTEXITCODE -ne 0) {
        throw "Inno Setup compilation failed with exit code $LASTEXITCODE"
    }
    
    Write-Host ""
    Write-Host "SUCCESS: Installer created successfully!" -ForegroundColor Green
    Write-Host "Output: installer\alibre-shapes-addon-setup-v2.0.exe" -ForegroundColor Cyan
    
    # Check if the installer was actually created
    if (Test-Path "installer\alibre-shapes-addon-setup-v2.0.exe") {
        $fileInfo = Get-Item "installer\alibre-shapes-addon-setup-v2.0.exe"
        Write-Host "Installer size: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" -ForegroundColor Cyan
        Write-Host "Created: $($fileInfo.CreationTime)" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "ERROR: Inno Setup compilation failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Read-Host "Press Enter to exit"
