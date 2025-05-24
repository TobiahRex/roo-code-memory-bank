#!/bin/zsh
# Test script for domain detection

# Source the memory bank functions
source ./memory_bank_functions.sh

# Test cases
echo "Testing domain detection..."

# Test case 1: Standard path with domains directory
test_path_1="$HOME/code/domains/example_domain/project_name"
domain_1=$(get_project_domain "$test_path_1")
echo "Test 1: $test_path_1 -> Domain: $domain_1"

# Test case 2: Legacy path structure
test_path_2="$HOME/code/example_domain/project_name"
domain_2=$(get_project_domain "$test_path_2")
echo "Test 2: $test_path_2 -> Domain: $domain_2"

# Test case 3: Temporary directory (similar to the bug example)
test_path_3="/private/var/folders/x7/d_1kvnqn42s9_xsggmv3qfqr0000gp/T/tmp.4o7rQgHUlB"
domain_3=$(get_project_domain "$test_path_3")
echo "Test 3: $test_path_3 -> Domain: $domain_3"

# Test case 4: Project in root directory (should return "unknown")
test_path_4="/"
domain_4=$(get_project_domain "$test_path_4")
echo "Test 4: $test_path_4 -> Domain: $domain_4"

# Test case 5: Current directory
test_path_5="$PWD"
domain_5=$(get_project_domain "$test_path_5")
echo "Test 5: $test_path_5 -> Domain: $domain_5"

echo "Domain detection testing complete."