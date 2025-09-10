#!/bin/bash

# Script to perform final security gate check
# Usage: ./security-gate-check.sh <audit_level> <continue_on_error>

set -e

AUDIT_LEVEL=${1:-"moderate"}
CONTINUE_ON_ERROR=${2:-"false"}

echo "🔒 Final security gate check..."

# Check if npm audit found vulnerabilities at the configured level
if npm audit --audit-level="$AUDIT_LEVEL" --json | jq -e '.vulnerabilities | length > 0' > /dev/null 2>&1; then
    echo "❌ Security vulnerabilities detected at level '$AUDIT_LEVEL' - build blocked"
    echo "Please fix the vulnerabilities before proceeding"
    exit 1
fi

# Double-check for high severity vulnerabilities (should have been caught earlier, but safety check)
if npm audit --audit-level=high --json | jq -e '.vulnerabilities | length > 0' > /dev/null 2>&1; then
    echo "❌ CRITICAL: High severity vulnerabilities still detected - build blocked"
    echo "This should not happen if previous checks passed. Please investigate."
    exit 1
fi

echo "✅ Security gate passed - no vulnerabilities detected"
echo "✅ Build can proceed safely"
