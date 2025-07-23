# Alibre Design Addon Template

This repository provides a Visual Studio template for creating Alibre Design addons using C# and Python scripting.

## About This Template

This template demonstrates how to create script-based addons for Alibre Design. It provides:

- A complete C# addon framework for Alibre Design
- Dynamic Python script loading and execution
- Template placeholders for easy customization
- Example scripts to get you started
- Proper project structure for addon development

## Getting Started

1. Use this template to create a new Visual Studio project
2. Replace template placeholders with your specific values:
   - `$safeprojectname$` - Your addon name
   - `$username$` - Your name/organization
   - `$projecturl$` - Your project URL
   - `$projectdescription$` - Description of your addon
   - `$date$` - Current date
   - `$year$` - Current year

3. Customize the Python scripts in `Scripts/src/examples/` 
4. Update the addon functionality in `AlibreAddOn.cs`
5. Build and install your addon

## Template Structure

```
├── src/
│   ├── AlibreAddOn.cs              # Main addon implementation
│   ├── $projectname$.csproj        # Project file  
│   ├── $projectname$.adc           # Addon configuration
│   └── Scripts/
│       └── src/
│           └── examples/
│               ├── alibre_setup.py # Python setup script
│               └── Template.py     # Example Python script
```

## Customizing Your Addon

1. **C# Code**: Modify `AlibreAddOn.cs` to implement your specific addon functionality
2. **Python Scripts**: Replace the example scripts with your own Python automation scripts
3. **Menu Structure**: Update the menu building logic to match your addon's needs
4. **Addon Metadata**: Customize the `.adc` file with your addon information

## Requirements

- Visual Studio 2019 or later
- .NET Framework 4.8.1
- Alibre Design (compatible version)

## Building and Installation

1. Build the solution in Visual Studio
2. Copy the output files to your Alibre Design addons directory
3. Restart Alibre Design to load your addon

**Submit questions to the Alibre Forum or contact the original template author.**

https://www.alibre.com/
https://www.alibre.com/forum/index.php
