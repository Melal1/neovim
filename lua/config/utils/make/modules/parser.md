# parser.lua

## Parser.SetCacheRoot(root_path, makefile_path)
Purpose: Set the cache context for parsing operations.
Inputs:
- `root_path` (string|nil): Project root path.
- `makefile_path` (string|nil): Makefile path.
Returns:
- None.
Side effects/notes:
- Updates `Parser.CacheRoot` and `Parser.CacheMakefilePath` when non-empty.
Example:
```lua
Parser.SetCacheRoot("/p/app", "/p/app/Makefile")
```

## cache_key_for(root_path)
Purpose: Convert a path into a filesystem-safe cache key.
Inputs:
- `root_path` (string|nil): Root path.
Returns:
- `string`: Normalized key used for cache filename.
Side effects/notes:
- Replaces separators and drive letters with safe characters.
Example:
```lua
local key = cache_key_for("/p/app")
```

## cache_file_for(root_path)
Purpose: Build the cache filename for a given root.
Inputs:
- `root_path` (string|nil): Root path.
Returns:
- `string`: Full path to cache file in `~/.cache/MakeNvim/`.
Example:
```lua
local path = cache_file_for("/p/app")
```

## log_cache(message)
Purpose: Emit a debug notification when cache logging is enabled.
Inputs:
- `message` (string): Message to show.
Returns:
- None.
Side effects/notes:
- Honors `Parser.CacheLog` flag.
Example:
```lua
log_cache("Cache miss")
```

## is_links_assignment_line(line)
Purpose: Detect lines assigning `LINKS` on a target.
Inputs:
- `line` (string): Line to test.
Returns:
- `boolean`: `true` when the line matches a `LINKS` assignment.
Example:
```lua
local ok = is_links_assignment_line("app: LINKS += -lm")
```

## search_flags_for(annotatedType)
Purpose: Determine which target types to search for based on a marker annotation.
Inputs:
- `annotatedType` (string|nil): `full`, `executable`, `obj`, or `run`.
Returns:
- `table`: Flags for `obj`, `executable`, and `run` searches.
Example:
```lua
local flags = search_flags_for("executable")
```

## read_makefile_content(makefile_path)
Purpose: Read Makefile content from disk if a path is provided.
Inputs:
- `makefile_path` (string|nil): Makefile path.
Returns:
- `string|nil`: Content or `nil` if missing.
Example:
```lua
local content = read_makefile_content("/p/app/Makefile")
```

## try_load_cache(root_path, makefile_path, content)
Purpose: Load cached section analysis when valid.
Inputs:
- `root_path` (string|nil): Root used for cache naming.
- `makefile_path` (string|nil): Makefile path for stat/hash validation.
- `content` (string|nil): Optional Makefile content for hashing.
Returns:
- `table|nil`: Cached sections, or `nil` if cache miss.
- `string|nil`: Computed hash (when applicable).
- `string`: Cache file path used.
Side effects/notes:
- Uses mtime/size checks first, then optional SHA256 hash.
Example:
```lua
local sections, hash, cache_file = try_load_cache("/p/app", "/p/app/Makefile", content)
```

## write_cache(cache_file, sections, makefile_path, content)
Purpose: Write section analysis to disk cache.
Inputs:
- `cache_file` (string): Cache path.
- `sections` (table): Parsed section analysis.
- `makefile_path` (string|nil): Makefile path for metadata.
- `content` (string|nil): Makefile content for hashing.
Returns:
- None.
Side effects/notes:
- Creates `~/.cache/MakeNvim` directory if needed.
Example:
```lua
write_cache(cache_file, sections, "/p/app/Makefile", content)
```

## Parser.ParseVariables(Content)
Purpose: Parse simple Makefile variable assignments into a table.
Inputs:
- `Content` (string|nil): Makefile content.
Returns:
- `table<string,string>`: Map of variable name to value.
Side effects/notes:
- Skips comments and empty lines.
- Supports `=` and `:=` assignments.
Example:
```lua
local vars = Parser.ParseVariables("CXX = g++\nBUILD_MODE := debug\n")
```

## Parser.FindMarker(Content, RelativePath, CheckStart, CheckEnd)
Purpose: Find marker start/end line numbers for a given file path.
Inputs:
- `Content` (string): Makefile content.
- `RelativePath` (string): Marker path.
- `CheckStart` (boolean): Whether to search for start marker.
- `CheckEnd` (boolean): Whether to search for end marker.
Returns:
- `MarkerInfo`: `{ M_start, M_end, type }`.
Side effects/notes:
- Reads line by line and extracts optional `type:` annotation.
Example:
```lua
local info = Parser.FindMarker(content, "./src/main.cpp", true, true)
```

## Parser.FindAllMarkerPairs(Content)
Purpose: Find all `marker_start`/`marker_end` pairs in the Makefile.
Inputs:
- `Content` (string|nil): Makefile content.
Returns:
- `MarkerPair[]`: Array of `{ path, StartLine, EndLine, annotatedType }`.
Example:
```lua
local pairs = Parser.FindAllMarkerPairs(content)
```

