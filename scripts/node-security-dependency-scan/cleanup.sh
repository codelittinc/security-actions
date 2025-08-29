#!/bin/bash

# Script to cleanup temporary files
# Usage: ./cleanup.sh

echo "🧹 Cleaning up temporary files..."

# Remove temporary files that might have been left behind
rm -f /tmp/all_outdated.json /tmp/unauthorized_names.txt /tmp/unauthorized_outdated.txt

echo "✅ Cleanup completed"
