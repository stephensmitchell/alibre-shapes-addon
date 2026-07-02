# Code Review — alibre-shapes-addon

- **Date:** 2026-06-15
- **Branch:** `review/2026-06-15-code-review` (code @ `25cae7b`, "cleanup push")
- **Reviewer:** Claude (Opus 4.8)
- **Scope:** Full repository re-review (C# COM host + IronPython shape scripts + installer/build/CI tooling)

---

## 0. Status vs. the 2026-06-14 review

**The application/build code is unchanged since the previous review.** The only commits added
since are the `2026-06-14-code-review.md` document and its merge (`0627773`); the tracked source
tree is byte-identical to base `25cae7b`. Therefore **every finding in
[`reviews/2026-06-14-code-review.md`](2026-06-14-code-review.md) still stands** — they have not
been addressed. I re-verified the two Critical and four High items against the source and confirm
they are all still present (see §2).

This document does **not** repeat the prior findings in full. It records:
1. A spot-check confirmation that the prior Critical/High items are unfixed, and
2. **New findings** the 2026-06-14 review did not cover — most importantly a CI workflow that
   cannot succeed.

---

## 1. New findings summary

| ID  | Severity | Title |
|-----|----------|-------|
| N-1 | Critical | GitHub Actions `build-installers.yml` can never produce an installer |
| N-2 | High     | `src\` vs `source\` path mismatch also breaks the CI workflow |
| N-3 | Medium   | CI uses .NET 6 SDK to build a `net481` (.NET Framework) target |
| N-4 | Low      | `AlibreAddOn.cs` listed as `<None>` in the `.csproj` (redundant/confusing) |
| N-5 | Low      | Two parallel installer systems (Inno Setup + Advanced Installer `.aip`) |
| N-6 | Nit      | `.adc` manifest field inconsistencies (`friendlyName` vs identifier, "Demo") |

---

## 2. Confirmation: prior Critical/High items still unfixed

- **C-1 (installer `src\` path mismatch):** still present in
  [build-installer.ps1:39](source/build-installer.ps1),
  [installer-config.json:17](source/installer-config.json), and
  [alibre-shapes-addon.iss:39-66](source/alibre-shapes-addon.iss). Confirmed.
- **C-2 (`alibre_setup.py` never copied to output):** the `.csproj` still copies only
  `Scripts\src\hss\Template.py` ([csproj:39-41](source/alibre-shapes-addon.csproj)); no content
  entry exists for `alibre_setup.py`. [AlibreAddOn.cs:196](source/AlibreAddOn.cs) still hard-requires
  it next to the main script → every script run will fail. Confirmed.
- **H-1 (hard-coded Alibre version path):** [AlibreAddOn.cs:181](source/AlibreAddOn.cs) and
  [csproj:52,56](source/alibre-shapes-addon.csproj) still pin
  `C:\Program Files\Alibre Design 28.1.1.28227`. Confirmed.
- **H-2 (`.iss` references missing `README.md`):** confirmed; additionally `LICENSE`
  ([iss:66](source/alibre-shapes-addon.iss)) is referenced relative to the `.iss` (i.e.
  `source\LICENSE`) but `LICENSE` lives at the **repo root**, so that source will also fail to
  resolve when compiling from `source/`.
- **H-3 (duplicate `SaveData`/`LoadData`, one pair throws):** confirmed at
  [AlibreAddOn.cs:71-84](source/AlibreAddOn.cs).
- **H-4 (built `.exe` committed):** confirmed — `source/alibre-shapes-addon-v2.0.exe` (~10 MB) is
  tracked. Note: the root [`.gitignore`](.gitignore) **already** ignores `*.exe`, `installer/`,
  and `**/[Bb]in/*`, so the binary must have been force-added. Fix is simply
  `git rm --cached source/alibre-shapes-addon-v2.0.exe`.

---

## 3. New findings (detail)

### N-1. Critical — the CI workflow cannot produce a working build/installer
**File:** [.github/workflows/build-installers.yml](.github/workflows/build-installers.yml)

The workflow runs on every push/PR to `main` and on tags, and is the only automated path to a
release artifact. It will fail (or silently upload nothing) for several independent reasons:

1. **Missing proprietary SDK references (fundamental).** The build resolves
   `AlibreAddOn.dll` and `AlibreX.dll` from
   `C:\Program Files\Alibre Design 28.1.1.28227\Program\...` ([csproj:52,56](source/alibre-shapes-addon.csproj)).
   Alibre Design is **not installed on the `windows-latest` runner**, so reference resolution fails
   and the `dotnet build` step errors out. There is no step that installs Alibre or vendors these
   DLLs. As written, the workflow can never compile this project. Either commit/cache the required
   reference assemblies (license permitting) or gate/remove the CI build until that is solved.
2. **Wrong project path** (see N-2): `dotnet restore src/...` and `dotnet build src/...` point at a
   non-existent `src/` directory.
3. **Wrong `.iss` path:** the build step runs
   `ISCC.exe "alibre-shapes-addon.iss"` from the repo root, but the script lives at
   `source/alibre-shapes-addon.iss`. ISCC will report "file not found".
4. **Artifact path mismatch:** `upload-artifact` and the release step use `installer/*.exe`
   (relative to repo root), but the `.iss` `OutputDir=installer` is resolved relative to the
   script's own directory → output would land in `source/installer/`. The upload would find no
   files.

Because of (1) the job fails early, which masks (2)–(4); all four must be fixed for CI to work.

### N-2. High — `src\` vs `source\` mismatch extends into CI
**File:** [build-installers.yml:23,26](.github/workflows/build-installers.yml)

This is the same root cause as prior finding C-1, but C-1 enumerated the local build scripts and
the `.iss`/`installer-config.json` — it did **not** mention the GitHub Actions workflow, which also
hard-codes `src/alibre-shapes-addon.csproj`. When renaming `src` ↔ `source` to fix C-1, this file
must be included or CI stays broken even after the local build is fixed.

### N-3. Medium — CI installs .NET 6 SDK but the target is `net481`
**File:** [build-installers.yml:18-20,26](.github/workflows/build-installers.yml)

`actions/setup-dotnet` is pinned to `dotnet-version: '6.0.x'`, then the build targets
`-f net481` (.NET Framework 4.8.1). Building a Framework target needs the 4.8.1 targeting pack /
MSBuild, not the .NET 6 SDK. On the hosted image it may happen to find the Framework reference
assemblies, but the declared toolchain is mismatched and fragile. Either drop the
`setup-dotnet@6.0.x` step and use the pre-installed MSBuild, or install the correct targeting pack
explicitly.

### N-4. Low — `AlibreAddOn.cs` is declared as `<None>` in the project file
**File:** [alibre-shapes-addon.csproj:43-45](source/alibre-shapes-addon.csproj)

```xml
<ItemGroup>
  <None Include="AlibreAddOn.cs" />
</ItemGroup>
```

Under the SDK-style project, `*.cs` files are already compiled via the implicit glob, so the file
still builds — but additionally listing the **only source file** as `None` is misleading (it reads
as "this is not compiled") and risks a duplicate-item warning. Remove this `ItemGroup`. This is
adjacent to prior finding M-4 (project-file cruft) but was not called out there.

### N-5. Low — two competing installer systems are maintained in parallel
**Files:** [alibre-shapes-addon.iss](source/alibre-shapes-addon.iss),
[alibre-shapes-addon.aip](source/alibre-shapes-addon.aip)

The repo ships both an Inno Setup script and an Advanced Installer project (`.aip`, requires a paid
license; the CI even has a commented-out stub for it). They duplicate product metadata (name,
version, GUID, registry keys) that can drift out of sync, and it is unclear which one is canonical.
Pick one as the supported installer and remove or clearly mark the other as unsupported.

### N-6. Nit — `.adc` manifest field inconsistencies
**File:** [alibre-shapes-addon.adc](source/alibre-shapes-addon.adc)

- `friendlyName="alibre-shapes"` but the `Identifier` property and `Menu text` are
  `alibre-shapes-addon` — inconsistent naming.
- `<Description>Demo</Description>` is a placeholder; the installer/config use the fuller
  "Alibre Script-based addon for shape operations".
- `<Icon location=""/>` is empty (consistent with icons being dead code per prior L-1).

Harmless individually, but together they reinforce the "prototype/copy-paste" signal from M-4/L-2.

---

## 4. What looks good (additions)

- The root `.gitignore` is comprehensive and already covers build output, installers, and `*.exe`
  — so cleaning up H-4 is a one-line `git rm --cached`, not a `.gitignore` change.
- The CI workflow's *intent* (build → Inno Setup → upload artifact → release on tag) is a sensible
  pipeline shape; it just needs the SDK-availability and path problems resolved.

---

## 5. Recommended fix order (supersedes/extends the 2026-06-14 order)

1. **C-1 + N-2** — unify on one folder name (`src` or `source`) across *all* of: build scripts,
   `.iss`, `installer-config.json`, **and** `build-installers.yml`. (blocking)
2. **C-2** — copy `Scripts\**\*.py` (incl. `alibre_setup.py`) to output. (blocking)
3. **N-1** — make the Alibre SDK DLLs available to CI (vendor/cache them) or disable the CI build
   until that is solved; then fix the `.iss` path and `installer/*.exe` artifact path. (blocking
   for any green CI)
4. **H-1** — resolve the Alibre install root at runtime / via registry instead of the pinned path.
5. **H-2 / H-4 / M-5 / N-3** — fix installer source paths (README/LICENSE), drop the committed
   `.exe`, ship Release, and align the CI toolchain.
6. **H-3** — confirm the bound `SaveData`/`LoadData` overload is a safe no-op.
7. **M-1 / M-2** — make `Template.py` parameterized and run in the host's session.
8. **N-4 / N-5 / N-6 / M-4 / L-*** — project-file and manifest cleanup; consolidate installers.