## Parser.ReadContentBetweenLines(Content, StartLine, EndLine, ReturnTable)
Purpose: Extract content between two line numbers.
Inputs:
- `Content` (string): Makefile content.
- `StartLine` (integer): Start line (exclusive).
- `EndLine` (integer): End line (exclusive).
- `ReturnTable` (boolean|nil): Return a table of lines if `true`.
Returns:
- `string|string[]`: Extracted content.
Example:
```lua
local block = Parser.ReadContentBetweenLines(content, 10, 20, false)
```

## Parser.ReadContentBetweenMarkers(Content, RelativePath, ReturnTable)
Purpose: Extract content between marker start/end for a specific path.
Inputs:
- `Content` (string): Makefile content.
- `RelativePath` (string): Marker path.
- `ReturnTable` (boolean|nil): Return table of lines if `true`.
Returns:
- `string|string[]`: Extracted section content.
Example:
```lua
local section = Parser.ReadContentBetweenMarkers(content, "./src/main.cpp")
```

## Parser.TargetExists(Content, RelativePath)
Purpose: Check whether a section exists for a given path.
Inputs:
- `Content` (string|nil): Makefile content.
- `RelativePath` (string): Marker path.
Returns:
- `boolean`: `true` if marker start exists.
Example:
```lua
if Parser.TargetExists(content, "./src/main.cpp") then ... end
```

## Parser.ParseDependencies(targetLine)
Purpose: Parse dependency tokens from a Makefile target line.
Inputs:
- `targetLine` (string): Line like `target: dep1 dep2`.
Returns:
- `string[]`: Dependency list.
Example:
```lua
local deps = Parser.ParseDependencies("app: main.o utils.o")
```

## Parser.FindExecutableTargetName(sectionContent, baseName)
Purpose: Find the best executable target name in a section.
Inputs:
- `sectionContent` (string): Section content.
- `baseName` (string|nil): Base name hint for matching.
Returns:
- `string|nil`: Target name or `nil` if not found.
Side effects/notes:
- Skips `LINKS` assignment lines and `.o` targets.
Example:
```lua
local name = Parser.FindExecutableTargetName(section, "main")
```

## Parser.GetLinksForTarget(sectionContent, targetName)
Purpose: Extract `LINKS` flags for a specific target.
Inputs:
- `sectionContent` (string): Section content.
- `targetName` (string): Target name.
Returns:
- `string[]`: Link flags.
Example:
```lua
local links = Parser.GetLinksForTarget(section, "./build/debug/main")
```

## Parser.ParseTarget(sectionContent, targetName)
Purpose: Parse a target block into dependencies and recipe lines.
Inputs:
- `sectionContent` (string): Section content.
- `targetName` (string): Target to parse.
Returns:
- `TargetInfo`: `{ name, dependencies, recipe, found }`.
Example:
```lua
local info = Parser.ParseTarget(section, "main")
```

## Parser.DetectTargetTypes(sectionContent, baseName, annotatedType)
Purpose: Detect whether a section contains obj, executable, and run targets.
Inputs:
- `sectionContent` (string): Section content.
- `baseName` (string|nil): Base name hint.
- `annotatedType` (string|nil): Expected type annotation.
Returns:
- `boolean hasObj`, `boolean hasExecutable`, `boolean hasRun`.
Example:
```lua
local hasObj, hasExe, hasRun = Parser.DetectTargetTypes(section, "main")
```

## Parser.AnalyzeSection(sectionContent, baseName, annotatedType)
Purpose: Analyze a single section and validate expected target types.
Inputs:
- `sectionContent` (string): Section content.
- `baseName` (string|nil): Base name hint.
- `annotatedType` (string|nil): Marker annotation type.
Returns:
- `SectionAnalysis`: Detailed target and type info.
Side effects/notes:
- Marks invalid sections and provides error messages.
Example:
```lua
local analysis = Parser.AnalyzeSection(section, "main", "full")
```

## Parser.AnalyzeAllSections(Content, opts)
Purpose: Analyze all marker sections and optionally use cached results.
Inputs:
- `Content` (string): Makefile content.
- `opts` (table|string|nil): Root and Makefile path hints.
Returns:
- `table[]`: Section analysis list.
Side effects/notes:
- Writes cache on successful parse.
Example:
```lua
local sections = Parser.AnalyzeAllSections(content, { root = "/p/app" })
```

## Parser.GetSectionsByType(Content, targetType)
Purpose: Filter analyzed sections by a target type.
Inputs:
- `Content` (string): Makefile content.
- `targetType` (string): `obj`, `executable`, `run`, or `full`.
Returns:
- `table[]`: Filtered sections.
Example:
```lua
local runSections = Parser.GetSectionsByType(content, "run")
```

## Parser.PrintAnalysisSummary(Content)
Purpose: Emit a human-readable summary of all sections via notifications.
Inputs:
- `Content` (string): Makefile content.
Returns:
- None.
Side effects/notes:
- Uses multiple `vim.notify` calls with summary lines.
Example:
```lua
Parser.PrintAnalysisSummary(content)
```

## Parser.HasReqVars(Content, MakefileVars)
Purpose: Check whether all required Makefile variables are present.
Inputs:
- `Content` (string|nil): Makefile content.
- `MakefileVars` (table): Required variable names.
Returns:
- `boolean`: `true` if all exist.
Example:
```lua
local ok = Parser.HasReqVars(content, cfg.MakefileVars)
```
