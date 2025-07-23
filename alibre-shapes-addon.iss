#define MyAppName "Alibre Shapes Addon"
#define MyAppVersion "2.0"
#define MyAppPublisher "Stephen S. Mitchell"
#define MyAppURL "https://github.com/stephensmitchell/alibre-shapes-addon"
#define MyAppExeName "alibre-shapes-addon.dll"
#define MyAppDescription "Alibre Script-based addon for shape operations"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{78C709DA-7E50-4BDC-A73B-79E730DDB7EC}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\Alibre Design\Addons\{#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=LICENSE
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=installer
OutputBaseFilename=alibre-shapes-addon-setup-v{#MyAppVersion}
SetupIconFile=
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
MinVersion=6.1sp1

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; Main addon files
Source: "src\bin\Debug\net481\alibre-shapes-addon.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bin\Debug\net481\alibre-shapes-addon.adc"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bin\Debug\net481\alibre-shapes-addon.pdb"; DestDir: "{app}"; Flags: ignoreversion

; IronPython dependencies
Source: "src\bin\Debug\net481\IronPython.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bin\Debug\net481\IronPython.Modules.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bin\Debug\net481\IronPython.SQLite.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bin\Debug\net481\IronPython.Wpf.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bin\Debug\net481\Microsoft.Dynamic.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bin\Debug\net481\Microsoft.Scripting.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bin\Debug\net481\Microsoft.Scripting.Metadata.dll"; DestDir: "{app}"; Flags: ignoreversion

; System dependencies
Source: "src\bin\Debug\net481\System.Buffers.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bin\Debug\net481\System.Memory.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bin\Debug\net481\System.Numerics.Vectors.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "src\bin\Debug\net481\System.Runtime.CompilerServices.Unsafe.dll"; DestDir: "{app}"; Flags: ignoreversion

; Python library files (recursive copy from lib directory)
Source: "src\bin\Debug\net481\lib\*"; DestDir: "{app}\lib"; Flags: ignoreversion recursesubdirs createallsubdirs

; Scripts directory
Source: "src\bin\Debug\net481\Scripts\*"; DestDir: "{app}\Scripts"; Flags: ignoreversion recursesubdirs createallsubdirs

; Documentation
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "LICENSE"; DestDir: "{app}"; Flags: ignoreversion

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Registry]
; Register the addon with Alibre Design
Root: HKLM; Subkey: "SOFTWARE\Alibre, LLC\Alibre Design\Addons\{#MyAppName}"; ValueType: string; ValueName: "Path"; ValueData: "{app}\alibre-shapes-addon.adc"; Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\Alibre, LLC\Alibre Design\Addons\{#MyAppName}"; ValueType: string; ValueName: "Description"; ValueData: "{#MyAppDescription}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\Alibre, LLC\Alibre Design\Addons\{#MyAppName}"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"; Flags: uninsdeletekey

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
