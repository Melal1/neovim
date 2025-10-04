# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Enhanced statusline with:
  - Mode indicator (NORMAL, INSERT, VISUAL, etc.) with custom highlights.
  - Git branch display.
  - Buffer flags (modified, readonly, unmodifiable).
  - Diagnostics (errors, warnings, hints, info).
  - DAP (debugging) component.
  - File path and name display with truncation for narrow windows.
  - Line and column number display.
- Randomized humorous Copilot names when attached to LSP.
- Keymap `<leader><leader>x` to:
  - Execute the current line in normal mode.
  - Execute selected lines in visual mode as Lua code.

### Changed
- Refactored `statusline.lua`:
  - Removed dependency on `lsp-progress.nvim`.
  - Dynamic truncation logic based on window width.
  - Consolidated LSP status, diagnostics, and file components.
- Updated colors and highlights for better visual distinction.

### Removed
- `plugins/lsp_progress.lua` plugin (deprecated).
- Old `mode_info` table and `lsp_progress_component()` in statusline.

