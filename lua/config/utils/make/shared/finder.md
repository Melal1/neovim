# finder.lua

## Finder.FindRoot(StartingPoint, MaxSearchLevels, RootMarkers)
Purpose: Walk upward from a starting directory to locate a project root using marker files or directories.
Inputs:
- `StartingPoint` (string|nil): Directory to start from. Defaults to current buffer directory.
- `MaxSearchLevels` (integer|nil): Maximum parent levels to traverse. Default is 5.
- `RootMarkers` (string[]|nil): Marker names like `.git`, `Makefile`, `src`.
Returns:
- `RootInfo` (table|nil): `{ Path, Marker, Level }` when found.
- `err` (string|nil): Error text when not found.
Side effects/notes:
- Uses `vim.loop.fs_stat` to detect markers.
- Stops when reaching filesystem root or max levels.
Example:
```lua
local Finder = require("config.utils.make.shared.finder")
local root, err = Finder.FindRoot(nil, 6, { ".git", "Makefile" })
if root then
  print(root.Path)
else
  print(err)
end
```

## Finder.FindHeaderDirectory(Basename, RootPath)
Purpose: Find the directory containing a header file named `<Basename>.h`.
Inputs:
- `Basename` (string): Header base name without extension.
- `RootPath` (string): Root directory to search.
Returns:
- `string|nil`: Directory containing the header, relative to root when possible.
Side effects/notes:
- Uses a `find` shell command; can be slow on large trees.
- Returns only the first match.
Example:
```lua
local dir = Finder.FindHeaderDirectory("utils", "/p/app")
-- Possible result: "./include" or "/p/app/include"
```
