## [Unreleased] - YYYY-MM-DD

### Added
- `toggleTerm.SingleShot(cmd, height)` function to run a single shell command in a temporary split.
- Treesitter autocmd delayed by 50ms for safer initialization.
- Statusline displays shell name for terminal buffers.

### Changed
- Statusline background set to transparent (`guibg=NONE`) for normal and terminal buffers.
- `MakeTarget` runner now uses `SingleShot` instead of `run_cmd` for better terminal integration.
- Terminal creation no longer redundantly specifies the shell.
- Treesitter plugin now lazy-loads on `BufRead` and `BufNew` events.
- Telescope plugin no longer triggers on `BufReadPost` to improve startup speed.

### Fixed
- Terminal buffers now correctly avoid filepath component in statusline.

