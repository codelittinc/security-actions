#!/bin/bash

# Function to determine scan range
get_scan_range() {
  local DEFAULT_BRANCH="$1"
  local CURRENT_BRANCH="$2"
  local BEFORE_COMMIT="$3"

  if [ "$(printf %q "$CURRENT_BRANCH")" = "$(printf %q "$DEFAULT_BRANCH")" ]; then
    # On default branch - scan only the pushed commits
    if [ "$(printf %q "$BEFORE_COMMIT")" = "0000000000000000000000000000000000000000" ] || [ -z "$BEFORE_COMMIT" ]; then
      echo "HEAD~1"
    else
      echo "$BEFORE_COMMIT"
    fi
  else
    # On feature branch - scan all commits not in default branch
    echo "origin/$DEFAULT_BRANCH"
  fi
}

# Function to filter out ignored keys
filter_ignored_keys() {
  local INPUT_FILE="$1"
  local OUTPUT_FILE="$2"
  local IGNORE_KEYS="$3"

  if [ -z "$IGNORE_KEYS" ]; then
    # No keys to ignore, just copy the input to output
    cp "$INPUT_FILE" "$OUTPUT_FILE"
    return 0
  fi

  echo "🔍 Filtering out ignored keys..."
  
  # Initialize output file
  touch "$OUTPUT_FILE"
  
  # Process each line
  while IFS= read -r line; do
    if echo "$line" | grep -q '"SourceMetadata"'; then
      # This is a finding line - check if it should be ignored
      local SHOULD_IGNORE=false
      
      # Convert comma-separated ignore keys to array and check each one
      IFS=',' read -ra IGNORE_ARRAY <<< "$IGNORE_KEYS"
      for ignore_key in "${IGNORE_ARRAY[@]}"; do
        # Trim whitespace
        ignore_key=$(echo "$ignore_key" | xargs)
        
        # Check if the Raw field contains this ignored key
        if echo "$line" | grep -qi "\"Raw\".*\"$ignore_key\""; then
          echo "🚫 Ignoring finding containing key: $ignore_key"
          SHOULD_IGNORE=true
          break
        fi
      done
      
      # Only add to output if not ignored
      if [ "$SHOULD_IGNORE" = false ]; then
        echo "$line" >> "$OUTPUT_FILE"
      fi
    else
      # Non-finding lines (log messages, etc.) - keep them
      echo "$line" >> "$OUTPUT_FILE"
    fi
  done < "$INPUT_FILE"
  
  echo "✅ Filtering completed"
}
