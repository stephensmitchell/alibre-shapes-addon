# Alibre Shapes Add-On

Alibre Shapes Add-On is an Alibre Design add-on that generates parametric steel profiles in the active part by running bundled Alibre Script generators.

This build ships as a demo and template. It includes one generator, `Template.py`, which builds a square hollow section (square steel tube) from standard hot-formed and cold-formed dimension tables. At load time the add-on scans `Scripts\src\hss` and turns each `*.py` file into a menu item, so you extend it by adding more generator scripts.

A C# assembly hosts IronPython and runs the generators against the Alibre API. The project targets .NET Framework 4.8.1 (`net481`), builds for x64, and references the `AlibreAddOn` and `AlibreX` assemblies from Alibre Design 29.0.0.29060.

## Table Of Contents

- [What Is Here](#what-is-here)
- [Official Alibre Resources](#official-alibre-resources)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Usage](#usage)
- [Key Files](#key-files)
- [Key Folders](#key-folders)
- [Notes](#notes)
- [License](#license)

## What Is Here

- A C# Alibre add-on (`AlibreAddOn.cs`) that builds the `alibre-shapes-addon` menu and hosts an embedded IronPython script runner.
- One bundled generator, `Template.py`, that models a square hollow section with inner and outer corner fillets.
- Hot-formed and cold-formed dimension tables covering standard sizes from 20 mm to 400 mm.
- A setup script, `alibre_setup.py`, that binds the active part or assembly before each generator runs.
- Inno Setup and Advanced Installer configurations, with PowerShell and batch build scripts, for packaging the add-on.
- A GitHub Actions workflow (`.github/workflows/build-installers.yml`) for building the installers.

## Official Alibre Resources

Alibre's official resources for API development and AI/LLM/agent workflows: <https://www.alibre.com/api/>

## Requirements

- Alibre Design 29.0.0.29060 (x64). The build references `AlibreAddOn.dll` and `AlibreX.dll` from the Alibre Design install.
- .NET Framework 4.8.1 (the project targets `net481`) built for x64.
- IronPython 3.4.2 and IronPython.StdLib 3.4.2 (referenced via NuGet) to run the Alibre Script generators.
- For packaging: Inno Setup 6 or Advanced Installer.

## Quick Start

To try the add-on without building, run the prebuilt installer:

```text
source\alibre-shapes-addon-v2.0.exe
```

To build from source:

```bash
dotnet build source\alibre-shapes-addon.csproj -c Release -f net481
```

Then register the add-on with Alibre (see [Installation](#installation)), launch Alibre Design, open a Part, and pick a generator from the **alibre-shapes-addon** menu.

## Installation

Build the project, then install with one of the provided installers:

1. Build the add-on:
   ```bash
   dotnet build source\alibre-shapes-addon.csproj -c Release -f net481
   ```
2. Build an installer (see [documentation/INSTALLER-README.md](../documentation/INSTALLER-README.md) for full details):
   - Inno Setup: run `source\build-installer.ps1` (or `source\build-installer.bat`) to produce `installer\alibre-shapes-addon-setup-v2.0.exe`.
   - Advanced Installer: open `source\alibre-shapes-addon.aip` and build an MSI.
3. Run the installer as Administrator. It installs the add-on under `%ProgramFiles%\Alibre Design\Addons\`, registers `alibre-shapes-addon.adc` under `HKLM\SOFTWARE\Alibre, LLC\Alibre Design\Addons`, so Alibre discovers the add-on on startup.

## Usage

1. Launch Alibre Design and open or create a Part.
2. Open the **alibre-shapes-addon** menu and select a generator. The bundled square section appears as **Template** (from `Template.py`).
3. The script builds the profile in the active part from the size, wall thickness, fillet radii, and length set in the script. Edit those values near the top of `Scripts\src\hss\Template.py` to change the geometry. `HorC` selects hot (0) or cold (1) formed tables, `Size` selects the section, the thickness index selects a table row, and `Length` sets the extrusion length in mm.

## Key Files

| File | Purpose |
| --- | --- |
| `source/AlibreAddOn.cs` | The add-on: registers the menu, hosts IronPython, and runs generators against the Alibre API. |
| `source/Scripts/src/hss/Template.py` | Bundled generator; builds a square hollow section from hot-formed and cold-formed dimension tables. |
| `source/Scripts/src/hss/alibre_setup.py` | Setup script run before each generator; binds the active part or assembly from the current session. |
| `source/alibre-shapes-addon.csproj` | .NET SDK project targeting `net481` and x64; references AlibreAddOn and AlibreX; pulls IronPython from NuGet. |
| `source/alibre-shapes-addon.sln` | Visual Studio solution. |
| `source/alibre-shapes-addon.adc` | Alibre add-on manifest read at startup (assembly, menu text, identifier). |
| `source/alibre-shapes-addon.iss` | Inno Setup script for the EXE installer. |
| `source/alibre-shapes-addon.aip` | Advanced Installer project for the MSI installer. |
| `source/build-installer.ps1` | PowerShell script that builds the Inno Setup installer. |
| `source/installer-config.json` | Installer metadata: version, dependencies, registry path, and requirements. |
| `source/alibre-shapes-addon-v2.0.exe` | Prebuilt installer executable (v2.0). |
| `documentation/INSTALLER-README.md` | Installer build and packaging guide. |

## Key Folders

| Folder | Purpose |
| --- | --- |
| `source/` | Add-on C# source, the .NET project and solution, installer scripts, and the disclaimer. |
| `source/Scripts/src/hss/` | Alibre Script generators and `alibre_setup.py`; add a new `*.py` here to create a menu item. |
| `documentation/` | Installer build guide. |
| `reviews/` | Dated code-review notes. |
| `submodules/` | Placeholder for vendored submodules (currently holds only a `.gitkeep`). |
| `.github/` | This README, contribution and issue/PR templates, and the installer build workflow. |

## Notes

- This build labels itself a demo. The About dialog and the `.adc` description both read "Demo", and the single bundled generator is named Template.
- `ScriptRunner` hard-codes the Alibre install path `C:\Program Files\Alibre Design 29.0.0.29060`. A different Alibre version or install location needs a code change.
- Generator parameters live in the script as literal values. There is no parameter dialog. Edit `Template.py` to change size, thickness, fillet radii, or length.
- The fillet step in `Template.py` targets specific edge names (`Edge<6>`, `Edge<30>`, and similar). When the modeled edges change, the script prints a warning and skips the fillets.
- `installer-config.json` sets the build configuration to Debug and registers under `HKLM`, so installation writes to Program Files and needs Administrator rights.
- The generators run under the add-on's embedded IronPython 3.4.2 engine, which loads the Alibre Script API from the Alibre Design install.

## License

Per the bundled disclaimer (`source/alibre.disclaimer.txt`), the project uses the MIT License. See [LICENSE](../LICENSE).

Alibre, Alibre Design, and Alibre Script names and related materials belong to their respective owners.
