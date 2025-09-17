## [Unreleased]

### Added
- Toggle for `clang-tidy` in `clangd` LSP configuration, including custom
  checks and automatic server restart.
- `ToggleInlayHints` and `ToggleTidy` commands for easier developer workflow.
- Helper functions in `cpp.lua`:
  - `get_source_files()` to collect `.c`/`.cpp` files from `src`.
  - `format_sources_for_cmake()` to prepare paths for CMakeLists.
  - `get_existing_sources()` to parse existing sources in CMake.

### Changed
- Refactored C++ user commands:
  - Introduced constants for project structure (e.g. `CMAKE_DIR`, `CMAKE_FILE`).
  - Improved code organization for better maintainability.

### Fixed
- `.gitignore` now excludes `gitcommit.sh`.

---

