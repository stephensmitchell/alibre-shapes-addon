# Alibre Design Script Addon Template

This Visual Studio project template creates a new Alibre Design Script-based addon with Python integration.

## Features

- C# addon framework with menu integration
- Python script execution capability
- Dynamic menu generation from Python scripts
- Template Python script included
- Proper project structure for Alibre addons

## Prerequisites

- Visual Studio 2019 or later
- .NET Framework 4.8.1
- Alibre Design installed

## Usage

1. Create a new project using this template
2. Build the project
3. Copy the output files to your Alibre Design addons directory
4. Restart Alibre Design
5. The addon menu will appear in Alibre Design

## Customization

- Modify the Python scripts in the Scripts folder to create your own shapes
- Update the C# code to add additional menu items or functionality
- Change the addon metadata in the .adc file

## Template Parameters

The template will automatically replace the following parameters:
- `$safeprojectname$` - Safe project name (no spaces/special chars)
- `$projectname$` - Display project name
- `$username$` - Current user name
- `$year$` - Current year
- `$repositoryurl$` - Repository URL (if applicable)

## Structure

```
YourAddon/
├── YourAddon.cs          # Main addon implementation
├── YourAddon.adc         # Addon configuration
├── YourAddon.csproj      # Project file
└── Scripts/
    └── src/
        └── YourAddon/
            ├── alibre_setup.py    # Python setup script
            └── Template.py        # Example Python script
```