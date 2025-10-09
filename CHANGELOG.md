# Changelog

## [Unreleased]

### Added
- **LuaDoc Annotations**  
  - Added extensive type annotations for:
    - `MakefileVars`, `RootInfo`, `MarkerInfo`, `MarkerPair`, `TargetInfo`, etc.
  - Annotated functions with parameters and return types for better LSP support.

- **Bear Integration**  
  - Introduced a new module `lua/config/utils/make/modules/bear.lua`.
  - Added `Bear.Target` and `Bear.CurrentFile` functions to run Bear on
    specific targets or the current file.
  - Integrated Bear into `AddToMakefile`, `EditTarget`, and executable/object
    target generation.

### Changed
- Refactored `Generator.ExecutableTarget` to return `(lines, success)` consistently.
- Improved return values across `init.lua` functions to use boolean indicators.
- Enhanced error handling and user notifications during Makefile operations.

### Fixed
- Corrected minor inconsistencies in `RunTargetInSplit` and `Make` command handling.
- Fixed handling of build directory and relative paths in several generator and
  parser functions.

