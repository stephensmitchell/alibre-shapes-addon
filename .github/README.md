# Alibre Shapes Add-On

An Alibre Design add-on that generates parametric steel profiles in the active part. It adds a menu to Alibre Design that runs bundled Python (Alibre Script) generators, modeling a section from standard dimension tables.

## Features
- Adds an "alibre-shapes-addon" menu to Alibre Design with an "About" entry and one entry per bundled shape script.
- Generates a square hollow section (square steel tube) as an extruded profile with inner and outer corner fillets.
- Includes hot-formed and cold-formed dimension tables with standard sizes from 20 mm to 400 mm.
- Section size, wall thickness, outer/inner fillet radii, and length are set in the script.
- Drop-in scripting: any `*.py` file added to `Scripts\src\hss` (other than `alibre_setup.py`) appears as a menu item, with the file name (without its `.py` extension, and with dashes and underscores shown as spaces) used as the menu label.

## Requirements
- Alibre Design 29.0.0.29060 (x64). The build references the `AlibreX` and `AlibreAddOn` assemblies from the Alibre Design install.
- .NET Framework 4.8.1 (the project targets `net481`).
- IronPython 3.4.2 and IronPython.StdLib 3.4.2 (referenced via NuGet) for running the Alibre Script generators.

## Installation
Build the project, then install with one of the provided installers:

1. Build the add-on:
   ```bash
   dotnet build source\alibre-shapes-addon.csproj -c Release -f net481
   ```
2. Build an installer (see [documentation/INSTALLER-README.md](../documentation/INSTALLER-README.md) for full details):
   - Inno Setup: run `source\build-installer.ps1` (or `source\build-installer.bat`) to produce a setup `.exe`.
   - Advanced Installer: open `source\alibre-shapes-addon.aip` and build an MSI.
3. Run the installer as Administrator. It copies the add-on, registers `alibre-shapes-addon.adc` with Alibre Design, and adds the required registry entries so Alibre discovers the add-on on startup.

## Usage
1. Launch Alibre Design and open or create a Part.
2. Open the **alibre-shapes-addon** menu and select a shape generator (the bundled square section is listed as **Template**).
3. The script builds the profile in the active part using the size, thickness, fillet radii, and length set in the script. Edit the parameters in `Scripts\src\hss\Template.py` to change the generated geometry.

## License
See [LICENSE](../LICENSE).
