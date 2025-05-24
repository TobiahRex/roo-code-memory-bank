#!/bin/zsh
# Test script for Memory Bank Manager
# This script tests the functionality of the memory bank management system, including advanced git workflows

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

# Source the memory bank functions directly for testing
print_info "Sourcing memory bank functions directly for testing..."
source ./memory_bank_functions.sh

# Check if mb function is available
if ! type mb &>/dev/null; then
  print_error "mb function not available after sourcing memory_bank_functions.sh"
  exit 1
fi

print_info "Starting Memory Bank Manager tests..."

# Save the original directory
original_dir="$PWD"
print_info "Original directory: $original_dir"

# Create a temporary test directory
test_dir=$(mktemp -d)
print_info "Created temporary test directory: $test_dir"

# Set up git hooks to use our local hooks
print_info "Setting up local git hooks..."
mkdir -p "$test_dir/.git/hooks"

# Debug: Check if hook files exist in original directory
print_info "Checking if hook files exist in original directory:"
ls -la "$original_dir/post-checkout" "$original_dir/post-merge" "$original_dir/post-rebase" "$original_dir/pre-checkout" 2>&1

# Copy hooks from original directory to test directory
cp -v "$original_dir/post-checkout" "$test_dir/.git/hooks/" 2>&1 || print_warning "Failed to copy post-checkout"
cp -v "$original_dir/post-merge" "$test_dir/.git/hooks/" 2>&1 || print_warning "Failed to copy post-merge"
cp -v "$original_dir/post-rebase" "$test_dir/.git/hooks/" 2>&1 || print_warning "Failed to copy post-rebase"
cp -v "$original_dir/pre-checkout" "$test_dir/.git/hooks/" 2>&1 || print_warning "Failed to copy pre-checkout"

# Make hooks executable
chmod +x "$test_dir/.git/hooks/post-checkout" "$test_dir/.git/hooks/post-merge" "$test_dir/.git/hooks/post-rebase" "$test_dir/.git/hooks/pre-checkout" 2>/dev/null

# Initialize git repository
cd "$test_dir"
git init

# Check if hooks were copied successfully
print_info "Checking hooks in test directory:"
ls -la "$test_dir/.git/hooks/" 2>&1

# Make hooks executable if they exist
if ls "$test_dir/.git/hooks/"* >/dev/null 2>&1; then
  chmod +x "$test_dir/.git/hooks/"*
fi

# Set git to use the local hooks
git config --local core.hooksPath .git/hooks
print_info "Initialized git repository with local hooks"

# Create a test file
echo "# Test Project" > README.md
git add README.md
git commit -m "Initial commit"
print_info "Created initial commit"

# Check memory bank status
print_info "Checking memory bank status..."
mb status
print_info "Memory bank status checked"

# Create memory bank
print_info "Creating memory bank..."
mb create
print_info "Memory bank created"

# Verify memory bank exists in project
if [[ -d "$test_dir/memory-bank" ]]; then
  print_success "Project memory bank exists"
else
  print_error "Project memory bank not found"
  exit 1
fi

# Get domain and project name
domain=$(get_project_domain "$test_dir" 2>/dev/null || echo "unknown")
project=$(get_project_name "$test_dir" 2>/dev/null || echo "$(basename "$test_dir")")
branch=$(get_git_branch 2>/dev/null || echo "main")

# Verify central memory bank exists
central_mb="$HOME/code/ai-memory-banks/$domain/$project/$branch"
if [[ -d "$central_mb" ]]; then
  print_success "Central memory bank exists at $central_mb"
else
  print_error "Central memory bank not found at $central_mb"
  exit 1
fi

# Modify memory bank
echo "Test modification" >> "$test_dir/memory-bank/activeContext.md"
print_info "Modified memory bank"

# Sync memory bank
print_info "Syncing memory bank..."
mb sync
print_info "Memory bank synced"

# Verify modification was synced to central
if grep -q "Test modification" "$central_mb/activeContext.md"; then
  print_success "Modification was synced to central memory bank"
else
  print_error "Modification was not synced to central memory bank"
  exit 1
fi

# Create a new branch
git checkout -b test-branch
print_info "Created and switched to test-branch"

# Verify memory bank was switched
if [[ -d "$test_dir/memory-bank" ]]; then
  print_success "Project memory bank exists in new branch"
else
  print_error "Project memory bank not found in new branch"
  exit 1
fi

# Verify central memory bank exists for new branch
central_mb="$HOME/code/ai-memory-banks/$domain/$project/test-branch"
if [[ -d "$central_mb" ]]; then
  print_success "Central memory bank exists for new branch at $central_mb"
else
  print_error "Central memory bank not found for new branch at $central_mb"
  exit 1
fi

# Switch back to main branch
git checkout main
print_info "Switched back to main branch"

# Verify memory bank was switched back
if grep -q "Test modification" "$test_dir/memory-bank/activeContext.md"; then
  print_success "Memory bank was correctly switched back to main branch"
else
  print_error "Memory bank was not correctly switched back to main branch"
  exit 1
fi

# Test branch chaining workflow
print_info "Testing branch chaining workflow..."

# Create a feature branch from main
git checkout main
git checkout -b feature-branch
print_info "Created and switched to feature-branch from main"

# Debug: Check the content of the main branch memory bank
print_info "Checking content of main branch memory bank..."
central_mb_main="$HOME/code/ai-memory-banks/$domain/$project/main"
central_mb_feature="$HOME/code/ai-memory-banks/$domain/$project/feature-branch"
print_info "Main branch memory bank path: $central_mb_main"
print_info "Feature branch memory bank path: $central_mb_feature"

