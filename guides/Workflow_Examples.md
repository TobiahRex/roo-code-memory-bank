# Memory Bank Manager Workflow Guide

This guide demonstrates common workflow patterns using the Memory Bank Manager alongside typical Git commands. The Memory Bank Manager helps maintain context across different branches by storing and managing AI memory banks.

## 1. Checking Out a Branch

When switching between branches, the Memory Bank Manager automatically handles memory bank synchronization through Git hooks.

```bash
# Check current branch and memory bank status
git branch
mb status

# Save current memory bank state (optional, but recommended)
mb sync

# Switch to an existing branch
git checkout feature-branch

# The memory bank is automatically switched via post-checkout hook
# You can verify the memory bank status
mb status
```

**What happens behind the scenes:**
1. The `pre-checkout` hook saves your current memory bank to the central location
2. Git performs the branch checkout
3. The `post-checkout` hook loads the appropriate memory bank for the target branch
4. If no memory bank exists for the target branch, it either creates a new one or copies from the parent branch

## 2. Initializing the Memory Bank Feature

When starting to use the Memory Bank Manager in a project for the first time:

```bash
# Navigate to your project
cd /path/to/your/project

# Check the status (will show if memory bank exists)
mb status

# Initialize a new memory bank for the current branch
mb create

# Verify the memory bank was created
mb status
```

**What happens behind the scenes:**
1. The `mb create` command:
   - Detects your project domain, name, and current branch
   - Creates a central memory bank at `~/code/ai-memory-banks/<domain>/<project>/<branch>`
   - Creates a local memory bank in your project at `./memory-bank/`
   - Adds `/memory-bank` to your `.gitignore` file to prevent committing it

## 3. Saving the Memory Bank State as a Precaution

Before making significant changes or when you want to ensure your memory bank is backed up:

```bash
# Check current memory bank status
mb status

# Synchronize memory bank (both to and from central storage)
mb sync

# For a more targeted approach, you can sync only to central storage
# This is useful when you want to ensure your changes are backed up
# without potentially overwriting local changes
mb sync-to-central  # Note: This is achieved via internal function calls
```

**What happens behind the scenes:**
1. The `mb sync` command:
   - Copies files from your local `./memory-bank/` to the central location
   - Copies files from the central location back to your local `./memory-bank/`
   - Ensures both locations have the most up-to-date content

## 4. Making a Git Commit with the Latest Diff, Then Checking Out a New Branch

When you want to commit changes and create a new branch with the memory bank context:

```bash
# Make sure your memory bank is up to date
mb sync

# Stage and commit your changes
git add .
git commit -m "Implement feature X"

# Create and checkout a new branch
git checkout -b new-feature-branch

# The memory bank is automatically handled:
# - pre-checkout saves the current memory bank
# - post-checkout creates a new memory bank for the new branch
# - the new memory bank inherits content from the parent branch

# Verify the new memory bank
mb status
```

**What happens behind the scenes:**
1. The `mb sync` ensures your memory bank is up to date
2. Git commits your changes
3. When creating a new branch:
   - The `pre-checkout` hook saves the current branch's memory bank
   - Git creates and switches to the new branch
   - The `post-checkout` hook detects this is a new branch
   - It copies the memory bank from the parent branch to the new branch
   - It adds a note about branch lineage to the `activeContext.md` file

## Additional Useful Commands

```bash
# List all memory banks for the current project
mb list

# Merge memory bank from another branch into current branch
mb merge source-branch

# Archive a branch's memory bank (useful before deleting branches)
mb archive branch-to-archive

# Check if memory bank is properly gitignored
mb check

# Fix gitignore settings if needed
mb fix-gitignore

# Display help information
mb help
```

## Memory Bank Integration with Git Workflow

The Memory Bank Manager integrates with Git through hooks:

- `pre-checkout`: Saves the current memory bank before switching branches
- `post-checkout`: Loads the appropriate memory bank after switching branches
- `post-merge`: Updates the memory bank after merging branches
- `post-rebase`: Updates the memory bank after rebasing

This ensures your AI context is always synchronized with your Git workflow, maintaining continuity as you work across different branches and features.