#!/bin/bash
set -e

echo "🧪 Running Security Actions Test Suite"
echo "======================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name=$1
    local test_command=$2
    
    print_status $BLUE "🔍 Running: $test_name"
    
    # Use a subshell to prevent `set -e` from stopping the script
    if (eval "$test_command"); then
        print_status $GREEN "✅ PASSED: $test_name"
        ((TESTS_PASSED++))
    else
        print_status $RED "❌ FAILED: $test_name"
        ((TESTS_FAILED++))
    fi
    echo ""
}

# 1. Unit Tests
print_status $YELLOW "=== Unit Tests ==="
run_test "TruffleHog Functions Unit Tests" "bats test/test-trufflehog-functions.bats"

# 2. Mock TruffleHog Tests
print_status $YELLOW "=== Mock Integration Tests ==="

# Test scenario: No secrets found
run_test "No Secrets Scenario" "TEST_SCENARIO=no_secrets ./test/test-workflow-mock.sh"

# Test scenario: Secrets found
run_test "Secrets Found Scenario" "TEST_SCENARIO=secrets_found ./test/test-workflow-mock.sh"

# Test scenario: Secrets with ignore keys
run_test "Ignore Keys Scenario" "TEST_SCENARIO=secrets_found IGNORE_KEYS=ghp_test123 ./test/test-workflow-mock.sh"

# 3. JSON Processing Tests
print_status $YELLOW "=== JSON Processing Tests ==="
run_test "JSON Output Formatting" "./test/test-json-processing.sh"

# 4. GitHub Actions Syntax Tests
print_status $YELLOW "=== GitHub Actions Syntax Tests ==="
run_test "Workflow Syntax Validation" "./test/test-workflow-syntax.sh"

# Summary
print_status $YELLOW "=== Test Summary ==="
print_status $GREEN "Tests Passed: $TESTS_PASSED"
if [ $TESTS_FAILED -gt 0 ]; then
    print_status $RED "Tests Failed: $TESTS_FAILED"
    exit 1
else
    print_status $GREEN "All tests passed! 🎉"
    exit 0
fi
