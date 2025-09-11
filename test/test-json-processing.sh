#!/bin/bash
set -e

echo "🔍 Testing JSON processing logic"

# Test the jq commands used in the workflow
echo "Testing file path extraction..."

# Create test finding JSON
cat > test_finding.json << 'EOF'
{
  "DetectorName": "Github",
  "SourceMetadata": {
    "Data": {
      "Git": {
        "commit": "abc123def456",
        "file": "config/secrets.yml",
        "email": "test@example.com",
        "repository": "https://github.com/test/repo",
        "timestamp": "2025-09-11 10:00:00 +0000",
        "line": 5
      }
    }
  },
  "Raw": "ghp_test123456789",
  "StartLine": null,
  "EndLine": null
}
EOF

echo "Test finding JSON:"
cat test_finding.json

echo ""
echo "Testing file path extraction (show_keys=false):"
cat test_finding.json | jq -r '
  if (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) then
    .DetectorName + " in " + ((.SourceMetadata.Git.File // .SourceMetadata.Data.Filesystem.File // .SourceMetadata.Data.Git.File // .SourceMetadata.Data.Git.file // .file) // 
    (if .SourceMetadata.Git.Repository then "repository: " + .SourceMetadata.Git.Repository else null end) //
    (if (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) then "commit: " + ((.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit)[0:8]) else null end) //
    "unknown location") + " (Commit: " + (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) + ")"
  else
    .DetectorName + " in " + ((.SourceMetadata.Git.File // .SourceMetadata.Data.Filesystem.File // .SourceMetadata.Data.Git.File // .SourceMetadata.Data.Git.file // .file) // 
    (if .SourceMetadata.Git.Repository then "repository: " + .SourceMetadata.Git.Repository else null end) //
    (if (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) then "commit: " + ((.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit)[0:8]) else null end) //
    "unknown location")
  end
'

echo ""
echo "Testing file path extraction (show_keys=true):"
cat test_finding.json | jq -r '
  if (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) then
    .DetectorName + " in " + ((.SourceMetadata.Git.File // .SourceMetadata.Data.Filesystem.File // .SourceMetadata.Data.Git.File // .SourceMetadata.Data.Git.file // .file) // 
    (if .SourceMetadata.Git.Repository then "repository: " + .SourceMetadata.Git.Repository else null end) //
    (if (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) then "commit: " + ((.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit)[0:8]) else null end) //
    "unknown location") + " (Commit: " + (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) + "): " + .Raw
  else
    .DetectorName + " in " + ((.SourceMetadata.Git.File // .SourceMetadata.Data.Filesystem.File // .SourceMetadata.Data.Git.File // .SourceMetadata.Data.Git.file // .file) // 
    (if .SourceMetadata.Git.Repository then "repository: " + .SourceMetadata.Git.Repository else null end) //
    (if (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) then "commit: " + ((.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit)[0:8]) else null end) //
    "unknown location") + ": " + .Raw
  end
'

# Test edge case: missing file path
echo ""
echo "Testing edge case: missing file path"
cat > test_finding_no_file.json << 'EOF'
{
  "DetectorName": "Generic",
  "SourceMetadata": {
    "Data": {
      "Git": {
        "commit": "xyz789",
        "email": "test@example.com",
        "repository": "https://github.com/test/repo",
        "timestamp": "2025-09-11 10:00:00 +0000"
      }
    }
  },
  "Raw": "secret_value_123"
}
EOF

echo "Testing with missing file path:"
cat test_finding_no_file.json | jq -r '
  if (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) then
    .DetectorName + " in " + ((.SourceMetadata.Git.File // .SourceMetadata.Data.Filesystem.File // .SourceMetadata.Data.Git.File // .SourceMetadata.Data.Git.file // .file) // 
    (if .SourceMetadata.Git.Repository then "repository: " + .SourceMetadata.Git.Repository else null end) //
    (if (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) then "commit: " + ((.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit)[0:8]) else null end) //
    "unknown location") + " (Commit: " + (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) + ")"
  else
    .DetectorName + " in " + ((.SourceMetadata.Git.File // .SourceMetadata.Data.Filesystem.File // .SourceMetadata.Data.Git.File // .SourceMetadata.Data.Git.file // .file) // 
    (if .SourceMetadata.Git.Repository then "repository: " + .SourceMetadata.Git.Repository else null end) //
    (if (.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit) then "commit: " + ((.SourceMetadata.Git.Commit // .SourceMetadata.Data.Git.commit)[0:8]) else null end) //
    "unknown location")
  end
'

# Cleanup
rm -f test_finding.json test_finding_no_file.json

echo ""
echo "✅ JSON processing tests completed successfully"