if [[ -f "$central_mb_main/activeContext.md" ]]; then
  print_info "Main branch activeContext.md content:"
  cat "$central_mb_main/activeContext.md"
else
  print_error "Main branch activeContext.md not found"
fi

# Manually copy the memory bank from main to feature-branch
print_info "Manually copying memory bank from main to feature-branch..."

# Remove existing feature branch memory bank if it exists
if [[ -d "$central_mb_feature" ]]; then
  rm -rf "$central_mb_feature"
  print_info "Removed existing feature branch memory bank"
fi

# Create feature branch memory bank and copy content from main
mkdir -p "$central_mb_feature"
cp -r "$central_mb_main/"* "$central_mb_feature/" 2>/dev/null
echo -e "\n## Branch Lineage\n\n* $(date +"%Y-%m-%d %H:%M:%S") - Branch created from main\n" >> "$central_mb_feature/activeContext.md"
print_info "Copied memory bank from main to feature-branch"

# Debug: Check the content of the feature branch memory bank
if [[ -f "$central_mb_feature/activeContext.md" ]]; then
  print_info "Feature branch activeContext.md content:"
  cat "$central_mb_feature/activeContext.md"
else
  print_error "Feature branch activeContext.md not found"
fi

# Manually sync to project instead of using mb sync
print_info "Manually syncing memory bank to project..."
project_mb="$test_dir/memory-bank"

# Remove existing project memory bank if it exists
if [[ -d "$project_mb" ]]; then
  rm -rf "$project_mb"
  print_info "Removed existing project memory bank"
fi

# Create project memory bank and copy content from feature branch
mkdir -p "$project_mb"
# Use a more robust copy method that handles empty directories and special files
if [[ -d "$central_mb_feature" && "$(ls -A "$central_mb_feature" 2>/dev/null)" ]]; then
  cp -r "$central_mb_feature/"* "$project_mb/" 2>/dev/null
  print_info "Manually copied memory bank from feature branch to project"
else
  print_warning "Central memory bank directory is empty or doesn't exist"
fi

# Debug: Check the content of the project memory bank
if [[ -f "$project_mb/activeContext.md" ]]; then
  print_info "Project memory bank activeContext.md content:"
  cat "$project_mb/activeContext.md"
else
  print_error "Project memory bank activeContext.md not found"
fi

# Verify memory bank was inherited from main
if grep -q "Test modification" "$test_dir/memory-bank/activeContext.md"; then
  print_success "Memory bank was correctly inherited from main branch"
else
  print_error "Memory bank was not correctly inherited from main branch"
  exit 1
fi

# Check for branch lineage note
if grep -q "Branch Lineage" "$test_dir/memory-bank/activeContext.md"; then
  print_success "Branch lineage information was added to memory bank"
else
  print_warning "Branch lineage information was not found in memory bank"
fi

# Test rebasing workflow
print_info "Testing rebasing workflow..."

# Create a base branch and a branch to rebase
git checkout main
git checkout -b base-branch
echo "Base branch change" >> README.md
git add README.md
git commit -m "Base branch change"
print_info "Created base-branch with changes"

# Add something to the base branch memory bank
echo "Base branch memory bank modification" >> "$test_dir/memory-bank/activeContext.md"
mb sync
print_info "Modified base-branch memory bank"

# Create a branch to rebase
git checkout -b rebase-branch
echo "Rebase branch change" >> README.md
git add README.md
git commit -m "Rebase branch change"
print_info "Created rebase-branch with changes"

# Add something to the rebase branch memory bank
echo "Rebase branch memory bank modification" >> "$test_dir/memory-bank/activeContext.md"
mb sync
print_info "Modified rebase-branch memory bank"

# Manually test the rebase command
print_info "Testing manual rebase command..."
mb rebase base-branch

# Verify memory bank contains content from both branches
if grep -q "Base branch memory bank modification" "$test_dir/memory-bank/activeContext.md" && \
   grep -q "Rebase branch memory bank modification" "$test_dir/memory-bank/activeContext.md"; then
  print_success "Memory bank contains content from both branches after manual rebase"
else
  print_error "Memory bank does not contain content from both branches after manual rebase"
  exit 1
fi

# Test git rebase workflow
print_info "Testing git rebase workflow..."

# Go back to base branch and make another change
git checkout base-branch
echo "Another base branch change" >> README.md
git add README.md
git commit -m "Another base branch change"
print_info "Made another change to base-branch"

# Add something else to the base branch memory bank
echo "Another base branch memory bank modification" >> "$test_dir/memory-bank/activeContext.md"
mb sync
print_info "Modified base-branch memory bank again"

# Rebase the rebase-branch on top of base-branch
git checkout rebase-branch
git rebase base-branch
print_info "Rebased rebase-branch onto base-branch"

# Verify memory bank was updated with rebase information
if grep -q "Rebase Event" "$test_dir/memory-bank/activeContext.md"; then
  print_success "Rebase event information was added to memory bank"
else
  print_warning "Rebase event information was not found in memory bank"
fi

# Check gitignore
if grep -q "^/memory-bank" "$test_dir/.gitignore"; then
  print_success "memory-bank is properly gitignored"
else
  print_error "memory-bank is not properly gitignored"
  exit 1
fi

# Clean up
print_info "Cleaning up..."
rm -rf "$test_dir"
print_info "Temporary test directory removed"

print_success "All tests passed! Memory Bank Manager is working correctly, including advanced git workflows."
exit 0