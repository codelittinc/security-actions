#!/bin/bash
set -e

# Mock workflow test script
echo "🔍 Testing workflow with mock TruffleHog"
echo "Scenario: ${TEST_SCENARIO:-no_secrets}"
echo "Ignore Keys: ${IGNORE_KEYS:-none}"

# Create a temporary directory for testing
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Initialize a git repository
git init
git config user.email "test@example.com"
git config user.name "Test User"

# Create test content based on scenario
if [ "$TEST_SCENARIO" = "secrets_found" ]; then
    echo "Creating test repository with secrets..."
    echo "API_KEY=fake_key_12345" > .env
    echo "GITHUB_TOKEN=ghp_test123" >> secrets.txt
    git add .env secrets.txt
    git commit -m "Add test secrets"
else
    echo "Creating clean test repository..."
    echo "# Clean repository" > README.md
    git add README.md
    git commit -m "Initial commit"
fi

# Mock the trufflehog command by putting our mock in PATH
export PATH="/workspace/test:$PATH"

# Test the core logic by sourcing and running functions
source /workspace/scripts/trufflehog-functions.sh

# Test get_scan_range function
echo "Testing get_scan_range function..."
RESULT=$(get_scan_range "main" "main" "$(git rev-parse HEAD~1 2>/dev/null || echo '0000000000000000000000000000000000000000')")
echo "Scan range result: $RESULT"

# Test filter_ignored_keys function if ignore keys are provided
if [ -n "$IGNORE_KEYS" ]; then
    echo "Testing filter_ignored_keys function..."
    
    # Create test input file with findings
    cat > test_findings.json << EOF
{"Raw": "fake_key_12345", "DetectorName": "Generic", "SourceMetadata": {"Data": {"Git": {"file": "test.txt"}}}}
{"Raw": "ghp_test123", "DetectorName": "Github", "SourceMetadata": {"Data": {"Git": {"file": "secrets.txt"}}}}
EOF
    
    filter_ignored_keys "test_findings.json" "filtered_findings.json" "$IGNORE_KEYS"
    
    echo "Original findings:"
    cat test_findings.json
    echo "Filtered findings:"
    cat filtered_findings.json
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "✅ Mock workflow test completed successfully"
