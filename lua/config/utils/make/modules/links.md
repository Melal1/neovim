# links.lua

## get_picker_or_warn(message)
Purpose: Return the picker module or warn when unavailable.
Inputs:
- `message` (string|nil): Error message to display.
Returns:
- `picker` (table|nil): Picker module or `nil`.
Side effects/notes:
- Uses `Utils.Notify` to report errors.
Example:
```lua
local picker = get_picker_or_warn("Picker required")
```

## normalize_link_flags(flags)
Purpose: Normalize and deduplicate link flags.
Inputs:
- `flags` (string[]|nil): Raw flags.
Returns:
- `string[]`: Unique, non-empty flags in order.
Side effects/notes:
- Preserves original order of first occurrence.
Example:
```lua
local out = normalize_link_flags({ "-lm", "-lm", "" })
```

## merge_link_flags(existing, incoming, action)
Purpose: Add or remove flags from an existing list.
Inputs:
- `existing` (string[]|nil): Current flags.
- `incoming` (string[]|nil): Flags to add/remove.
- `action` (string): `"add"` or `"remove"`.
Returns:
- `string[]`: Updated flag list.
Example:
```lua
local flags = merge_link_flags({"-lm"}, {"-lpthread"}, "add")
```

## parse_links_block(content)
Purpose: Parse the `# links_start` / `# links_end` block in a Makefile.
Inputs:
- `content` (string|nil): Makefile content.
Returns:
- `groups` (table[]): List of `{ name, flags }`.
- `individuals` (string[]): Link flags not part of groups.
Side effects/notes:
- Filters individual flags that are already part of a group.
Example:
```lua
local groups, individuals = parse_links_block(content)
```

## build_links_block(groups, individuals)
Purpose: Build a links block from groups and individual flags.
Inputs:
- `groups` (table[]): Group definitions.
- `individuals` (string[]): Individual flags.
Returns:
- `string[]`: Lines for the links block.
Example:
```lua
local lines = build_links_block({{ name = "math", flags = {"-lm"} }}, {"-lpthread"})
```

## apply_links_block(content, groups, individuals)
Purpose: Insert, update, or remove the links block in a Makefile.
Inputs:
- `content` (string|nil): Makefile content.
- `groups` (table[]): Group definitions.
- `individuals` (string[]): Individual flags.
Returns:
- `string`: Updated Makefile content.
Side effects/notes:
- Removes the block entirely if no links remain.
Example:
```lua
local new_content = apply_links_block(content, groups, individuals)
```

## build_link_entries(makefile_content)
Purpose: Build picker entries for link selection.
Inputs:
- `makefile_content` (string): Makefile content.
Returns:
- `entries` (table[]): Picker items with `value` and `display`.
- `flags_by_value` (table): Map from entry value to flags.
- `all_flags` (string[]): Deduped list of all flags.
Example:
```lua
local entries, map, all = build_link_entries(content)
```

## confirm_action(message)
Purpose: Ask the user for confirmation.
Inputs:
- `message` (string): Prompt message.
Returns:
- `boolean`: `true` when user confirms.
Example:
```lua
if not confirm_action("Proceed?") then return end
```

## normalize_link_input(flag)
Purpose: Normalize a single link flag string.
Inputs:
- `flag` (string): Raw flag, possibly without leading `-`.
Returns:
- `string|nil`: Normalized flag, or `nil` if empty.
Example:
```lua
local f = normalize_link_input("lm")
-- f == "-lm"
```

## parse_links_input(prompt)
Purpose: Read and normalize link flags from user input.
Inputs:
- `prompt` (string): Prompt message.
Returns:
- `string[]`: Deduped normalized flags.
Example:
```lua
local flags = parse_links_input("Enter flags: ")
```

## format_link_options(groups, individuals)
Purpose: Create display lines for link groups and individual flags.
Inputs:
- `groups` (table[]): Group list.
- `individuals` (string[]): Individual flags.
Returns:
- `string[]`: Formatted lines for display.
Example:
```lua
local lines = format_link_options(groups, individuals)
```

## build_preselected_link_values(entries, flags_by_value, existing_flags)
Purpose: Determine which entries should be preselected based on existing flags.
Inputs:
- `entries` (table[]): Picker entries.
- `flags_by_value` (table): Map from entry to flags.
- `existing_flags` (string[]): Current flags.
Returns:
- `string[]`: Entry values to preselect.
Example:
```lua
local pre = build_preselected_link_values(entries, map, {"-lm"})
```

## update_section_links(section_lines, target_name, links)
Purpose: Insert, update, or remove a `LINKS` line for a target in a section.
Inputs:
- `section_lines` (string[]): Section lines.
- `target_name` (string): Target to update.
- `links` (string[]): Link flags.
Returns:
- `string[]`: Updated section lines.
Example:
```lua
local out = update_section_links(lines, "app", {"-lm"})
```

