#!/bin/bash

# Script to check for high severity vulnerabilities
# Usage: ./check-high-severity-vulnerabilities.sh <continue_on_error>

set -e

CONTINUE_ON_ERROR=${1:-"false"}

echo "🔍 Checking for high severity vulnerabilities..."

# Check npm audit for high/critical vulnerabilities
if npm audit --audit-level=high --json | jq -e '.vulnerabilities | length > 0' > /dev/null 2>&1; then
    echo "❌ HIGH SEVERITY VULNERABILITIES DETECTED!"
    echo "npm audit found high or critical vulnerabilities that must be fixed."
    echo ""
    echo "Vulnerability details:"
    npm audit --audit-level=high
    echo ""
    echo "🚨 BUILD FAILED: High severity vulnerabilities detected"
    echo "Please fix these vulnerabilities before proceeding."
    exit 1
fi

# Check OWASP report for high CVSS scores
if [ -f "reports/dependency-check-report.xml" ]; then
    echo "🔍 Checking OWASP report for high CVSS vulnerabilities..."
    
    # Check if there are any vulnerabilities with CVSS >= 7 (high)
    if grep -q 'severity="High"' reports/dependency-check-report.xml 2>/dev/null; then
        echo "❌ HIGH CVSS VULNERABILITIES DETECTED IN OWASP REPORT!"
        echo "OWASP Dependency Check found high severity vulnerabilities."
        echo ""
        echo "🚨 BUILD FAILED: High CVSS vulnerabilities detected"
        echo "Please review the OWASP report and fix high severity issues."
        exit 1
    fi
fi

echo "✅ No high severity vulnerabilities detected"
