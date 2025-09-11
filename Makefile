# Security Actions Testing Makefile

.PHONY: help test test-unit test-integration test-docker test-interactive clean build

# Default target
help:
	@echo "Security Actions Testing Commands"
	@echo "================================="
	@echo "make test              - Run all tests in Docker"
	@echo "make test-unit         - Run only unit tests"
	@echo "make test-integration  - Run only integration tests"
	@echo "make test-json         - Run only JSON processing tests"
	@echo "make test-interactive  - Start interactive Docker container for testing"
	@echo "make build             - Build Docker test image"
	@echo "make clean             - Clean up Docker images and containers"
	@echo ""
	@echo "Docker Requirements:"
	@echo "- Docker must be installed and running"
	@echo "- No other dependencies needed!"

# Run all tests
test:
	@echo "🚀 Running all tests in Docker..."
	docker compose -f docker-compose.test.yml run --rm test-runner

# Run only unit tests
test-unit:
	@echo "🧪 Running unit tests..."
	docker compose -f docker-compose.test.yml run --rm test-unit-only

# Run only JSON processing tests
test-json:
	@echo "📊 Running JSON processing tests..."
	docker compose -f docker-compose.test.yml run --rm test-json-only

# Run integration tests (requires GitHub Actions environment)
test-integration:
	@echo "🔗 Running integration tests..."
	@echo "Note: Full integration tests require GitHub Actions environment"
	@echo "Running local integration tests only..."
	docker compose -f docker-compose.test.yml run --rm test-runner ./test/test-workflow-mock.sh

# Start interactive container for debugging
test-interactive:
	@echo "🐚 Starting interactive Docker container..."
	@echo "Use this to debug tests or run commands manually"
	docker compose -f docker-compose.test.yml run --rm test-interactive

# Build Docker test image
build:
	@echo "🏗️  Building Docker test image..."
	docker compose -f docker-compose.test.yml build

# Clean up Docker resources
clean:
	@echo "🧹 Cleaning up Docker resources..."
	docker compose -f docker-compose.test.yml down --rmi all --volumes --remove-orphans
	docker system prune -f

# Quick smoke test
smoke-test:
	@echo "💨 Running quick smoke test..."
	docker compose -f docker-compose.test.yml run --rm test-runner bash -c "echo '✅ Docker environment working'"

# Test specific scenario
test-scenario:
	@echo "🎭 Testing specific scenario: $(SCENARIO)"
	docker compose -f docker-compose.test.yml run --rm -e TEST_SCENARIO=$(SCENARIO) test-runner ./test/test-workflow-mock.sh

# Examples of scenario testing
test-no-secrets:
	@$(MAKE) test-scenario SCENARIO=no_secrets

test-secrets-found:
	@$(MAKE) test-scenario SCENARIO=secrets_found

# Validate workflow syntax
validate-syntax:
	@echo "📝 Validating workflow syntax..."
	docker compose -f docker-compose.test.yml run --rm test-runner ./test/test-workflow-syntax.sh

# Show test coverage
coverage:
	@echo "📊 Test Coverage Report"
	@echo "======================="
	@echo "✅ Unit Tests: Shell functions"
	@echo "✅ Integration Tests: Mock workflow execution"
	@echo "✅ Syntax Tests: GitHub Actions YAML validation"
	@echo "✅ JSON Processing: TruffleHog output parsing"
	@echo "✅ Edge Cases: Error handling and fallbacks"
	@echo ""
	@echo "Run 'make test' to execute all tests"
