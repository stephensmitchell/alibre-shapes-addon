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

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

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
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\README.md"; Comment: "View {#MyAppName} Documentation"

[Code]
const
  NET_FW_PROFILE_DOMAIN = 1;
  NET_FW_PROFILE_PRIVATE = 2;
  NET_FW_PROFILE_PUBLIC = 4;
  NET_FW_PROFILE_ALL = 2147483647;
  NET_FW_IP_VERSION_ANY = 2;
  NET_FW_ACTION_ALLOW = 1;
  NET_FW_MODIFY_STATE = 1;

function InitializeSetup(): Boolean;
var
  NetFrameworkVersion: string;
begin
  Result := True;
  
  // Check for .NET Framework 4.8.1 or higher
  if not RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full', 'Version', NetFrameworkVersion) then
  begin
    MsgBox('Microsoft .NET Framework 4.8.1 or higher is required. Please install it before running this setup.', mbError, MB_OK);
    Result := False;
    Exit;
  end;
  
  if CompareVersion(NetFrameworkVersion, '4.8.1') < 0 then
  begin
    MsgBox('Microsoft .NET Framework 4.8.1 or higher is required. Current version: ' + NetFrameworkVersion + #13#10 + 
           'Please update your .NET Framework before running this setup.', mbError, MB_OK);
    Result := False;
    Exit;
  end;
end;

function CompareVersion(V1, V2: string): Integer;
var
  P, N1, N2: Integer;
begin
  Result := 0;
  while (Result = 0) and ((V1 <> '') or (V2 <> '')) do
  begin
    P := Pos('.', V1);
    if P > 0 then
    begin
      N1 := StrToInt(Copy(V1, 1, P - 1));
      Delete(V1, 1, P);
    end
    else if V1 <> '' then
    begin
      N1 := StrToInt(V1);
      V1 := '';
    end
    else
    begin
      N1 := 0;
    end;

    P := Pos('.', V2);
    if P > 0 then
    begin
      N2 := StrToInt(Copy(V2, 1, P - 1));
      Delete(V2, 1, P);
    end
    else if V2 <> '' then
    begin
      N2 := StrToInt(V2);
      V2 := '';
    end
    else
    begin
      N2 := 0;
    end;

    if N1 < N2 then
      Result := -1
    else if N1 > N2 then
      Result := 1;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Perform any post-installation tasks here
    Log('Installation completed successfully');
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
  // Skip components page if not needed
  if PageID = wpSelectComponents then
    Result := True;
end;

[Run]
; Run post-installation configuration if needed
; Filename: "{app}\Scripts\configure.bat"; Description: "Configure addon"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Messages]
WelcomeLabel2=This will install [name/ver] on your computer.%n%nThis addon provides script-based shape operations for Alibre Design.%n%nIt is recommended that you close Alibre Design before continuing.
