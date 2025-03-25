# Neovim Configuration for NixOS

- This is my Neovim setup tailored for NixOS. I plan to revisit and refine every plugin during my free time.
## Configuration Structure
```
├── init.lua                    # Entry point for Neovim configuration
├── lazy-lock.json              # Lockfile for Lazy.nvim plugin versions
└── lua                         # Core Lua configuration directory
    ├── config                  # General configuration files
    │   ├── lazy.lua            # Lazy.nvim plugin manager setup
    │   ├── mappings.lua        # Core keybindings and custom functions
    │   ├── settings.lua        # Global Neovim settings
    │   ├── Snippets            # Custom snippet definitions
    │   │   ├── init.lua        # Snippet initialization
    │   │   └── simple.lua      # Basic custom snippets
    │   └── utils.lua           # Utility functions and helpers
    ├── harpoon.lua             # Harpoon config (broken after update; reinstall pending)
    └── plugins                 # Plugin-specific configurations
        ├── alpha.lua           # Startup dashboard customization
        ├── autopair.lua        # Auto-pairing (planning switch to mini.pairs)
        ├── coderunner.lua      # Code execution (considering Overseer migration)
        ├── color.lua           # Color scheme utilities
        ├── completions.lua     # Autocompletion setup
        ├── copilot.lua         # Copilot config (restricted in my country; seeking alternatives)
        ├── debugger.lua        # Debugging tools (currently disabled)
        ├── flash.lua           # Enhanced navigation
        ├── git.lua             # Git integration
        ├── indent.lua          # Indentation guides
        ├── lsp-config.lua      # Language server protocol configuration
        ├── lualine.lua         # Statusline customization
        ├── markdown.lua        # Markdown enhancements
        ├── mini-ai.lua         # Mini.ai for better text objects
        ├── neo-tree.lua        # File explorer
        ├── none-ls.lua         # Formatting and diagnostics
        ├── oil-gx.lua          # Oil.nvim file manager
        ├── session-manager.lua # Session management
        ├── surround.lua        # Surround text editing
        ├── telescope.lua       # Fuzzy finder (more extensions planned)
        ├── theme.lua           # Theme configuration
        ├── tmuxnav.lua         # Tmux navigation integration
        ├── todo.lua            # Todo comment highlighting
        ├── treejs.lua          # Treesitter-based JS enhancements (disabled)
        ├── treesitter.lua      # Treesitter syntax highlighting
        └── undotree.lua        # Undo history visualization
```
## Notes

- Plugins marked as "disabled" (e.g., debugger.lua, treejs.lua) are currently inactive but retained for future use.
- Keybindings for most plugins are defined within their respective configuration files for better modularity and organization.
## TODO List

- [ ] Transition select plugins to mini.nvim alternatives (e.g., autopair.lua → mini.pairs).
- [ ] Enhance plugins/alpha.lua: Improve headers and color scheme.
- [ ] Reinstall and configure Harpoon V2 after recent update issues.
- [ ] Optimize performance (e.g., lazy-loading, reduce plugin overhead).
- [ ] Explore Copilot alternatives due to regional restrictions.
- [ ] Evaluate coderunner.lua replacement with Overseer.nvim.
- [ ] Expand telescope.lua with additional extensions.