## manage_link_options_add(picker, makefile_path, makefile_content)
Purpose: Interactive flow to add link groups or individual flags.
Inputs:
- `picker` (table): Picker module.
- `makefile_path` (string): Makefile path.
- `makefile_content` (string): Current content.
Returns:
- None.
Side effects/notes:
- Prompts for group names, flags, and confirmation.
Example:
```lua
manage_link_options_add(picker, path, content)
```

## manage_link_options_list(makefile_path, makefile_content)
Purpose: Display all link options in a notification.
Inputs:
- `makefile_path` (string): Makefile path.
- `makefile_content` (string): Current content.
Returns:
- None.
Example:
```lua
manage_link_options_list(path, content)
```

## manage_link_options_remove(picker, makefile_path, makefile_content)
Purpose: Interactive flow to remove groups or individual link flags.
Inputs:
- `picker` (table): Picker module.
- `makefile_path` (string): Makefile path.
- `makefile_content` (string): Current content.
Returns:
- None.
Side effects/notes:
- Supports removing entire groups or specific flags from a group.
Example:
```lua
manage_link_options_remove(picker, path, content)
```

## manage_link_options_edit(picker, makefile_path, makefile_content)
Purpose: Interactive flow to rename or modify a link group.
Inputs:
- `picker` (table): Picker module.
- `makefile_path` (string): Makefile path.
- `makefile_content` (string): Current content.
Returns:
- None.
Example:
```lua
manage_link_options_edit(picker, path, content)
```

## M.ParseLinksBlock(content)
Purpose: Public wrapper to parse link groups and individuals.
Inputs:
- `content` (string|nil): Makefile content.
Returns:
- `groups` (table[]), `individuals` (string[]).
Example:
```lua
local groups, individuals = M.ParseLinksBlock(content)
```

## M.HasLinkOptions(content)
Purpose: Check whether any link options exist in the Makefile.
Inputs:
- `content` (string|nil): Makefile content.
Returns:
- `boolean`: `true` if groups or individual flags exist.
Example:
```lua
if M.HasLinkOptions(content) then ... end
```

## M.LoadLinkOptions(makefile_path, fallback_content)
Purpose: Load link options from disk (or use fallback content).
Inputs:
- `makefile_path` (string|nil): Makefile path.
- `fallback_content` (string|nil): Content to use if file missing.
Returns:
- `content` (string): Makefile content used.
- `groups` (table[]): Group list.
- `individuals` (string[]): Individual flags.
Example:
```lua
local content, groups, individuals = M.LoadLinkOptions(path, content)
```

## M.SaveLinkOptions(makefile_path, content, groups, individuals)
Purpose: Save updated link options back into the Makefile content.
Inputs:
- `makefile_path` (string): Makefile path.
- `content` (string): Existing Makefile content.
- `groups` (table[]): Group list.
- `individuals` (string[]): Individual flags.
Returns:
- `boolean`: `true` on success.
- `string|nil`: Updated content (or error message on failure).
Example:
```lua
local ok, new_content = M.SaveLinkOptions(path, content, groups, individuals)
```

## M.SelectLinks(existing_flags, makefile_content, callback, opts)
Purpose: Let the user pick link flags from the links block.
Inputs:
- `existing_flags` (string[]|nil): Preselected flags.
- `makefile_content` (string): Makefile content.
- `callback` (function): Receives final flag list.
- `opts` (table|nil): Picker options (`prompt_title`, `preselect`).
Returns:
- `boolean`: `true` if flow started, `false` on picker error.
Side effects/notes:
- Supports an "All" entry to select all flags.
Example:
```lua
M.SelectLinks({"-lm"}, content, function(flags) print(vim.inspect(flags)) end)
```

## M.GetExistingLinks(content, relative_path, base_name)
Purpose: Extract existing link flags for a given target section.
Inputs:
- `content` (string): Makefile content.
- `relative_path` (string): Marker path.
- `base_name` (string): Base name for target matching.
Returns:
- `string[]`: Existing link flags.
Example:
```lua
local links = M.GetExistingLinks(content, "./src/main.cpp", "main")
```

## M.UpdateLinksForEntry(content, relative_path, base_name, new_links)
Purpose: Update or remove a target's `LINKS` assignment within a marker section.
Inputs:
- `content` (string): Makefile content.
- `relative_path` (string): Marker path.
- `base_name` (string): Base name for matching.
- `new_links` (string[]): New link flags.
Returns:
- `string|nil`: Updated content or `nil` on error.
Example:
```lua
local updated = M.UpdateLinksForEntry(content, "./src/main.cpp", "main", {"-lm"})
```

## M.ManageInteractive(makefile_path, makefile_content)
Purpose: Open the interactive menu for link management.
Inputs:
- `makefile_path` (string): Makefile path.
- `makefile_content` (string): Current content.
Returns:
- `boolean`: `true` when menu opens, `false` on error.
Example:
```lua
M.ManageInteractive(path, content)
```
