@echo off
echo Building Alibre Shapes Addon Installer with Inno Setup...
echo.

REM Check if Inno Setup is installed
if not exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" (
    if not exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" (
        echo ERROR: Inno Setup 6 not found!
        echo Please download and install Inno Setup from: https://jrsoftware.org/isinfo.php
        pause
        exit /b 1
    )
    set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
) else (
    set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
)

REM Create installer directory if it doesn't exist
if not exist "installer" mkdir installer

REM Build the project first (optional - comment out if not needed)
echo Building .NET project...
dotnet build src\alibre-shapes-addon.csproj -c Debug -f net481
if errorlevel 1 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo Compiling Inno Setup script...
"%ISCC%" "alibre-shapes-addon.iss"

if errorlevel 1 (
    echo ERROR: Inno Setup compilation failed!
    pause
    exit /b 1
)

echo.
echo SUCCESS: Installer created successfully!
echo Output: installer\alibre-shapes-addon-setup-v2.0.exe
echo.
pause
