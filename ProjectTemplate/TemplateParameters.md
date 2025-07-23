# Alibre Script Addon Template Parameters

This file documents the template parameters used in the Visual Studio template.

## Available Parameters

### Standard Visual Studio Parameters
- `$safeprojectname$` - Project name safe for use in code (no spaces, special characters)
- `$projectname$` - User-friendly project name
- `$username$` - Current Windows username
- `$userdomain$` - Current user domain
- `$registeredorganization$` - Registered organization from Windows
- `$year$` - Current year (4 digits)
- `$time$` - Current time
- `$date$` - Current date
- `$guid1$`, `$guid2$`, etc. - Generated GUIDs
- `$repositoryurl$` - Repository URL (if applicable)

### Custom Parameters
These parameters can be customized by modifying the template wizard or using IWizard interface:

- `alibreversion` - Target Alibre Design version (default: 28.1.1.28227)
- `authorname` - Author name for the addon
- `authorurl` - Author website/profile URL
- `description` - Addon description

## Usage in Template Files

Parameters are used in template files using the `$parametername$` syntax. For example:
```xml
<Author name="$username$" link="$repositoryurl$"/>
<Copyright>Copyright (c) $year$ $username$</Copyright>
```

## Conditional Parameter Replacement

The template system supports conditional parameter replacement. Parameters are only replaced if they are enclosed in dollar signs and match exactly.

## File and Folder Name Parameters

Parameters can also be used in file and folder names:
- `$safeprojectname$.cs` becomes `MyAddon.cs`
- `Scripts/src/$safeprojectname$/` becomes `Scripts/src/MyAddon/`