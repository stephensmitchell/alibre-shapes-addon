# Alibre Design Addon Template Usage Guide

This guide explains how to use this template to create your own Alibre Design addons.

## Template Parameters

When creating a new project from this template, you'll be prompted to provide values for these parameters:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `$safeprojectname$` | Safe project name (no spaces/special chars) | `MyAlibreAddon` |
| `$projectname$` | Project name | `my-alibre-addon` |
| `$username$` | Your name or organization | `John Doe` |
| `$projecturl$` | Project repository URL | `https://github.com/johndoe/my-alibre-addon` |
| `$projectdescription$` | Brief addon description | `Custom shapes generator for Alibre Design` |
| `$scriptdescription$` | Main script description | `Creates parametric mechanical parts` |
| `$date$` | Current date | `2025-01-20` |
| `$year$` | Current year | `2025` |

## Customization Steps

### 1. Replace Template Code

After creating your project, customize these areas:

#### C# Code (`AlibreAddOn.cs`)
- Update the `BuildMenus()` method to add your specific menu items
- Modify the `AboutCmd()` method with your addon information
- Add any additional C# functionality your addon requires

#### Python Scripts (`Scripts/src/examples/`)
- Replace `Template.py` with your main script logic
- Add additional Python files as needed
- Update `alibre_setup.py` if you need different initialization

### 2. Update Project Configuration

#### Project File (`.csproj`)
- Add references to any additional libraries you need
- Update the target framework if required
- Add any additional content files

#### Addon Configuration (`.adc`)
- All template parameters should be automatically replaced
- Verify the configuration matches your addon requirements

### 3. Add Your Functionality

#### Menu Structure
The template automatically discovers Python scripts in the `Scripts/src/examples/` folder and creates menu items for them. To customize:

1. Add your Python scripts to the examples folder
2. The script filename becomes the menu item name (with _ and - converted to spaces)
3. The `alibre_setup.py` script won't appear in the menu (it's for initialization)

#### Script Development
Each Python script has access to:
- `AlibreRoot` - The main Alibre application interface
- `CurrentSession` - The current Alibre session
- `ScriptFileName` - Name of the current script
- `ScriptFolder` - Path to the scripts folder
- `SessionIdentifier` - Unique session identifier
- `Arguments` - Command line arguments (if any)

### 4. Building and Deployment

1. Build your project in Visual Studio
2. The output will include:
   - Your addon DLL
   - The `.adc` configuration file
   - All Python scripts
3. Copy these files to your Alibre Design addons directory
4. Restart Alibre Design to load your addon

## Example Script Structure

```python
#!/usr/bin/env python3
"""
Your Custom Script
Description of what this script does
"""

import clr
from System.Runtime.InteropServices import Marshal
from AlibreScript.API import *

# Get Alibre interface
alibre = Marshal.GetActiveObject("AlibreX.AutomationHook")
root = alibre.Root
myPart = Part(root.TopmostSession)

# Set units
Units.Current = UnitTypes.Millimeters

# Your custom functionality here
def create_custom_part():
    # Add your part creation logic
    pass

# Execute your function
if __name__ == "__main__":
    create_custom_part()
```

## Best Practices

1. **Error Handling**: Always wrap your Python code in try-catch blocks
2. **User Feedback**: Use `print()` statements to provide user feedback
3. **Parameterization**: Make your scripts configurable with variables at the top
4. **Documentation**: Comment your code thoroughly
5. **Testing**: Test your addon with different Alibre Design versions

## Troubleshooting

### Common Issues

1. **Scripts not appearing in menu**: Check that they're in the correct folder and have `.py` extension
2. **Python execution errors**: Verify Alibre Design Python environment is properly configured
3. **Missing references**: Ensure all required DLLs are available in the Alibre installation

### Debug Tips

1. Use `MessageBox.Show()` in C# for debugging
2. Use `print()` statements in Python scripts
3. Check the Alibre Design console for error messages
4. Verify file paths are correct for your installation

## License

This template is provided as-is for educational and development purposes.
Modify and distribute according to your project's license requirements.