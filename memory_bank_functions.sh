#!/bin/zsh
# Memory Bank Manager Functions
# These functions manage Roo Code Memory Banks across different projects and git branches

# Project Detection Functions

# Detect the current project root directory
function get_project_root() {
  # Try git root first
  local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$git_root" ]]; then
    echo "$git_root"
    return 0
  fi
  
  # Try finding common project files
  local current_dir="$PWD"
  while [[ "$current_dir" != "/" ]]; do
    # Check for package.json (Node.js)
    if [[ -f "$current_dir/package.json" ]]; then
      echo "$current_dir"
      return 0
    fi
    
    # Check for Cargo.toml (Rust)
    if [[ -f "$current_dir/Cargo.toml" ]]; then
      echo "$current_dir"
      return 0
    fi
    
    # Check for pom.xml (Java/Maven)
    if [[ -f "$current_dir/pom.xml" ]]; then
      echo "$current_dir"
      return 0
    fi
    
    # Check for .xcodeproj (iOS/macOS)
    if [[ -d "$current_dir/"*.xcodeproj ]]; then
      echo "$current_dir"
      return 0
    fi
    
    # Move up one directory
    current_dir=$(dirname "$current_dir")
  done
  
  # Fall back to current directory
  echo "$PWD"
}

# Extract domain from project path
function get_project_domain() {
  local project_root="$1"
  
  # Convert to absolute path if it's a relative path
  if [[ ! "$project_root" = /* ]]; then
    project_root="$PWD/$project_root"
  fi
  
  # Replace $HOME with ~ for consistent matching
  project_root="${project_root/#$HOME/~}"
  
  # Extract domain based on path structure
  if [[ "$project_root" =~ ~/code/domains/([^/]+) ]]; then
    echo "${BASH_REMATCH[1]}"
  elif [[ "$project_root" =~ ~/code/([^/]+)/([^/]+) ]]; then
    # For existing structure before migration
    echo "${BASH_REMATCH[1]}"
  elif [[ "$project_root" =~ (/private)?/var/folders/.*/T/tmp\. ]]; then
    # Handle temporary directories
    # Extract the project name from the path (last component)
    local project_name=$(basename "$project_root")
    # Use a special domain for temporary projects
    echo "temp"
  else
    # Try to extract domain from parent folder of project path
    local parent_dir=$(dirname "$project_root")
    local domain_name=$(basename "$parent_dir")
    
    # Check if we have a valid domain name (not root or other special directories)
    if [[ "$domain_name" != "/" && "$domain_name" != "." && "$domain_name" != ".." && "$domain_name" != "T" ]]; then
      echo "$domain_name"
    else
      # Default domain if all extraction attempts fail
      echo "unknown"
    fi
  fi
}

# Extract project name from path
function get_project_name() {
  local project_root="$1"
  echo "$(basename "$project_root")"
}

# Get current git branch
function get_git_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "default"
}

# Memory Bank Path Functions

# Get path to central memory bank
function get_central_mb_path() {
  local domain="$1"
  local project="$2"
  local branch="$3"
  
  # Expand ~ to $HOME for consistent path handling
  local path="$HOME/code/ai-memory-banks/$domain/$project"
  
  # If branch is provided, include it in the path
  if [[ -n "$branch" ]]; then
    path="$path/$branch"
  fi
  
  echo "$path"
}

