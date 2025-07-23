# Installing the Alibre Script Addon Template

This guide explains how to install and use the Alibre Design Script Addon template in Visual Studio.

## Installation Methods

### Method 1: Manual Installation (Recommended)

1. **Locate the Visual Studio Templates folder:**
   - For Visual Studio 2022: `%USERPROFILE%\Documents\Visual Studio 2022\Templates\ProjectTemplates\Visual C#`
   - For Visual Studio 2019: `%USERPROFILE%\Documents\Visual Studio 2019\Templates\ProjectTemplates\Visual C#`

2. **Copy the template:**
   - Copy the entire `ProjectTemplate` folder to the Templates directory
   - Rename it to `AlibreScriptAddon` (optional, for clarity)

3. **Create template ZIP (alternative):**
   - Zip the contents of the `ProjectTemplate` folder
   - Name the ZIP file `AlibreScriptAddon.zip`
   - Place it in the Templates directory

### Method 2: VSIX Extension (Advanced)

For distribution as a Visual Studio extension:

1. Create a VSIX project
2. Include the template files in the VSIX
3. Configure the extension manifest
4. Build and install the VSIX

## Using the Template

1. **Start Visual Studio**
2. **Create New Project**
3. **Search for "Alibre"** or browse to Visual C# templates
4. **Select "Alibre Design Script Addon"**
5. **Configure project settings:**
   - Project name (will be used for addon name)
   - Location
   - Solution name
6. **Click Create**

## Verification

After creating a project from the template:

1. **Check project structure:**
   ```
   YourAddon/
   ├── YourAddon.cs
   ├── YourAddon.adc
   ├── YourAddon.csproj
   └── Scripts/
       └── src/
           └── YourAddon/
               ├── alibre_setup.py
               └── Template.py
   ```

2. **Build the project** (may require Alibre Design references)
3. **Verify parameterization** - all `$safeprojectname$` should be replaced with your actual project name

## Troubleshooting

### Template not appearing
- Check the template location is correct
- Restart Visual Studio
- Clear Visual Studio template cache: `%LOCALAPPDATA%\Microsoft\VisualStudio\`

### Build errors
- Ensure Alibre Design is installed
- Verify AlibreAddOn.dll and AlibreX.dll references
- Check .NET Framework 4.8.1 is installed

### Script execution issues
- Verify Python scripts are copied to output directory
- Check Alibre Design version compatibility
- Ensure scripts folder structure is preserved

## Customization

You can customize the template by:

1. **Modifying template files** before installation
2. **Adding custom parameters** to the .vstemplate file
3. **Creating custom wizards** for advanced parameter collection
4. **Including additional files** or project items

## Template Updates

To update the template:

1. Replace the template files in the Templates directory
2. Restart Visual Studio
3. Template cache may need to be cleared