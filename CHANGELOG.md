# Changelog

## [Unreleased]

### Added
- New `:CmakeDelete` command to remove `CMakeLists.txt` and `cmake/` build directory
- `utils/pick.lua`: Telescope-based multi-file picker (used in `:CmakeSetup`)
- Automatic `.clangd` generation during project setup
- New cpp.lua commands:
  - `:CmakeSetup` (scaffold project with std selection & file picking)
  - `:CmakeAddFile` (add current file to sources)
  - `:CmakeAddAll` (add all new .cpp/.c files to sources)
  - `:CmakeClean` (remove missing files from sources)
- Blink.nvim enhancements:
  - Command-line ghost text
  - New cmdline keymaps:
    - `<C-y>` → cancel
    - `<C-e>` → select and accept

### Changed
- CMake workflow refactored:
  - Added project root detection (`src`, `include`, `.git`)
  - `:CmakeSetup` now confirms project root and supports manual
    file selection via Telescope
  - Automatically runs cmake after modifying sources
- Blink.nvim completion UI now displays in columns:
  - (kind_icon, kind) and (label, label_description)

### Fixed
- `:CmakeClean` now correctly removes missing files from sources

