### Feat
- **Debug/Release Build Support:** Introduced explicit `DEBUGFLAGS` and `RELEASEFLAGS` in the configuration. The default `CXXFLAGS` is now set to use `$(DEBUGFLAGS)` for easier switching between debug (`-g -O0`) and release (`-O3 -DNDEBUG`) builds.
- **Makefile Target Type Annotation:** Target generation now includes a **`type:` annotation** in the start marker (e.g., `# marker_start: path type:obj`) to improve target parsing and validation logic.
- **Makefile Analysis Command:** Added a new command **`:Make analysis`** to print a summary of all parsed Makefile sections, including their inferred and annotated types, for easier debugging and verification.
- **Refactor `Make` Commands and Keymaps**
    - The `RunMake` user command has been **renamed to `Make`** for a cleaner and more direct API.
    - All related keymaps, including `<leader>rm` (Add to Makefile) and `<leader>rf` (Run Target) in C++ files, and the global `<leader>rm` (Add/Run), have been updated to use the new `:Make` command.
    - **Enhanced Run Options:** The **`:Make run`** command now accepts a second argument to specify the terminal window for execution: `split` (default), `float`, or `tab`.

---

### Changed
- **Improved Target Generation:** Refactored Makefile target generation in `generator.lua` to use idiomatic Makefile **automatic variables** (`$<`, `$@`) and explicitly prefix all generated object and executable names with `$(BUILD_DIR)/` for consistent build output.
- **Refined Target Parsing:** The internal parser logic has been significantly updated to leverage target type annotations and provide more robust detection and validation of object (`obj`), executable, and full targets.
- **Enhanced Target Picking:** The list of object files presented for dependency selection when creating an executable is now more user-friendly, displaying the **base filename** instead of the full target name.
- **Simplified Target Existance Check:** Simplified the function for checking if a target exists (`TargetExists`) by keying off the source file's relative path marker.
- **Improved Terminal Execution:** Execution logic was updated to use **`toggleTerm.run_cmd`**, allowing multiple commands (like `cd` and `make`) to be sent sequentially to the terminal buffer for a cleaner run environment.

---

### Fix
- **Improved Notification Readability**
    - Added leading newline characters (`\n`) to `vim.notify` calls within `M.AddToMakefile` to ensure the notification output is separated from the input prompt (e.g., "Target type [o/e]:") for better user experience.
