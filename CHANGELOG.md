## [Unreleased]

### Added
- **BearAll target**: Introduced a new menu action for C++ projects that allows selecting multiple Makefile targets through Telescope and running `bear` on them asynchronously. This is useful for generating compilation databases for multiple targets quickly.

### Changed
- **Bear execution**: Replaced all blocking `vim.fn.system()` calls with non-blocking `vim.system()` for bear commands. This prevents the Neovim UI from freezing during long bear runs and provides clear notifications when the process finishes or fails.
- **Utils.GetRelativePath**: Now returns `(result, ok)` instead of `(result, err)`. All relevant code was updated to reflect this new interface.
- **Debug runner**: Added early returns when tmux is unavailable or filetype lacks a debug config, improving error reporting.

### Improved
- **Picker utilities**: Added type annotations for Telescope entries and options, restructured code for clarity, and improved preview handling for multi-entry pickers.
- **Make module**: Cleaned up error handling in `AddToMakefile`, `EditTarget`, and `Remove`.

### Removed
- **Keymaps**: Removed unused experimental `<leader>rm` mapping from `core/keymaps.lua`.

### Breaking Changes
- `Utils.GetRelativePath` no longer returns `(path, err)` but `(pathOrErrMsg, ok)`. Call sites must check the boolean flag instead of relying on a `nil` error.

