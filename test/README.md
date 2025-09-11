# Testing Security Actions

## Local Testing

### 1. Install Dependencies

```bash
# Install act for local GitHub Actions testing
brew install act  # macOS
# or
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Install bats for shell script testing
npm install -g bats  # or use package manager
```

### 2. Run Unit Tests

```bash
# Test shell functions
chmod +x scripts/trufflehog-functions.sh
bats test/test-trufflehog-functions.bats
```

### 3. Test Workflow Locally

```bash
# Test with mock secrets
export TEST_SCENARIO=secrets_found
act workflow_call --secret webhook_url=https://httpbin.org/post

# Test clean run
export TEST_SCENARIO=no_secrets
act workflow_call --secret webhook_url=https://httpbin.org/post
```

### 4. Test Different Scenarios

```bash
# Test with show_keys enabled
act workflow_call \
  --input show_keys=true \
  --input notify_webhook=false \
  --secret webhook_url=https://httpbin.org/post

# Test with ignore keys
act workflow_call \
  --input ignore_keys="TEST_KEY,DEMO_SECRET" \
  --secret webhook_url=https://httpbin.org/post
```

## Integration Testing

### Create Test Repository

```bash
# Create a test repo with secrets
mkdir test-security-repo
cd test-security-repo
git init
echo "API_KEY=sk_test_12345" > .env
git add .env
git commit -m "Add test secret"

# Call your security workflow
# (In .github/workflows/test.yml)
```

## Mock Testing

Replace TruffleHog with mock for controlled testing:

```bash
# In your test environment
export PATH="./test:$PATH"  # Put mock-trufflehog.sh in PATH
chmod +x test/mock-trufflehog.sh
```

## Test Cases to Cover

1. ✅ No secrets found
2. ✅ Secrets found with show_keys=false
3. ✅ Secrets found with show_keys=true
4. ✅ Ignore keys functionality
5. ✅ Webhook notifications enabled/disabled
6. ✅ Different file types and locations
7. ✅ Multiple secrets in different commits
8. ✅ Edge cases (empty repos, binary files, etc.)
