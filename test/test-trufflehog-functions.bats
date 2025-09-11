#!/usr/bin/env bats

# Load the functions to test
load '../scripts/trufflehog-functions.sh'

@test "get_scan_range returns correct range for default branch" {
  result=$(get_scan_range "main" "main" "abc123")
  [ "$result" = "abc123" ]
}

@test "get_scan_range returns correct range for feature branch" {
  result=$(get_scan_range "main" "feature-branch" "abc123")
  [ "$result" = "origin/main" ]
}

@test "get_scan_range handles zero commit" {
  result=$(get_scan_range "main" "main" "0000000000000000000000000000000000000000")
  [ "$result" = "HEAD~1" ]
}

@test "filter_ignored_keys filters out specified keys" {
  # Create test input file with proper SourceMetadata structure
  echo '{"Raw": "AKIATEST123", "DetectorName": "AWS", "SourceMetadata": {"Data": {"Git": {"file": "test.txt"}}}}' > test_input.json
  echo '{"Raw": "secret456", "DetectorName": "Generic", "SourceMetadata": {"Data": {"Git": {"file": "other.txt"}}}}' >> test_input.json
  
  filter_ignored_keys "test_input.json" "test_output.json" "AKIATEST123"
  
  # Should only contain the second finding
  [ $(wc -l < test_output.json) -eq 1 ]
  grep -q "secret456" test_output.json
  
  # Cleanup
  rm -f test_input.json test_output.json
}
