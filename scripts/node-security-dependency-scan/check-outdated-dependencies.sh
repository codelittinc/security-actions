#!/bin/bash

# Script to check for outdated dependencies with allowed libraries filtering
# Usage: ./check-outdated-dependencies.sh <allowed_libraries> <continue_on_error>

set -e

ALLOWED_LIBS=${1:-""}
CONTINUE_ON_ERROR=${2:-"false"}

echo "🔍 Checking for outdated dependencies..."

if [ -n "$ALLOWED_LIBS" ]; then
    echo "📋 Libraries allowed to be outdated: $ALLOWED_LIBS"
    
    # Clean up the allowed libraries string (remove spaces, normalize)
    ALLOWED_CLEAN=$(echo "$ALLOWED_LIBS" | tr -d ' ' | tr ',' '\n' | grep -v '^$' | tr '\n' ',' | sed 's/,$//')
    echo "📋 Cleaned allowed libraries: $ALLOWED_CLEAN"
    
    if [ -n "$ALLOWED_CLEAN" ]; then
        # Run npm outdated and filter out allowed libraries
        npm outdated --json 2>/dev/null | jq -r --arg allowed "$ALLOWED_CLEAN" '
            if . then
                to_entries[] |
                select(.key | IN($allowed | split(","))) |
                "ALLOWED: \(.key) - Current: \(.value.current) -> Latest: \(.value.latest)"
            else
                empty
            end
        ' || echo "✅ No outdated dependencies found"
        
        # Check for non-allowed outdated libraries using a simpler approach
        UNAUTHORIZED_OUTDATED=""
        
        # Get all outdated packages
        npm outdated --json 2>/dev/null > /tmp/all_outdated.json || true
        
        if [ -s /tmp/all_outdated.json ]; then
            # Convert allowed libraries to a format we can use with grep
            ALLOWED_PATTERN=$(echo "$ALLOWED_CLEAN" | tr ',' '|')
            
            # Extract package names that are NOT in the allowed list
            jq -r 'to_entries[] | .key' /tmp/all_outdated.json | grep -vE "^($ALLOWED_PATTERN)$" > /tmp/unauthorized_names.txt || true
            
            if [ -s /tmp/unauthorized_names.txt ]; then
                # Get full details for unauthorized packages
                while IFS= read -r pkg; do
                    if [ -n "$pkg" ]; then
                        pkg_info=$(jq -r --arg pkg "$pkg" '.[$pkg] | "\($pkg) - Current: \(.current) -> Latest: \(.latest)"' /tmp/all_outdated.json 2>/dev/null || echo "")
                        if [ -n "$pkg_info" ]; then
                            UNAUTHORIZED_OUTDATED="${UNAUTHORIZED_OUTDATED}${pkg_info}"$'\n'
                        fi
                    fi
                done < /tmp/unauthorized_names.txt
                
                # Remove trailing newline
                UNAUTHORIZED_OUTDATED=$(echo "$UNAUTHORIZED_OUTDATED" | sed 's/^$//')
            fi
        fi
        
        if [ -n "$UNAUTHORIZED_OUTDATED" ]; then
            echo "❌ UNAUTHORIZED OUTDATED DEPENDENCIES DETECTED:"
            echo "$UNAUTHORIZED_OUTDATED"
            echo ""
            echo "🚨 BUILD FAILED: These dependencies must be updated"
            
            # Clean up temporary files
            rm -f /tmp/all_outdated.json /tmp/unauthorized_names.txt
            exit 1
        else
            echo "✅ All outdated dependencies are in the allowed list"
            
            # Clean up temporary files
            rm -f /tmp/all_outdated.json /tmp/unauthorized_names.txt
        fi
    else
        echo "📋 No valid library names found in the allowed list"
        npm outdated
    fi
else
    echo "📋 No libraries are allowed to be outdated - checking all dependencies"
    npm outdated
fi

# Clean up any temporary files that might have been left behind
rm -f /tmp/all_outdated.json /tmp/unauthorized_names.txt /tmp/unauthorized_outdated.txt
