# Code Review — alibre-shapes-addon

- **Date:** 2026-06-14
- **Branch:** `the-tool-store` @ `25cae7b` ("cleanup push")
- **Reviewer:** Claude (Opus 4.8)
- **Scope:** Full repository review (C# add-on host + IronPython shape scripts + installer/build tooling)

---

## 1. Summary

This is an Alibre Design add-on that exposes a ribbon menu and dynamically loads IronPython
scripts to generate parametric steel-shape geometry (square hollow sections). The C# layer
(`AlibreAddOn.cs`) is the COM-facing host; the Python layer (`Scripts/src/hss/`) does the CAD
modeling.

The code is small (~13 tracked files, ~400 LOC of real logic) and the core menu/script-runner
plumbing is reasonable. However, there is a **broken installer build path**, a **likely runtime
failure because `alibre_setup.py` is never copied to the output directory**, several **hard-coded
absolute paths/versions** that break portability, and a fair amount of **copy-paste leftover
configuration**. The Python `Template.py` has dead "interactive" prompts and brittle hard-coded
edge names.

**Overall:** Functional prototype with real correctness and packaging bugs. Recommend addressing
the Critical and High items before shipping the v2.0 installer.

### Findings by severity

| Severity | Count |
|----------|-------|
| Critical | 2 |
| High     | 4 |
| Medium   | 5 |
| Low / Nit| 6 |

---

## 2. Critical

### C-1. Installer build references `src\` but the project lives in `source\`
**Files:** [build-installer.ps1:39](source/build-installer.ps1), [build-installer.bat:23](source/build-installer.bat), [alibre-shapes-addon.iss:39-66](source/alibre-shapes-addon.iss), [installer-config.json:17](source/installer-config.json)

Every build/packaging artifact points at a `src\` directory:

```
dotnet build "src\alibre-shapes-addon.csproj" ...          # build-installer.ps1 / .bat
Source: "src\bin\Debug\net481\alibre-shapes-addon.dll" ...  # .iss
"projectPath": "src\\alibre-shapes-addon.csproj"            # installer-config.json
```

The actual layout is `source\alibre-shapes-addon.csproj`. There is no `src\` directory. The
build and the Inno Setup compile will both fail immediately ("project not found" / "source file
not found"). Pick one folder name and make all four files agree.

### C-2. `alibre_setup.py` is never copied to the output directory → every script run fails
**Files:** [alibre-shapes-addon.csproj:35-42](source/alibre-shapes-addon.csproj), [AlibreAddOn.cs:194-200](source/AlibreAddOn.cs)

`ScriptRunner.ExecuteScript` requires `alibre_setup.py` next to the main script:

```csharp
string setupScriptPath = Path.Combine(ScriptsPath, "alibre_setup.py");
...
if (!File.Exists(setupScriptPath) || !File.Exists(mainScriptPath)) { /* error + return */ }
```

But the `.csproj` only copies `Scripts\src\hss\Template.py` to output — `alibre_setup.py` has **no
`<Content>` / `CopyToOutputDirectory` entry**. After a clean build the output folder will contain
`Template.py` but not `alibre_setup.py`, so the file-existence check fails and the user gets a
"Script not found" MessageBox for *every* menu item. The Inno script copies `Scripts\*`
recursively from the build output, so the missing-from-output problem propagates into the
installer too.

**Fix:** add `alibre_setup.py` (and ideally glob the whole `Scripts\**\*.py`) to the copied
content, e.g.:

```xml
<Content Include="Scripts\**\*.py">
  <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
</Content>
```

---

## 3. High

### H-1. Hard-coded, version-pinned Alibre install path
**File:** [AlibreAddOn.cs:181-185](source/AlibreAddOn.cs)

```csharp
string alibreInstallPath = "C:\\Program Files\\Alibre Design 28.1.1.28227";
```

This breaks on any other Alibre version, any non-default install location, and any localized
Program Files path. The same pinned version appears in the `.csproj` `HintPath`s
([csproj:52,56](source/alibre-shapes-addon.csproj)). Resolve the install root at runtime instead —
the add-on is already loaded *by* Alibre, so derive it from the running process / the registry key
the installer itself writes (`SOFTWARE\Alibre, LLC\Alibre Design`), or from an env var, with the
hard-coded path only as a last-resort fallback.

### H-2. `.iss` packages `README.md` and `.pdb` that may not exist
**File:** [alibre-shapes-addon.iss:41,65](source/alibre-shapes-addon.iss)

```
Source: "src\bin\Debug\net481\alibre-shapes-addon.pdb"; ...
Source: "README.md"; DestDir: "{app}"; ...
```

There is no `README.md` at the repo root (only `LICENSE`, `documentation/`, `source/`,
`submodules/`). Inno Setup treats a missing non-`skipifsourcedoesntexist` source as a fatal
compile error. The `.pdb` line will also fail under a Release build. Either add the README, point
at `documentation/INSTALLER-README.md`, or add `Flags: skipifsourcedoesntexist`.

### H-3. Duplicated `SaveData`/`LoadData` with one pair throwing `NotImplementedException`
**File:** [AlibreAddOn.cs:70-84](source/AlibreAddOn.cs)

`AddOnRibbon` declares two overloads each of `SaveData`/`LoadData`: a no-op pair typed against
`System.Runtime.InteropServices.ComTypes.IStream` (the `using` alias at line 11) and a second pair
typed against `global::AlibreAddOn.IStream` that `throw new NotImplementedException()`. The
`IAlibreAddOn` interface is satisfied by exactly one of these signatures — almost certainly the
`AlibreAddOn.IStream` one. That means the methods the host actually calls are the **throwing**
ones. `HasPersistentDataToSave` returns `false`, which protects `SaveData`, but `LoadData` is
commonly invoked on document open regardless, and an unhandled `NotImplementedException` crossing
the COM boundary can destabilize the host. Confirm which signature the interface binds and make
the bound implementation a safe no-op.

### H-4. Build/output binaries committed to source control
**Files:** `source/alibre-shapes-addon-v2.0.exe` (tracked), plus the `.iss` consumes `bin\Debug\...`

`git ls-files` shows `source/alibre-shapes-addon-v2.0.exe` is checked in. Committing built
binaries bloats history, invites stale artifacts, and is a supply-chain/trust hazard for anyone
cloning the repo. Remove it from the index (`git rm --cached`) and confirm `.gitignore` covers
`bin/`, `obj/`, `installer/`, and `*.exe` under `source/`.

---

## 4. Medium

### M-1. Hard-coded values defeat the "interactive" prompts in `Template.py`
**File:** [Template.py:55-73](source/Scripts/src/hss/Template.py)

The script prints prompts that imply user input, then immediately hard-codes the answers:

```python
print('Select hot or cold formed profiles')
print('0 = Hot\n1 = Cold')
HorC = int(1)          # always cold-formed
...
Size = int(50)         # always 50 mm
readTh = int(2)        # always thickness index 2
Length = float(100.0)  # always 100 mm
```

So the script always produces the same part regardless of the prompts, and the prompts are
misleading. Either wire these to real input (a WinForms/WPF dialog, or `Arguments` which is
already passed into the scope at [AlibreAddOn.cs:205](source/AlibreAddOn.cs)) or delete the dead
prompts. The `int(...)` casts of integer literals are also pointless.

### M-2. `Template.py` ignores the session handed in by the host
**File:** [Template.py:6-8](source/Scripts/src/hss/Template.py) vs [alibre_setup.py:6-11](source/Scripts/src/hss/alibre_setup.py)

`alibre_setup.py` carefully builds `CurrentPart`/`CurrentAssembly` from the injected
`CurrentSession`, but `Template.py` throws that away and re-acquires its own root and part:

```python
alibre = Marshal.GetActiveObject("AlibreX.AutomationHook")
root = alibre.Root
myPart = Part(root.TopmostSession)   # not necessarily the user's active session
```

`TopmostSession` may not be the session the menu command was invoked on, so the geometry can land
in the wrong document. Use the `CurrentPart` that setup already prepared.

### M-3. Public methods can return `null` to the COM host
**File:** [AlibreAddOn.cs:54,63-65](source/AlibreAddOn.cs)

- `SubMenuItems` returns `null` (not an empty `Array`) when the id is unknown.
- `InvokeCommand` does `_alibreRoot.Sessions.Item(sessionIdentifier)` with no null check before
  passing `session` to the command.

Hosts generally expect non-null collections and tolerate odd ids. Return `Array.Empty<int>()` /
guard the session lookup to avoid NREs surfacing across the COM boundary.

### M-4. Stale / phantom entries in the `.csproj`
**File:** [alibre-shapes-addon.csproj:6,18-29,60-67](source/alibre-shapes-addon.csproj)

- `<RootNamespace>AssimpInsideAlibreDesignAddon</RootNamespace>` — leftover from a different
  ("Assimp") project; the real namespace is `AlibreAddOnAssembly`.
- `<None Update="alibre-stltostp-addon.adc">` and `<None Update="config.json">` reference files
  that don't exist (copy-paste from an STL→STEP add-on).
- `Compile/EmbeddedResource/None/Page Remove` blocks for `AlibreAddOn - Copy\**`, `Examples\**`,
  `icons\**` — none of those directories exist.

None are fatal but they signal the project was cloned from another and never cleaned, which makes
the build harder to reason about.

### M-5. Build configuration is hard-wired to `Debug`
**Files:** [installer-config.json:14](source/installer-config.json), [alibre-shapes-addon.iss:39-62](source/alibre-shapes-addon.iss), [build-installer.ps1:39](source/build-installer.ps1)

The shipping installer packages from `bin\Debug\net481\`. A released add-on should ship a Release
build (optimized, no debug `.pdb` requirement). Parameterize the configuration or switch the
default to `Release`.

---

## 5. Low / Nits

### L-1. `MenuItem` constructor silently ignores its `icon` parameter
[AlibreAddOn.cs:98-104](source/AlibreAddOn.cs): the ctor takes `string icon = null` but the body
hard-codes `Icon = null;`. Combined with `MenuIcon` always returning `null`
([line 59](source/AlibreAddOn.cs)) and the `Icon` property never being read, all icon plumbing is
dead code. Either implement it or remove the parameter/property to avoid confusion.

### L-2. Class named identically to a namespace forces `global::` qualifiers
`public static class AlibreAddOn` inside `namespace AlibreAddOnAssembly` collides with the SDK's
`AlibreAddOn` namespace (`using AlibreAddOn;` at [line 1](source/AlibreAddOn.cs)), which is exactly
why `global::AlibreAddOn.IStream` is needed at lines 76/81. Renaming the static class (e.g.
`AddOnEntryPoint`) removes the ambiguity.

### L-3. Unused imports in `Template.py`
[Template.py:1-2](source/Scripts/src/hss/Template.py): `import math` and `import sys` are never
used.

### L-4. Brittle hard-coded fillet edge names
[Template.py:88-89](source/Scripts/src/hss/Template.py): `Edge<6>`, `Edge<2>`, `Edge<30>`, …
depend on Alibre's internal edge numbering, which changes if the feature tree changes. The
`try/except` acknowledges this, but the result is silently un-filleted geometry. Consider
selecting edges by geometric query (e.g. by radius/position) rather than by internal name.

### L-5. `HorC`/`PData` data tables are large and undocumented
[Template.py:9-54](source/Scripts/src/hss/Template.py): `HData`/`CData` are dense numeric tables
with no comment on units or column meaning (`[thickness, outer_r, inner_r]`?). A one-line header
comment and the data source/standard (EN 10219? etc.) would make this maintainable and
auditable — these are engineering values where correctness matters.

### L-6. Errors are only surfaced via `MessageBox`, never logged
[AlibreAddOn.cs:160,198,213](source/AlibreAddOn.cs): every failure path is a modal dialog with no
persistent log. For field debugging, also write to a log file (or Alibre's diagnostics) so users
can report failures without screenshots.

---

## 6. What looks good

- Clean separation between the C# host and the Python modeling logic.
- Dynamic menu discovery (scan `*.py`, skip `alibre_setup.py`) is a nice extensibility pattern —
  drop in a script, get a menu item.
- `ScriptRunner` correctly injects session context into the Python scope and wraps execution in a
  try/catch.
- Lifecycle (`AddOnLoad`/`AddOnUnload`) nulls out statics on unload.
- The `.adc` manifest and registry registration are coherent with the Alibre add-on spec.

---

## 7. Recommended fix order

1. **C-1** + **C-2** — without these the build is broken and no script can run. (blocking)
2. **H-1** — unpins the add-on from one exact Alibre version.
3. **H-2 / H-4 / M-5** — make the installer actually compile and ship a clean Release build.
4. **H-3** — verify the bound `SaveData`/`LoadData` overload is a safe no-op.
5. **M-1 / M-2** — make `Template.py` produce correct, parameterized geometry in the right session.
6. Sweep the **M-4 / L-*** cleanups when touching the project file.
