#!/bin/zsh
# Memory Bank Manager Installation Script
# This script sets up the memory bank management system for Roo Code Memory Banks

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

print_info "Starting Memory Bank Manager installation..."

# Create directory structure
print_info "Creating directory structure..."
mkdir -p ~/code/ai-memory-banks/{david,gather,me,play,stitch,world}
print_success "Directory structure created at ~/code/ai-memory-banks/"

# Create git hooks directory
print_info "Setting up git hooks directory..."
export GIT_HOOKS_DIR="$HOME/.git-hooks"
mkdir -p "$GIT_HOOKS_DIR"
git config --global core.hooksPath "$GIT_HOOKS_DIR"
print_success "Git hooks directory set up at $GIT_HOOKS_DIR"

# Copy git hooks
print_info "Installing git hooks..."
cp pre-checkout "$GIT_HOOKS_DIR/"
cp post-checkout "$GIT_HOOKS_DIR/"
cp post-merge "$GIT_HOOKS_DIR/"
cp post-rebase "$GIT_HOOKS_DIR/"
chmod +x "$GIT_HOOKS_DIR"/*
print_success "Git hooks installed"

# Setup global gitignore
print_info "Setting up global gitignore..."
global_gitignore="$HOME/.gitignore_global"

# Create global gitignore if it doesn't exist
if [[ ! -f "$global_gitignore" ]]; then
  touch "$global_gitignore"
  git config --global core.excludesfile "$global_gitignore"
fi

# Add memory-bank to global gitignore
if ! grep -q "memory-bank/" "$global_gitignore"; then
  echo "memory-bank/" >> "$global_gitignore"
  print_success "Added memory-bank/ to global gitignore"
else
  print_info "memory-bank/ already in global gitignore"
fi

# Add functions to ~/.zshrc
print_info "Adding functions to ~/.zshrc..."

# Check if functions are already in ~/.zshrc
if grep -q "# Memory Bank Manager Functions" ~/.zshrc; then
  print_warning "Memory Bank Manager functions already exist in ~/.zshrc"
  print_info "Skipping function installation"
else
  # Add a newline for cleaner separation
  echo "" >> ~/.zshrc
  
  # Add functions to ~/.zshrc
  cat memory_bank_functions.sh >> ~/.zshrc
  
  print_success "Functions added to ~/.zshrc"
fi

print_info "Installation complete!"
print_info "To start using Memory Bank Manager:"
print_info "1. Run 'source ~/.zshrc' or restart your terminal"
print_info "2. Navigate to a project"
print_info "3. Run 'mb status' to verify setup"
print_info "4. Run 'mb create' to create your first memory bank"

# Offer to source ~/.zshrc
read -p "Would you like to source ~/.zshrc now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  source ~/.zshrc
  print_success "~/.zshrc sourced"
  
  # Check if we're in a git repository
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    print_info "You're in a git repository. You can run 'mb status' to check the status of your memory bank."
  else
    print_info "You're not in a git repository. Navigate to a project and run 'mb status'."
  fi
else
  print_info "Remember to source ~/.zshrc or restart your terminal before using Memory Bank Manager."
fi

exit 0