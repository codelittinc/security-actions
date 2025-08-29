#!/bin/bash

# Script to run npm audit with configurable audit level
# Usage: ./run-npm-audit.sh <audit_level> <continue_on_error>

set -e

AUDIT_LEVEL=${1:-"moderate"}
CONTINUE_ON_ERROR=${2:-"false"}

echo "🔍 Running npm audit with level: $AUDIT_LEVEL"

# Run npm audit with the specified level
if npm audit --audit-level="$AUDIT_LEVEL"; then
    echo "✅ npm audit passed at level: $AUDIT_LEVEL"
    exit 0
else
    echo "❌ npm audit failed at level: $AUDIT_LEVEL"
    
    if [ "$CONTINUE_ON_ERROR" = "true" ]; then
        echo "⚠️  Continuing despite audit failure (continue_on_error=true)"
        exit 0
    else
        echo "🚨 Build failed due to npm audit issues"
        exit 1
    fi
fi
