# Scripts Directory

This directory contains shell scripts organized by workflow to improve maintainability and testability.

## Structure

```
scripts/
├── README.md
└── node-security-dependency-scan/
    ├── run-npm-audit.sh
    ├── check-outdated-dependencies.sh
    ├── check-high-severity-vulnerabilities.sh
    ├── security-gate-check.sh
    └── cleanup.sh
```

## Node.js Security Dependency Scan Scripts

### `run-npm-audit.sh`

Runs npm audit with configurable audit level and continue-on-error behavior.

**Usage:** `./run-npm-audit.sh <audit_level> <continue_on_error>`

**Parameters:**

- `audit_level`: npm audit level (low, moderate, high, critical)
- `continue_on_error`: whether to continue on audit failure (true/false)

### `check-outdated-dependencies.sh`

Checks for outdated dependencies with filtering for allowed libraries.

**Usage:** `./check-outdated-dependencies.sh <allowed_libraries> <continue_on_error>`

**Parameters:**

- `allowed_libraries`: comma-separated list of libraries allowed to be outdated
- `continue_on_error`: whether to continue on failure (true/false)

### `check-high-severity-vulnerabilities.sh`

Checks for high severity vulnerabilities in npm audit and OWASP reports.

**Usage:** `./check-high-severity-vulnerabilities.sh <continue_on_error>`

**Parameters:**

- `continue_on_error`: whether to continue on failure (true/false)

### `security-gate-check.sh`

Performs final security gate check before allowing build to proceed.

**Usage:** `./security-gate-check.sh <audit_level> <continue_on_error>`

**Parameters:**

- `audit_level`: npm audit level threshold
- `continue_on_error`: whether to continue on failure (true/false)

### `cleanup.sh`

Cleans up temporary files created during the workflow execution.

**Usage:** `./cleanup.sh`

## Benefits of This Structure

1. **Maintainability**: Each script has a single responsibility and can be easily modified
2. **Testability**: Individual scripts can be tested independently
3. **Reusability**: Scripts can be reused in other workflows or run locally
4. **Debugging**: Easier to debug issues by running specific scripts
5. **Version Control**: Better tracking of changes to specific functionality
6. **Documentation**: Each script can have its own documentation and examples

## Adding New Scripts

When adding new scripts:

1. Create the script in the appropriate workflow folder
2. Make it executable: `chmod +x scripts/workflow-name/script-name.sh`
3. Update this README with usage information
4. Consider adding tests for the script functionality

## Testing Scripts Locally

You can test individual scripts locally by:

1. Setting up the required environment (Node.js, npm, etc.)
2. Running the script with appropriate parameters
3. Checking the output and exit codes

Example:

```bash
cd scripts/node-security-dependency-scan
./run-npm-audit.sh moderate false
```
