# actions.lua

## M.AddToMakefile(MakefilePath, FilePath, RootPath, Content, BypassCheck, Config)
Purpose: Add a new Makefile target block for the current source file (object or executable).
Inputs:
- `MakefilePath` (string): Path to Makefile.
- `FilePath` (string): Absolute path to the source file.
- `RootPath` (string): Project root path.
- `Content` (string): Current Makefile content.
- `BypassCheck` (boolean|nil): When `true`, skips source-extension validation.
- `Config` (table|nil): Config values (source extensions, Makefile vars).
Returns:
- `boolean`: `true` when a target was added, otherwise `false`.
Side effects/notes:
- Prompts for target type (object vs executable).
- Writes new target lines to the Makefile.
- For executable targets, prompts for dependencies and link flags.
- For object targets, can trigger Bear to update compile_commands.
Example:
```lua
local ok = M.AddToMakefile("/p/app/Makefile", "/p/app/src/main.cpp", "/p/app", content, false, cfg)
```

## M.EditTarget(MakefilePath, FilePath, RootPath, Content, Entries, callback, Config)
Purpose: Rebuild the Makefile section for a specific executable target with new deps/links.
Inputs:
- `MakefilePath` (string): Path to Makefile.
- `FilePath` (string): Target source file path.
- `RootPath` (string): Project root.
- `Content` (string): Makefile content.
- `Entries` (table[]|nil): Precomputed section entries (optional).
- `callback` (function|nil): Called with success status.
- `Config` (table|nil): Config values.
Returns:
- `boolean`: `true` if flow started, `false` on error.
Side effects/notes:
- Opens pickers to select object dependencies and link flags.
- Replaces the entire marker section for the target.
Example:
```lua
M.EditTarget("/p/app/Makefile", "/p/app/src/main.cpp", "/p/app", content, nil, nil, cfg)
```

## M.EditAllTargets(MakefilePath, RootPath, Content, Config)
Purpose: Let the user pick any executable target and edit it.
Inputs:
- `MakefilePath` (string): Path to Makefile.
- `RootPath` (string): Project root.
- `Content` (string): Makefile content.
- `Config` (table|nil): Config values.
Returns:
- `boolean`: `true` if picker opens, `false` on error.
Side effects/notes:
- Uses a picker to select one target.
- Calls `M.EditTarget` with the selected entry.
Example:
```lua
M.EditAllTargets("/p/app/Makefile", "/p/app", content, cfg)
```

## M.Remove(MakefilePath, Content)
Purpose: Remove selected target sections (marker blocks) from the Makefile.
Inputs:
- `MakefilePath` (string): Path to Makefile.
- `Content` (string): Makefile content.
Returns:
- `boolean`: `true` if picker opens, `false` on error.
Side effects/notes:
- Uses picker with previews to select multiple sections.
- Rewrites the Makefile without selected blocks.
Example:
```lua
M.Remove("/p/app/Makefile", content)
```

## M.PickAndAdd(RootPath, Content)
Purpose: Show a picker of source files (currently `.cpp`) and allow adding targets.
Inputs:
- `RootPath` (string): Project root.
- `Content` (string): Makefile content (unused currently).
Returns:
- `boolean`: `true` if picker opens, `false` on error.
Side effects/notes:
- Currently only searches `*.cpp` files.
- Selection callback is a stub (no action yet).
Example:
```lua
M.PickAndAdd("/p/app", content)
```
