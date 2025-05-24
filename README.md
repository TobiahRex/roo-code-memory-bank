# Roo Code Memory Bank Manager

A system for managing personalized Roo Code Memory Banks across different projects and git branches without version controlling them.

## Features

- Stores memory banks outside project directories in a centralized local location
- Automatically detects current project and git branch
- Copies the appropriate memory bank into the project root when switching contexts
- Ensures memory banks are properly gitignored
- Supports workflows for creating, switching, backing up, and synchronizing memory banks
- Handles edge cases like new branches or projects
- Implements an effective naming convention for memory banks
- Supports advanced git workflows including rebasing and branch chaining
- Automatically handles memory bank inheritance in branch chains
- Properly merges memory banks during rebase operations

## Directory Structure

The system uses the following directory structure for centralized memory bank storage:

```
~/code/ai-memory-banks/
├── david/
│   ├── project1/
│   │   ├── main/
│   │   │   ├── activeContext.md
│   │   │   ├── productContext.md
│   │   │   ├── progress.md
│   │   │   ├── decisionLog.md
│   │   │   └── systemPatterns.md
│   │   └── feature-branch/
│   │       └── ...
│   └── project2/
│       └── ...
├── gather/
│   └── ...
├── me/
│   └── ...
├── play/
│   └── ...
├── stitch/
│   └── ...
└── world/
    └── ...
```

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/roo-code-memory-bank-manager.git
   cd roo-code-memory-bank-manager
   ```

2. Run the installation script:
   ```bash
   chmod +x install_memory_bank_manager.sh
   ./install_memory_bank_manager.sh
   ```

3. Source your ~/.zshrc or restart your terminal:
   ```bash
   source ~/.zshrc
   ```

4. Navigate to a project and create your first memory bank:
   ```bash
   cd ~/path/to/your/project
   mb create
   ```

## Usage

The memory bank manager provides a command-line interface through the `mb` command:

### Basic Commands

- `mb` - Show status of the current memory bank
- `mb create` - Create a new memory bank for the current project and branch
- `mb switch [branch]` - Switch to a different branch's memory bank
- `mb sync` - Synchronize the project and central memory banks
- `mb list` - List available memory banks for the current project

### Advanced Commands

- `mb archive [branch]` - Archive a branch's memory bank
- `mb merge <branch>` - Merge a branch's memory bank into the current branch
- `mb rebase <branch>` - Rebase current memory bank on top of another branch's memory bank
- `mb check` - Check if the memory bank is properly gitignored
- `mb fix-gitignore` - Fix gitignore settings
- `mb help` - Show help information

## Automatic Operation

The system automatically:

1. Saves the current memory bank before switching branches
2. Loads the appropriate memory bank after switching branches
3. Updates the memory bank after merging branches
4. Handles memory bank inheritance when creating new branches (branch chaining)
5. Merges memory banks appropriately during rebase operations
6. Ensures memory banks are properly gitignored

## Privacy and Version Control

The memory bank management system is designed to remain private and not get tracked in version control:

- All implementation code lives in ~/.zshrc or other user-level configuration files
- Git hooks are configured at the user level, not the repository level
- The memory-bank directory is automatically added to .gitignore
- A global gitignore rule is added as a fallback

## Troubleshooting

### Memory Bank Not Found

If you get a "Memory bank not found" error:

1. Check if you're in a git repository
2. Verify that the memory bank exists in the central location
3. Run `mb create` to create a new memory bank

### Git Hooks Not Working

If git hooks are not working:

1. Check if the hooks are executable: `ls -la ~/.git-hooks`
2. Verify that git is using the custom hooks directory: `git config --get core.hooksPath`
3. Try running the hooks manually: `~/.git-hooks/post-checkout`
4. Verify that all hooks are installed: `ls -la ~/.git-hooks` should show pre-checkout, post-checkout, post-merge, and post-rebase

### Memory Bank Not Gitignored

If your memory bank is not being gitignored:

1. Run `mb check` to verify gitignore status
2. Run `mb fix-gitignore` to fix gitignore settings

## License

MIT
