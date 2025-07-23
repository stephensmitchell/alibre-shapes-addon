# Using the Alibre Script Addon Template

This guide walks through creating a new addon using the template and customizing it for your specific needs.

## Creating Your First Addon

### Step 1: Create Project from Template

1. Open Visual Studio
2. Click "Create a new project"
3. Search for "Alibre Design Script Addon"
4. Select the template and click "Next"
5. Configure your project:
   - **Project name**: `MyShapesAddon` (example)
   - **Location**: Choose your development folder
   - **Solution name**: `MyShapesAddon` (or leave default)
6. Click "Create"

### Step 2: Examine Generated Project

Your new project will have this structure:
```
MyShapesAddon/
├── MyShapesAddon.cs          # Main addon implementation
├── MyShapesAddon.adc         # Addon configuration
├── MyShapesAddon.csproj      # Project file
├── MyShapesAddon.sln         # Solution file
└── Scripts/
    └── src/
        └── MyShapesAddon/
            ├── alibre_setup.py    # Python setup
            └── Template.py        # Example script
```

### Step 3: Build the Project

1. Right-click the solution and select "Build Solution"
2. The output will be in `bin/Debug` or `bin/Release`
3. You should see:
   - `MyShapesAddon.dll`
   - `MyShapesAddon.adc`
   - `Scripts/` folder with Python files

## Customizing Your Addon

### Adding New Python Scripts

1. **Create a new Python file** in `Scripts/src/MyShapesAddon/`
2. **Name it descriptively**, e.g., `CreateGear.py`
3. **The addon will automatically** add it to the menu

Example script (`CreateGear.py`):
```python
# CreateGear.py - Simple gear creation script

import math
from AlibreScript.API import *

# Get current part
myPart = CurrentPart
if not myPart:
    print("Please create or open a part first")
    exit()

# Gear parameters
teeth = 20
module = 2.0  # Module in mm
pressure_angle = 20.0  # degrees

# Calculate gear dimensions
pitch_diameter = teeth * module
outer_diameter = pitch_diameter + (2 * module)

print(f"Creating gear with {teeth} teeth, module {module}")
print(f"Pitch diameter: {pitch_diameter}mm")
print(f"Outer diameter: {outer_diameter}mm")

# Create gear profile (simplified)
gear_sketch = myPart.AddSketch('GearProfile', myPart.GetPlane('XY-Plane'))

# Add a simple circular approximation for demonstration
gear_sketch.AddCircle(Circle(0, 0, outer_diameter/2))
gear_sketch.AddCircle(Circle(0, 0, pitch_diameter/2))

# Extrude to create gear
gear_thickness = 10.0
myPart.AddExtrudeBoss('GearBody', gear_sketch, gear_thickness, False)

print("Gear created successfully!")
```

### Customizing the Menu

The menu is automatically generated from your Python scripts, but you can customize it by modifying the `MenuManager` class in your main C# file:

```csharp
private void BuildMenus()
{
    // Add custom "About" menu
    var aboutItem = new MenuItem(9090, "About", "About MyShapesAddon");
    aboutItem.Command = aboutItem.AboutCmd;
    _rootMenuItem.AddSubItem(aboutItem);

    // Add a separator (custom menu item)
    var separatorItem = new MenuItem(9091, "───────────", "");
    _rootMenuItem.AddSubItem(separatorItem);

    // Existing script loading code...
    // ...
}
```

### Modifying Addon Metadata

Edit the `.adc` file to customize addon information:

```xml
<AlibreDesignAddOn specificationVersion="2" friendlyName="MyShapesAddon">
    <Author name="Your Name" link="https://yourwebsite.com"/>
    <Copyright>Copyright (c) 2025 Your Name</Copyright>
    <DLL type="Managed" loadedWhen="Startup" location="MyShapesAddon.dll"/>
    <Icon location=""/> 
    <Menu text="My Shapes"/>
    <Description>Custom shapes addon for mechanical components</Description> 
    <Workspace type="Always"/>
    <Property name="Identifier" value="MyShapesAddon"/>
</AlibreDesignAddOn>
```

## Advanced Customization

### Adding Parameters to Scripts

You can create interactive scripts that prompt for parameters:

```python
# Interactive script example
import clr
from System.Windows.Forms import MessageBox, DialogResult
from AlibreScript.API import *

# Simple parameter input (in real implementation, use proper dialog)
result = MessageBox.Show("Create a large gear?", "Gear Size", 
                        MessageBoxButtons.YesNo)

if result == DialogResult.Yes:
    module = 5.0
    teeth = 30
else:
    module = 2.0
    teeth = 20

# Rest of gear creation code...
```

### Error Handling

Add robust error handling to your scripts:

```python
try:
    # Your shape creation code here
    myPart = CurrentPart
    if not myPart:
        raise Exception("No active part found")
    
    # Shape creation logic...
    
except Exception as e:
    print(f"Error creating shape: {e}")
    # Optionally show message box
    MessageBox.Show(f"Error: {e}", "Shape Creation Error")
```

### Organizing Scripts by Category

Create subdirectories in your Scripts folder:

```
Scripts/
└── src/
    └── MyShapesAddon/
        ├── alibre_setup.py
        ├── Gears/
        │   ├── SimpleGear.py
        │   └── HelicalGear.py
        ├── Fasteners/
        │   ├── Bolt.py
        │   └── Nut.py
        └── Profiles/
            ├── IBeam.py
            └── Channel.py
```

Then modify the menu builder to create submenus:

```csharp
// In BuildMenus() method
var gearsMenu = new MenuItem(8000, "Gears", "Gear creation tools");
var fastenersMenu = new MenuItem(8001, "Fasteners", "Bolt and nut tools");

// Add scripts to appropriate submenus
// Implementation details depend on your folder scanning logic
```

## Deployment

### Installing Your Addon

1. **Build in Release mode** for distribution
2. **Copy the entire output folder** to Alibre Design's addons directory:
   - Default: `C:\Program Files\Alibre Design\Program\Addons\YourAddon\`
3. **Restart Alibre Design**
4. **Your addon menu** should appear in the interface

### Distributing Your Addon

1. **Create a ZIP package** containing:
   - All DLL files
   - The .adc configuration file
   - Scripts folder with all Python files
   - README with installation instructions

2. **Provide installation instructions** for end users

3. **Consider version management** - update the .adc file with version information

## Best Practices

### Script Organization
- Keep scripts focused on single tasks
- Use descriptive filenames that will make good menu items
- Include error handling and user feedback
- Document your scripts with comments

### Performance
- Avoid heavy computations in menu building
- Use lazy loading for complex operations
- Cache frequently used data

### User Experience
- Provide clear feedback messages
- Handle edge cases gracefully
- Use consistent naming conventions
- Include helpful tooltips in menu items

### Testing
- Test with different Alibre Design document types
- Verify script execution in various contexts
- Test menu functionality thoroughly
- Include unit tests for complex algorithms

This template provides a solid foundation for creating professional Alibre Design addons with minimal setup time and maximum flexibility.