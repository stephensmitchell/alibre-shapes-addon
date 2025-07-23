@echo off
REM Batch script to package the Alibre Script Addon Template
REM Creates a ZIP file for distribution

echo === Alibre Script Addon Template Packager ===
echo.

REM Create output directory
if not exist "Output" (
    mkdir Output
    echo Created output directory: Output
)

REM Check if PowerShell is available for compression
powershell -Command "Get-Command Compress-Archive" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell with Compress-Archive not available
    echo Please use PowerShell 5.0 or later, or install 7-Zip
    echo.
    pause
    exit /b 1
)

REM Verify template files exist
echo Verifying template structure...

if not exist "ProjectTemplate\AlibreAddonTemplate.vstemplate" (
    echo ERROR: Missing AlibreAddonTemplate.vstemplate
    goto :error
)

if not exist "ProjectTemplate\AlibreAddOn.cs" (
    echo ERROR: Missing AlibreAddOn.cs
    goto :error
)

if not exist "ProjectTemplate\ProjectTemplate.csproj" (
    echo ERROR: Missing ProjectTemplate.csproj
    goto :error
)

echo Template structure verified

REM Create ZIP package
echo Creating ZIP package...

powershell -Command "Compress-Archive -Path 'ProjectTemplate\*' -DestinationPath 'Output\AlibreScriptAddon.zip' -Force"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create ZIP package
    goto :error
)

echo ZIP package created successfully!

REM Create installation instructions
echo Creating installation instructions...

(
echo Alibre Script Addon Template - Installation Instructions
echo ======================================================
echo.
echo Manual Installation:
echo 1. Copy 'AlibreScriptAddon.zip' to:
echo    %%USERPROFILE%%\Documents\Visual Studio 2022\Templates\ProjectTemplates\Visual C#\
echo.
echo    For other Visual Studio versions, use the appropriate year folder.
echo.
echo 2. Restart Visual Studio
echo.
echo 3. Create a new project and search for "Alibre" or browse to Visual C# templates
echo.
echo 4. Select "Alibre Design Script Addon" template
echo.
echo Alternative Installation ^(Extract ZIP^):
echo 1. Extract the ZIP file contents to your Visual Studio templates folder
echo 2. Follow steps 2-4 above
echo.
echo Template Location Examples:
echo - VS 2022: %%USERPROFILE%%\Documents\Visual Studio 2022\Templates\ProjectTemplates\Visual C#\
echo - VS 2019: %%USERPROFILE%%\Documents\Visual Studio 2019\Templates\ProjectTemplates\Visual C#\
echo.
echo Troubleshooting:
echo - If template doesn't appear, restart Visual Studio
echo - Check that the .vstemplate file is in the correct location
echo - Clear Visual Studio template cache if needed
echo.
echo For more information, see:
echo - TEMPLATE_INSTALLATION.md
echo - USAGE_GUIDE.md
echo - README.md
echo.
echo Generated: %DATE% %TIME%
) > "Output\INSTALLATION_INSTRUCTIONS.txt"

echo Installation instructions created

REM Display summary
echo.
echo === Package Summary ===
dir "Output\AlibreScriptAddon.zip" | find "AlibreScriptAddon.zip"
echo Installation guide: Output\INSTALLATION_INSTRUCTIONS.txt
echo.

echo Template packaging complete!
echo.
echo Next steps:
echo 1. Test the template by installing it in Visual Studio
echo 2. Create a test project from the template
echo 3. Verify the generated project builds successfully
echo 4. Distribute the ZIP file to users
echo.
echo Installation command for users:
echo Copy 'Output\AlibreScriptAddon.zip' to %%USERPROFILE%%\Documents\Visual Studio 2022\Templates\ProjectTemplates\Visual C#\
echo.
pause
goto :end

:error
echo.
echo Packaging failed!
echo Please check that all template files are present and try again.
echo.
pause
exit /b 1

:end