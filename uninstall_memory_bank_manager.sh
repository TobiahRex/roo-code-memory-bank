#!/bin/zsh
# Uninstall script for Memory Bank Manager
# This script removes the memory bank management system

# Print colored output
function print_info() {
  echo -e "\033[0;34m[INFO]\033[0m $1"
}

function print_success() {
  echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

function print_warning() {
  echo -e "\033[0;33m[WARNING]\033[0m $1"
}

function print_error() {
  echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# Check if script is run with sudo (which we don't want)
if [[ $EUID -eq 0 ]]; then
  print_error "This script should not be run with sudo or as root."
  exit 1
fi

print_info "Starting Memory Bank Manager uninstallation..."

# Ask for confirmation
read -p "Are you sure you want to uninstall Memory Bank Manager? This will remove all git hooks and functions, but will NOT delete your memory banks. (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  print_info "Uninstallation cancelled."
  exit 0
fi

# Remove git hooks
print_info "Removing git hooks..."
if [[ -d "$HOME/.git-hooks" ]]; then
  rm -f "$HOME/.git-hooks/pre-checkout" "$HOME/.git-hooks/post-checkout" "$HOME/.git-hooks/post-merge" "$HOME/.git-hooks/post-rebase"
  print_success "Git hooks removed"
else
  print_warning "Git hooks directory not found"
fi

# Reset git hooks path
print_info "Resetting git hooks path..."
git config --global --unset core.hooksPath
print_success "Git hooks path reset"

# Remove functions from ~/.zshrc
print_info "Removing functions from ~/.zshrc..."
if grep -q "# Memory Bank Manager Functions" ~/.zshrc; then
  # Create a temporary file
  temp_file=$(mktemp)
  
  # Remove the Memory Bank Manager section from ~/.zshrc
  sed '/# Memory Bank Manager Functions/,/# Initialize on shell startup/d' ~/.zshrc > "$temp_file"
  
  # Remove the initialization lines
  sed '/export GIT_HOOKS_DIR/d' "$temp_file" | sed '/git config --global core.hooksPath/d' > ~/.zshrc
  
  # Remove the temporary file
  rm "$temp_file"
  
  print_success "Functions removed from ~/.zshrc"
else
  print_warning "Memory Bank Manager functions not found in ~/.zshrc"
fi

# Remove from global gitignore
print_info "Removing from global gitignore..."
global_gitignore="$HOME/.gitignore_global"
if [[ -f "$global_gitignore" ]]; then
  # Create a temporary file
  temp_file=$(mktemp)
  
  # Remove the memory-bank entry from global gitignore
  grep -v "memory-bank/" "$global_gitignore" > "$temp_file"
  mv "$temp_file" "$global_gitignore"
  
  print_success "Removed from global gitignore"
else
  print_warning "Global gitignore not found"
fi

print_info "Uninstallation complete!"
print_info "Note: Your memory banks are still stored in ~/code/ai-memory-banks/"
print_info "If you want to remove them, run: rm -rf ~/code/ai-memory-banks/"
print_info "To complete the uninstallation, please restart your terminal or run: source ~/.zshrc"

# Offer to source ~/.zshrc
read -p "Would you like to source ~/.zshrc now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  source ~/.zshrc
  print_success "~/.zshrc sourced"
else
  print_info "Remember to source ~/.zshrc or restart your terminal to complete the uninstallation."
fi

exit 0