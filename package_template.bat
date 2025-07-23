@echo off
REM Script to package the Alibre Design Addon Template for distribution
REM Run this from the root of the template repository

echo Packaging Alibre Design Addon Template...

REM Create a temporary directory for the template
if exist "template_package" rmdir /s /q "template_package"
mkdir "template_package"

REM Copy template files
xcopy "src" "template_package\src\" /s /e /y
copy "AlibreAddon.vstemplate" "template_package\"
copy "TemplateWizardData.xml" "template_package\"
copy "README.md" "template_package\"
copy "TEMPLATE_USAGE.md" "template_package\"
copy "LICENSE" "template_package\" 2>nul

REM Create zip file for Visual Studio template installation
if exist "AlibreAddonTemplate.zip" del "AlibreAddonTemplate.zip"
powershell -command "Compress-Archive -Path 'template_package\*' -DestinationPath 'AlibreAddonTemplate.zip'"

REM Clean up
rmdir /s /q "template_package"

echo Template packaged as AlibreAddonTemplate.zip
echo.
echo To install the template:
echo 1. Copy AlibreAddonTemplate.zip to your Visual Studio project templates folder
echo    (typically: Documents\Visual Studio [Version]\Templates\ProjectTemplates\)
echo 2. Or use Visual Studio's "Import Template" wizard
echo.
pause