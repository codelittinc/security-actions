#!/bin/bash
set -e

echo "🔍 Testing GitHub Actions workflow syntax"

# Function to validate YAML syntax
validate_yaml() {
    local file=$1
    echo "Validating YAML syntax for: $file"
    
    # Basic YAML syntax check using python (available in most environments)
    python3 -c "
import yaml
import sys

try:
    with open('$file', 'r') as f:
        yaml.safe_load(f)
    print('✅ Valid YAML syntax')
except yaml.YAMLError as e:
    print(f'❌ YAML syntax error: {e}')
    sys.exit(1)
except Exception as e:
    print(f'❌ Error reading file: {e}')
    sys.exit(1)
"
}

# Function to check GitHub Actions specific syntax
validate_github_actions() {
    local file=$1
    echo "Checking GitHub Actions specific syntax for: $file"
    
    # Check for required fields
    if ! grep -q "^name:" "$file"; then
        echo "❌ Missing 'name' field"
        return 1
    fi
    
    if ! grep -q "^on:" "$file"; then
        echo "❌ Missing 'on' field"
        return 1
    fi
    
    if ! grep -q "^jobs:" "$file"; then
        echo "❌ Missing 'jobs' field"
        return 1
    fi
    
    # Check for common syntax patterns
    if grep -q "uses:.*@" "$file"; then
        echo "✅ Found action references"
    fi
    
    if grep -q "runs-on:" "$file"; then
        echo "✅ Found runner specifications"
    fi
    
    echo "✅ GitHub Actions syntax checks passed"
}

# Test main security workflow
echo "Testing main security workflow..."
validate_yaml ".github/workflows/security.yml"
validate_github_actions ".github/workflows/security.yml"

echo ""

# Test the test workflow itself
echo "Testing test workflow..."
validate_yaml ".github/workflows/test-security-action.yml"
validate_github_actions ".github/workflows/test-security-action.yml"

echo ""

# Check for common issues
echo "Checking for common issues..."

# Check for hardcoded secrets (ironic, but important!)
if grep -r "ghp_[a-zA-Z0-9]" .github/workflows/ --exclude-dir=.git; then
    echo "⚠️  Warning: Found potential hardcoded GitHub tokens"
else
    echo "✅ No hardcoded GitHub tokens found"
fi

# Check for proper secret usage
if grep -q "secrets\." .github/workflows/security.yml; then
    echo "✅ Found proper secret usage"
else
    echo "❌ No secret usage found - this might be an issue"
fi

# Check for proper input handling
if grep -q "inputs\." .github/workflows/security.yml; then
    echo "✅ Found input handling"
else
    echo "❌ No input handling found"
fi

# Check for continue-on-error usage (should be used carefully)
CONTINUE_ON_ERROR_COUNT=$(grep -c "continue-on-error: true" .github/workflows/security.yml || echo "0")
echo "ℹ️  Found $CONTINUE_ON_ERROR_COUNT uses of 'continue-on-error: true'"

echo ""
echo "✅ Workflow syntax validation completed successfully"
