#!/bin/bash
# Mock TruffleHog for testing

# Parse command line arguments
OUTPUT_FILE=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --since-commit=*)
      SINCE_COMMIT="${1#*=}"
      shift
      ;;
    *)
      if [[ "$1" == ">" ]]; then
        OUTPUT_FILE="$2"
        shift 2
        break
      fi
      shift
      ;;
  esac
done

# If no output file specified, get it from redirection
if [ -z "$OUTPUT_FILE" ]; then
  OUTPUT_FILE="/dev/stdout"
fi

# Simulate TruffleHog output based on test scenario
if [ "$TEST_SCENARIO" = "secrets_found" ]; then
  cat > "$OUTPUT_FILE" << 'EOF'
{"DetectorName":"Github","SourceMetadata":{"Data":{"Git":{"commit":"abc123","file":"secrets.txt","email":"test@example.com","repository":"test/repo","timestamp":"2025-09-11 10:00:00 +0000","line":1}}},"Raw":"ghp_test123","StartLine":null,"EndLine":null}
EOF
  exit 1  # TruffleHog returns 1 when secrets found
elif [ "$TEST_SCENARIO" = "no_secrets" ]; then
  echo '{"level":"info","msg":"No secrets found"}' > "$OUTPUT_FILE"
  exit 0
else
  # Default: no secrets
  echo '{"level":"info","msg":"Scan completed"}' > "$OUTPUT_FILE"
  exit 0
fi
