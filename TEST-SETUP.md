# 🧪 Security Actions Testing Setup

## Quick Start (Docker Only!)

**Requirements:** Only Docker needs to be installed on your machine.

### 1. Run All Tests

```bash
make test
```

### 2. Run Specific Test Types

```bash
# Unit tests only
make test-unit

# JSON processing tests
make test-json

# Workflow syntax validation
make validate-syntax
```

### 3. Interactive Testing

```bash
# Start interactive container for debugging
make test-interactive

# Inside the container, you can run:
bats test/test-trufflehog-functions.bats
./test/test-json-processing.sh
./test/test-workflow-mock.sh
```

### 4. Test Specific Scenarios

```bash
# Test clean repository (no secrets)
make test-no-secrets

# Test repository with secrets
make test-secrets-found
```

## GitHub Actions Automated Testing

The `.github/workflows/test-security-action.yml` workflow automatically runs:

### ✅ **On Every Push/PR:**

- Unit tests for shell functions
- Workflow syntax validation
- Integration tests with clean repository
- Integration tests with test secrets
- Input combination testing
- Edge case testing

### ✅ **Test Coverage:**

- **Unit Tests:** Shell function logic
- **Integration Tests:** Full workflow execution
- **Syntax Tests:** GitHub Actions YAML validation
- **JSON Tests:** TruffleHog output parsing
- **Edge Cases:** Error handling, empty repos, long ignore lists
- **Input Tests:** All parameter combinations

### ✅ **Test Types:**

1. **Clean Repository Test** - Verifies no false positives
2. **Secrets Detection Test** - Verifies secrets are found (should fail)
3. **Ignore Keys Test** - Verifies ignore functionality works
4. **Input Matrix Test** - Tests all show_keys/notify_webhook combinations
5. **Edge Cases Test** - Tests unusual scenarios

## Manual Testing Commands

### Docker Commands

```bash
# Build test environment
docker-compose -f docker-compose.test.yml build

# Run all tests
docker-compose -f docker-compose.test.yml run --rm test-runner

# Interactive shell
docker-compose -f docker-compose.test.yml run --rm test-interactive

# Clean up
make clean
```

### Direct Testing (if you have dependencies installed)

```bash
# Unit tests
bats test/test-trufflehog-functions.bats

# JSON processing
./test/test-json-processing.sh

# Mock workflow
TEST_SCENARIO=secrets_found ./test/test-workflow-mock.sh

# Syntax validation
./test/test-workflow-syntax.sh
```

## Test Structure

```
test/
├── run-all-tests.sh              # Main test runner
├── test-trufflehog-functions.bats # Unit tests (bats framework)
├── test-workflow-mock.sh          # Mock workflow integration tests
├── test-json-processing.sh        # JSON parsing tests
├── test-workflow-syntax.sh        # GitHub Actions syntax validation
├── mock-trufflehog.sh             # Mock TruffleHog for controlled testing
├── fixtures/                     # Test data files
│   └── test-findings.json
└── README.md                     # This file
```

## Debugging Failed Tests

1. **Run interactive container:**

   ```bash
   make test-interactive
   ```

2. **Check specific test:**

   ```bash
   # Inside container
   bats test/test-trufflehog-functions.bats -t "specific test name"
   ```

3. **Debug workflow logic:**

   ```bash
   # Test with specific scenario
   TEST_SCENARIO=secrets_found ./test/test-workflow-mock.sh
   ```

4. **Validate JSON processing:**
   ```bash
   ./test/test-json-processing.sh
   ```

## Adding New Tests

1. **Add unit test:** Edit `test/test-trufflehog-functions.bats`
2. **Add integration test:** Edit `test/test-workflow-mock.sh`
3. **Add JSON test:** Edit `test/test-json-processing.sh`
4. **Add GitHub Actions test:** Edit `.github/workflows/test-security-action.yml`

## Test Philosophy

- **🔒 Security First:** Never use real secrets in tests
- **🐋 Docker Isolated:** All tests run in containers
- **🚀 Fast Feedback:** Unit tests run quickly
- **🎯 Comprehensive:** Cover all major functionality
- **🔄 Automated:** Tests run on every change
- **📊 Visible:** Clear reporting of test results
