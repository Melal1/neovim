# CHANGELOG

## [Unreleased]

### Added

* **Feature: Safe Buffer Deletion**
    * Introduced `nvim-mini/mini.bufremove` for safe and controlled deletion of buffers.
    * New keymaps:
        * `<leader>bd` - Safely delete the current buffer.
        * `<leader>bD` - Force delete the current buffer (discarding changes).
* **Feature: Advanced Code Folding**
    * Added `kevinhwang91/nvim-ufo` (Unfold and Fold) plugin configuration in `lua/plugins/folds.lua`. This replaces the previous basic `ufo.lua` file.
    * Configured `treesitter` and `indent` as the primary fold providers for better structural folding.
    * Set up keymaps: `zR`, `zM`, `zr`, `zm`, and `zK` (peek fold).
* **Feature: Highlight on Yank**
    * Implemented an autocmd (`TextYankPost`) in `lua/config/init.lua` to briefly highlight text after a yank operation (`y`), improving visual feedback.
* **Feature: Treesitter Text Objects**
    * Added new `nvim-treesitter-textobjects` mappings for more precise code navigation and selection:
        * `ir`, `ar`: Inner/Around return statement.
        * `in`, `an`: Inner/Around number.
        * `io`, `ai`: Inner/Around loop statement.
        * `i-`, `a-`, `i=`, `a=`: Select Left/Right Hand Side of an assignment.
        * `ia`, `aa`: Inner/Around function parameter.
    * Added repeatable move mappings with `<leader>;` (repeat last move) and `<leader>,` (repeat opposite).
* **Configuration:**
    * Enabled `vim.opt.cursorline` and set `vim.opt.cursorlineopt = "number"` for better line focus.
    * Configured `shada` with `'100,<50,s10,h` for persistent session history.
    * Added `dstein64/vim-startuptime` plugin, accessible via `:StartupTime`.

### Changed

* **Plugin Cleanup and Optimization**
    * Removed obsolete plugins: `nvim-lualine/lualine.nvim` and `echasnovski/mini.files`.
    * Migrated the `nvim-ufo` config from `lua/plugins/ufo.lua` to the new `lua/plugins/folds.lua`.
    * Optimized lazy-loading events for several plugins (`comment.nvim`, `oil-git.nvim`, `oil-lsp-diagnostics.nvim`, `lsp-progress.nvim`, `telescope.nvim`, `nvim-surround`).
    * Set `nvim-treesitter` to be non-lazy loaded (`lazy = false`) for immediate availability, and added an autocmd to ensure highlighting is always tried.
* **C++ & Makefile Utility Improvements**
    * Added `remove` to the command completion list for the `RunMake` user command in `lua/config/usrcmd/cpp.lua`.
    * Removed excessive `vim.notify` and `print` calls from the Makefile utilities (`lua/config/utils/make/init.lua`, `lua/config/utils/make/finder.lua`, `lua/config/utils/make/parser.lua`) for a quieter user experience.
    * Updated `RunMake` to handle the new `remove` argument.

### Removed

* Removed the old, manual `<leader>bd` keymap for buffer deletion in `lua/core/keymaps.lua` in favor of `mini.bufremove`.
* Removed `lua/plugins/lualine.lua` (switched to a different statusline setup).
* Removed `lua/plugins/mini-files.lua`.
* Removed `lua/plugins/ufo.lua`.
