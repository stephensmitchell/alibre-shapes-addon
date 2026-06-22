# alibre-shapes-addon — Code Review (Correctness)

**Date:** 2026-06-20
**Scope:** Second-opinion review, code only (correctness bugs).

**Summary: 3 bugs — 1 High, 2 Medium**

## High

- **`source/AlibreAddOn.cs:103`** — The `MenuItem` constructor accepts an `icon` parameter but assigns `Icon = null;` instead of `Icon = icon;`, so the parameter is silently discarded and `Icon` is never set to a caller-provided value. The constructor parameter is effectively dead and any future icon passed in is dropped. (Note: icon retrieval via `MenuIcon` is also hardcoded to `null` at line 59, so this currently has no visible effect, but the assignment is a real logic error.)

## Medium

- **`source/AlibreAddOn.cs:76-84`** — The interface implementations `LoadData(global::AlibreAddOn.IStream, …)` and `SaveData(global::AlibreAddOn.IStream, …)` `throw new NotImplementedException()`, while separate no-op overloads taking the aliased `System.Runtime.InteropServices.ComTypes.IStream` (lines 71-72) silently do nothing. The aliased-type methods at 71-72 are not the interface methods; the actual `IAlibreAddOn` members are the throwing ones. If the host ever calls `SaveData`/`LoadData` (e.g., a future change makes `HasPersistentDataToSave` return true, or the host calls `LoadData` on session restore regardless), the add-on will crash with an unhandled exception rather than no-op as apparently intended.

- **`source/AlibreAddOn.cs:54`** — `SubMenuItems(int menuID)` returns `null` (via `?.`) when the menu ID is not found in the dictionary, instead of an empty array. The COM host calling `SubMenuItems` typically expects an `Array`; returning `null` for an unknown ID can cause a null dereference / marshaling failure in the host. `HasSubMenus` (line 53) similarly returns `null` coalesced to a bool comparison which is safe, but `SubMenuItems` handing back `null` is the riskier one.

## Reviewed and considered clean

- **`Template.py`** — The `HData`/`CData` lookups (`PData[Size][readTh]`) use hardcoded `Size=50` and `readTh=2`, which are valid indices for the data tables, so no index-out-of-range occurs as written. The `scaleFactor` computation and fillet creation are wrapped in a `try/except` that prints rather than swallows silently, which is acceptable. The hardcoded `int(1)/int(2)/float(100.0)` placeholders make the script non-interactive but are not correctness bugs.
- **`alibre_setup.py`** — Null-guards `CurrentSession` before `isinstance` checks; correct.

No off-by-one, race condition, or resource-leak bugs were found in the Python scripts.

---

## Fixes applied — 2026-06-20

- **[High] `source/AlibreAddOn.cs:103`** — `Icon = null;` → `Icon = icon;` (constructor parameter no longer discarded).
- **[Medium] `source/AlibreAddOn.cs`** — the real `IAlibreAddOn` `LoadData`/`SaveData` members (taking `global::AlibreAddOn.IStream`) are now no-ops instead of throwing `NotImplementedException`, matching the intended no-op persistence.
- **[Medium] `source/AlibreAddOn.cs`** — `SubMenuItems` returns an empty `int[]` (`?? new int[0]`) instead of `null` for unknown menu IDs.

*Caveat: changes applied to source; not verified by build.*