# Get path to project memory bank
function get_project_mb_path() {
  local project_root="$1"
  
  # Handle relative paths
  if [[ ! "$project_root" = /* ]]; then
    project_root="$PWD/$project_root"
  fi
  
  echo "$project_root/memory-bank"
}

# Memory Bank Operations

# Create initial memory bank files
function create_memory_bank_files() {
  local mb_path="$1"
  
  # Create activeContext.md
  cat > "$mb_path/activeContext.md" << 'EOL'
# Active Context

This file tracks the project's current status, including recent changes, current goals, and open questions.
$(date +"%Y-%m-%d %H:%M:%S") - Memory bank initialized.

## Current Focus

* 

## Recent Changes

* 

## Open Questions/Issues

* 
EOL

  # Create productContext.md
  cat > "$mb_path/productContext.md" << 'EOL'
# Product Context

This file provides a high-level overview of the project and the expected product that will be created.
$(date +"%Y-%m-%d %H:%M:%S") - Memory bank initialized.

## Project Goal

* 

## Key Features

* 

## Overall Architecture

* 
EOL

  # Create progress.md
  cat > "$mb_path/progress.md" << 'EOL'
# Progress

This file tracks the project's progress using a task list format.
$(date +"%Y-%m-%d %H:%M:%S") - Memory bank initialized.

## Completed Tasks

* 

## Current Tasks

* 

## Next Steps

* 
EOL

  # Create decisionLog.md
  cat > "$mb_path/decisionLog.md" << 'EOL'
# Decision Log

This file records architectural and implementation decisions using a list format.
$(date +"%Y-%m-%d %H:%M:%S") - Memory bank initialized.

## Decision

* 

## Rationale

* 

## Implementation Details

* 
EOL

  # Create systemPatterns.md
  cat > "$mb_path/systemPatterns.md" << 'EOL'
# System Patterns

This file documents recurring patterns and standards used in the project.
$(date +"%Y-%m-%d %H:%M:%S") - Memory bank initialized.

## Coding Patterns

* 

## Architectural Patterns

* 

## Testing Patterns

* 
EOL
}

# Create a new memory bank
function create_memory_bank() {
  local domain="$1"
  local project="$2"
  local branch="$3"
  local central_path=$(get_central_mb_path "$domain" "$project" "$branch")
  
  # Create directories
  mkdir -p "$central_path"
  
  # Create initial files
  create_memory_bank_files "$central_path"
  
  echo "Created new memory bank at $central_path"
}

# Copy memory bank from one branch to another
function copy_memory_bank() {
  local domain="$1"
  local project="$2"
  local source_branch="$3"
  local target_branch="$4"
  
  local source_path=$(get_central_mb_path "$domain" "$project" "$source_branch")
  local target_path=$(get_central_mb_path "$domain" "$project" "$target_branch")
  
  # Check if source exists
  if [[ ! -d "$source_path" ]]; then
    echo "Error: Source memory bank does not exist: $source_path"
    return 1
  fi
  
  # Create target directory
  mkdir -p "$target_path"
  
  # Copy files
  cp -r "$source_path/"* "$target_path/"
  
  # Update timestamp in files
  find "$target_path" -name "*.md" -exec sed -i '' "s/Memory bank initialized/Memory bank copied from $source_branch/g" {} \;
  
  echo "Copied memory bank from $source_branch to $target_branch"
}

# Switch to a different memory bank
function switch_memory_bank() {
  local project_root="$1"
  local domain="$2"
  local project="$3"
  local branch="$4"
  
  local project_mb=$(get_project_mb_path "$project_root")
  local central_mb=$(get_central_mb_path "$domain" "$project" "$branch")
  
  # Save current memory bank if it exists
  if [[ -d "$project_mb" ]]; then
    sync_to_central "$project_root" "$domain" "$project" "$(get_git_branch)"
  fi
  
  # Check if central memory bank exists
  if [[ ! -d "$central_mb" ]]; then
    # Prompt user to create new memory bank or copy from parent
    echo "Memory bank for $branch does not exist."
    echo "Options:"
    echo "  1. Create new memory bank (default)"
    echo "  2. Copy from current branch"
    
    read -p "Enter choice [1]: " choice
    choice=${choice:-1}
    
    case $choice in
      1)
        create_memory_bank "$domain" "$project" "$branch"
        ;;
      2)
        local current_branch=$(get_git_branch)
        copy_memory_bank "$domain" "$project" "$current_branch" "$branch"
        ;;
      *)
        echo "Invalid choice. Creating new memory bank."
        create_memory_bank "$domain" "$project" "$branch"
        ;;
    esac
  fi
  
  # Copy central to project
  rm -rf "$project_mb" 2>/dev/null
  mkdir -p "$project_mb"
  cp -r "$central_mb/"* "$project_mb/" 2>/dev/null
  
  echo "Switched to memory bank for $project ($branch)"
}

# Sync project and central memory banks
function sync_memory_bank() {
  local project_root="$1"
  local domain="$2"
  local project="$3"
  local branch="$4"
  
  # Sync in both directions
  sync_to_central "$project_root" "$domain" "$project" "$branch"
  sync_to_project "$project_root" "$domain" "$project" "$branch"
  
  echo "Synchronized memory bank for $project ($branch)"
}

# Sync from project to central
function sync_to_central() {
  local project_root="$1"
  local domain="$2"
  local project="$3"
  local branch="$4"
  
  local project_mb=$(get_project_mb_path "$project_root")
  local central_mb=$(get_central_mb_path "$domain" "$project" "$branch")
  
  # Ensure central directory exists
  mkdir -p "$central_mb"
  
  # Copy files from project to central with improved error handling
  if [[ -d "$project_mb" && "$(ls -A "$project_mb" 2>/dev/null)" ]]; then
    # First remove existing files to ensure clean sync
    rm -rf "$central_mb"/* 2>/dev/null
    # Then copy all files from project to central
    cp -r "$project_mb/"* "$central_mb/" 2>/dev/null
    echo "Synced memory bank from project to central: $branch"
  else
    echo "Warning: Project memory bank directory is empty or doesn't exist: $project_mb"
    # If central exists but project doesn't, we'll create the project memory bank
    if [[ -d "$central_mb" && "$(ls -A "$central_mb" 2>/dev/null)" ]]; then
      mkdir -p "$project_mb"
      cp -r "$central_mb/"* "$project_mb/" 2>/dev/null
      echo "Restored project memory bank from central"
    fi
  fi
}

# Sync from central to project
function sync_to_project() {
  local project_root="$1"
  local domain="$2"
  local project="$3"
  local branch="$4"
  
  local project_mb=$(get_project_mb_path "$project_root")
  local central_mb=$(get_central_mb_path "$domain" "$project" "$branch")
  
  # Ensure project directory exists
  mkdir -p "$project_mb"
  
  # Copy files from central to project with improved error handling
  if [[ -d "$central_mb" && "$(ls -A "$central_mb" 2>/dev/null)" ]]; then
    # First remove existing files to ensure clean sync
    rm -rf "$project_mb"/* 2>/dev/null
    # Then copy all files from central to project
    cp -r "$central_mb/"* "$project_mb/" 2>/dev/null
    echo "Synced memory bank from central to project: $branch"
  else
    echo "Warning: Central memory bank directory is empty or doesn't exist: $central_mb"
    # Create default files if central is empty
    if [[ ! -f "$project_mb/activeContext.md" ]]; then
      create_memory_bank_files "$project_mb"
      echo "Created default memory bank files in project"
    fi
  fi
}

# Utility Functions

# Ensure memory bank is in .gitignore
function ensure_gitignore() {
  local project_root="$1"
  local gitignore="$project_root/.gitignore"
  
  # Create .gitignore if it doesn't exist
  if [[ ! -f "$gitignore" ]]; then
    touch "$gitignore"
  fi
  
  # Add memory-bank to .gitignore if not already present
  if ! grep -q "^/memory-bank" "$gitignore"; then
    echo "/memory-bank" >> "$gitignore"
    echo "Added /memory-bank to .gitignore"
  fi
}

# Setup global gitignore
function setup_global_gitignore() {
  local global_gitignore="$HOME/.gitignore_global"
  
  # Create global gitignore if it doesn't exist
  if [[ ! -f "$global_gitignore" ]]; then
    touch "$global_gitignore"
    git config --global core.excludesfile "$global_gitignore"
  fi
  
  # Add memory-bank to global gitignore
  if ! grep -q "memory-bank/" "$global_gitignore"; then
    echo "memory-bank/" >> "$global_gitignore"
    echo "Added memory-bank/ to global gitignore"
  fi
}

# Check if in Cursor workspace
function check_cursor_workspace() {
  # Check for Cursor-specific environment variables
  if [[ -n "$CURSOR_WORKSPACE" ]]; then
    return 0
  fi
  
  # Check for Cursor-specific files
  if [[ -f "$HOME/.cursor/cursor.json" ]]; then
    return 0
  fi
  
  # Default to false
  return 1
}

# Main Command-Line Interface
function mb() {
  local command="${1:-status}"
  shift || true
  
  # Get current project info
  local project_root=$(get_project_root)
  local domain=$(get_project_domain "$project_root")
  local project=$(get_project_name "$project_root")
  local branch=$(get_git_branch)
  
  case "$command" in
    status)
      echo "Memory Bank Status:"
      echo "Project: $project"
      echo "Domain: $domain"
      echo "Branch: $branch"
      echo "Project Path: $project_root"
      echo "Central Path: $(get_central_mb_path "$domain" "$project" "$branch")"
      
      # Check if memory bank exists
      local project_mb=$(get_project_mb_path "$project_root")
      local central_mb=$(get_central_mb_path "$domain" "$project" "$branch")
      
      if [[ -d "$project_mb" ]]; then
        echo "Project Memory Bank: ✅ Exists"
      else
        echo "Project Memory Bank: ❌ Not found"
      fi
      
      if [[ -d "$central_mb" ]]; then
        echo "Central Memory Bank: ✅ Exists"
      else
        echo "Central Memory Bank: ❌ Not found"
      fi
      
      # Check gitignore status
      if git check-ignore -q "$project_mb" 2>/dev/null; then
        echo "Gitignore Status: ✅ Properly ignored"
      else
        echo "Gitignore Status: ⚠️ May not be ignored"
      fi
      ;;
    create)
      create_memory_bank "$domain" "$project" "$branch"
      sync_to_project "$project_root" "$domain" "$project" "$branch"
      ensure_gitignore "$project_root"
      ;;
    switch)
      local target_branch="${1:-$branch}"
      switch_memory_bank "$project_root" "$domain" "$project" "$target_branch"
      ensure_gitignore "$project_root"
      ;;
    sync)
      sync_memory_bank "$project_root" "$domain" "$project" "$branch"
      ensure_gitignore "$project_root"
      ;;
    list)
      echo "Available Memory Banks for $project:"
      ls -1 "$(get_central_mb_path "$domain" "$project" "")" 2>/dev/null || echo "None found."
      ;;
    archive)
      local target_branch="${1:-$branch}"
      local central_mb=$(get_central_mb_path "$domain" "$project" "$target_branch")
      local archive_path="$(get_central_mb_path "$domain" "$project" "archive")"
      
      if [[ ! -d "$central_mb" ]]; then
        echo "Error: Memory bank for $target_branch does not exist"
        return 1
      fi
      
      mkdir -p "$archive_path"
      mv "$central_mb" "$archive_path/$target_branch-$(date +%Y%m%d)"
      echo "Archived memory bank for $target_branch"
      ;;
    merge)
      local source_branch="$1"
      
      if [[ -z "$source_branch" ]]; then
        echo "Error: Source branch required"
        echo "Usage: mb merge <source_branch>"
        return 1
      fi
      
      local central_source=$(get_central_mb_path "$domain" "$project" "$source_branch")
      local central_target=$(get_central_mb_path "$domain" "$project" "$branch")
      
      if [[ ! -d "$central_source" ]]; then
        echo "Error: Source memory bank does not exist: $central_source"
        return 1
      fi
      
      if [[ ! -d "$central_target" ]]; then
        echo "Error: Target memory bank does not exist: $central_target"
        return 1
      fi
      
      # Simple merge strategy: for each file in source, append unique content to target
      for file in "$central_source"/*.md; do
        filename=$(basename "$file")
        target_file="$central_target/$filename"
        
        if [[ -f "$target_file" ]]; then
          echo "Merging $filename..."
          
          # Create a temporary file with merged content
          cat "$target_file" > "$target_file.tmp"
          echo -e "\n## Merged from $source_branch on $(date +"%Y-%m-%d %H:%M:%S")\n" >> "$target_file.tmp"
          
          # Extract content sections from source file and append to target
          sed -n '/^## /,$p' "$file" >> "$target_file.tmp"
          
          # Replace target with merged content
          mv "$target_file.tmp" "$target_file"
        else
          echo "Copying $filename (not present in target)..."
          cp "$file" "$target_file"
        fi
      done
      
      # Update project memory bank
      sync_to_project "$project_root" "$domain" "$project" "$branch"
      
      echo "Merged memory bank from $source_branch into $branch"
      ;;
    rebase)
      local base_branch="$1"
      
      if [[ -z "$base_branch" ]]; then
        echo "Error: Base branch required"
        echo "Usage: mb rebase <base_branch>"
        return 1
      fi
      
      local central_base=$(get_central_mb_path "$domain" "$project" "$base_branch")
      local central_current=$(get_central_mb_path "$domain" "$project" "$branch")
      
      if [[ ! -d "$central_base" ]]; then
        echo "Error: Base memory bank does not exist: $central_base"
        return 1
      fi
      
      if [[ ! -d "$central_current" ]]; then
        echo "Error: Current memory bank does not exist: $central_current"
        return 1
      fi
      
      # Add a note about the rebase to activeContext.md
      local project_mb=$(get_project_mb_path "$project_root")
      if [[ -f "$project_mb/activeContext.md" ]]; then
        echo -e "\n## Rebase Event\n\n* $(date +"%Y-%m-%d %H:%M:%S") - Manually rebased memory bank from $branch onto $base_branch\n" >> "$project_mb/activeContext.md"
      fi
      
      # Merge the base branch memory bank into the current branch
      for file in "$central_base"/*.md; do
        filename=$(basename "$file")
        target_file="$central_current/$filename"
        
        if [[ -f "$target_file" ]]; then
          echo "Merging $filename..."
          
          # Create a temporary file with merged content
          cat "$target_file" > "$target_file.tmp"
          echo -e "\n## Rebased from $base_branch on $(date +"%Y-%m-%d %H:%M:%S")\n" >> "$target_file.tmp"
          
          # Extract content sections from source file and append to target
          sed -n '/^## /,$p' "$file" >> "$target_file.tmp"
          
          # Replace target with merged content
          mv "$target_file.tmp" "$target_file"
        else
          echo "Copying $filename (not present in target)..."
          cp "$file" "$target_file"
        fi
      done
      
      # Update project memory bank
      sync_to_project "$project_root" "$domain" "$project" "$branch"
      
      echo "Rebased memory bank from $base_branch into $branch"
      ;;
    check)
      local project_mb=$(get_project_mb_path "$project_root")
      
      # Check if memory-bank is gitignored
      if git check-ignore -q "$project_mb" 2>/dev/null; then
        echo "✅ Memory bank is properly gitignored"
      else
        echo "⚠️ Warning: Memory bank may not be gitignored!"
        echo "Run 'mb fix-gitignore' to fix this issue."
      fi
      ;;
    fix-gitignore)
      ensure_gitignore "$project_root"
      setup_global_gitignore
      echo "Fixed gitignore settings"
      ;;
    help)
      echo "Memory Bank Manager Usage:"
      echo "  mb                  Show status"
      echo "  mb create           Create new memory bank"
      echo "  mb switch [branch]  Switch to branch memory bank"
      echo "  mb sync             Sync memory bank"
      echo "  mb list             List available memory banks"
      echo "  mb archive [branch] Archive branch memory bank"
      echo "  mb merge <branch>   Merge branch memory bank into current"
      echo "  mb rebase <branch>  Rebase current memory bank on top of another branch's memory bank"
      echo "  mb check            Check gitignore status"
      echo "  mb fix-gitignore    Fix gitignore settings"
      echo "  mb help             Show this help"
      ;;
    *)
      echo "Unknown command: $command"
      echo "Run 'mb help' for usage information."
      return 1
      ;;
  esac
}

# Get parent branch of the current branch
function get_parent_branch() {
  local branch="$1"
  # Try to find the parent branch from git reflog
  git reflog -10 | grep -o "checkout: moving from .* to $branch" | head -1 | sed 's/checkout: moving from \(.*\) to.*/\1/'
}

# Detect if a branch was rebased
function detect_rebase() {
  local branch="$1"
  # Check recent git reflog for rebase operations
  if git reflog -5 | grep -q "rebase"; then
    return 0  # True, rebase detected
  else
    return 1  # False, no rebase detected
  fi
}

# Get the base branch that was rebased onto
function get_rebase_base_branch() {
  # Try to extract the base branch from the reflog
  git reflog -5 | grep -o "rebase.*onto" | head -1 | sed 's/.*onto \([^ ]*\).*/\1/' | sed 's/^.*\///'
}

# Initialize on shell startup
export GIT_HOOKS_DIR="$HOME/.git-hooks"
git config --global core.hooksPath "$GIT_HOOKS_DIR"