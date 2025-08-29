# Security Actions

A comprehensive GitHub Actions workflow for detecting secrets and sensitive information in your codebase using TruffleHog.

## Features

- **Secret Detection**: Uses TruffleHog to scan for secrets, API keys, and sensitive data
- **Configurable Ignore Keys**: Ignore known false positive keys that are safe to exclude
- **Webhook Notifications**: Send security alerts to external systems
- **Flexible Configuration**: Customize behavior based on your security requirements
- **Comprehensive Scanning**: Scans commits, branches, and provides detailed reporting

## Usage

### Basic Usage

```yaml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  security-scan:
    uses: ./.github/workflows/security.yml
    with:
      show_keys: false
      notify_webhook: true
      ignore_keys: "AWS_ACCESS_KEY_ID,API_KEY"
    secrets:
      webhook_url: ${{ secrets.SECURITY_WEBHOOK_URL }}
```

### Configuration Options

| Parameter        | Type    | Required | Default | Description                                   |
| ---------------- | ------- | -------- | ------- | --------------------------------------------- |
| `show_keys`      | boolean | No       | `false` | Whether to show the actual keys found in logs |
| `notify_webhook` | boolean | No       | `true`  | Whether to send webhook notifications         |
| `ignore_keys`    | string  | No       | `""`    | Comma-separated list of keys to ignore        |

### Ignoring False Positive Keys

The `ignore_keys` parameter allows you to specify keys that should be ignored as false positives. This is useful when you have:

- Test credentials that are intentionally committed
- Example API keys that are not real
- Development keys that are safe to ignore
- Keys that are known to be false positives

#### Example: Ignore Common False Positives

```yaml
jobs:
  security-scan:
    uses: ./.github/workflows/security.yml
    with:
      ignore_keys: "AWS_ACCESS_KEY_ID,API_KEY,ACCESS_TOKEN,DEV_CREDENTIAL"
    secrets:
      webhook_url: ${{ secrets.SECURITY_WEBHOOK_URL }}
```

#### Example: Project-Specific Ignore Keys

```yaml
jobs:
  security-scan:
    uses: ./.github/workflows/security.yml
    with:
      ignore_keys: "MY_PROJECT_KEY,DEV_API_KEY,TEST_CREDENTIAL"
    secrets:
      webhook_url: ${{ secrets.SECURITY_WEBHOOK_URL }}
```

#### Example: Comprehensive Ignore List

```yaml
jobs:
  security-scan:
    uses: ./.github/workflows/security.yml
    with:
      ignore_keys: "AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,API_KEY,ACCESS_TOKEN,BEARER_TOKEN,JWT_SECRET,PRIVATE_KEY"
    secrets:
      webhook_url: ${{ secrets.SECURITY_WEBHOOK_URL }}
```

### Strict Mode (No Ignored Keys)

For maximum security, you can run without ignoring any keys:

```yaml
jobs:
  security-scan:
    uses: ./.github/workflows/security.yml
    with:
      show_keys: false
      notify_webhook: true
      # No ignore_keys specified - will fail on any detected secrets
    secrets:
      webhook_url: ${{ secrets.SECURITY_WEBHOOK_URL }}
```

## How It Works

1. **Scanning**: TruffleHog scans your repository for secrets and sensitive data
2. **Filtering**: If `ignore_keys` is specified, the workflow filters out findings containing those keys
3. **Reporting**: Results are processed and reported with appropriate security alerts
4. **Notification**: Webhook notifications are sent if enabled
5. **Security Gate**: The workflow fails if any non-ignored secrets are detected

## Security Considerations

- **Use Sparingly**: Only ignore keys that you are absolutely certain are safe
- **Regular Review**: Periodically review your ignore list to ensure it's still appropriate
- **Documentation**: Document why specific keys are ignored for team awareness
- **Testing**: Test your ignore configuration with known false positives

## Examples

See the `examples/` directory for complete workflow examples:

- `node-security-example.yml` - Node.js security dependency scanning with allowed outdated libraries
- `security-with-ignore-keys.yml` - Various ignore key configurations for secret detection

## Node.js Security Dependency Scanning

In addition to secret detection, this repository also provides a comprehensive Node.js security workflow that scans for:

- **Security Vulnerabilities**: Uses npm audit to detect known vulnerabilities
- **Outdated Dependencies**: Checks for outdated packages that may have security fixes
- **OWASP Dependency Check**: Comprehensive vulnerability scanning using OWASP tools
- **Configurable Allowed Libraries**: Specify libraries that are allowed to be outdated

### Node.js Security Workflow Usage

```yaml
name: Node.js Security Scan

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  security-scan:
    uses: ./.github/workflows/node-security-dependency-scan.yml
    with:
      project_name: "my-node-project"
      node_version: "18"
      fail_on_cvss: "7"
      enable_retired: true
      audit_level: "moderate"
      continue_on_error: false
      allowed_outdated_libraries: "@hapi/address,react-router-dom,tabbable"
```

### Node.js Security Configuration Options

| Parameter                    | Type    | Required | Default          | Description                                              |
| ---------------------------- | ------- | -------- | ---------------- | -------------------------------------------------------- |
| `project_name`               | string  | No       | `"node-project"` | Project name for OWASP Dependency Check                  |
| `node_version`               | string  | No       | `"18"`           | Node.js version to use                                   |
| `fail_on_cvss`               | string  | No       | `"7"`            | CVSS score threshold to fail the build                   |
| `enable_retired`             | boolean | No       | `true`           | Enable retired CVE checks                                |
| `audit_level`                | string  | No       | `"moderate"`     | npm audit level threshold                                |
| `continue_on_error`          | boolean | No       | `false`          | Continue workflow execution even if security checks fail |
| `allowed_outdated_libraries` | string  | No       | `""`             | Comma-separated list of libraries allowed to be outdated |

### Allowing Outdated Libraries

The `allowed_outdated_libraries` parameter allows you to specify libraries that are intentionally kept at older versions. This is useful when:

- You need to maintain compatibility with specific versions
- Breaking changes in newer versions would require significant refactoring
- The library is deprecated but still functional for your use case
- You're planning a migration but need time to complete it

#### Example: Allow Specific Libraries to Be Outdated

```yaml
jobs:
  security-scan:
    uses: ./.github/workflows/node-security-dependency-scan.yml
    with:
      allowed_outdated_libraries: "@hapi/address,react-router-dom,tabbable"
```

**Note**: Only the specified libraries will be allowed to be outdated. Any other outdated dependencies will still cause the build to fail, ensuring security while providing flexibility for specific cases.

## Requirements

- GitHub Actions
- A webhook URL for notifications (required secret)
- TruffleHog will be automatically installed during execution

## Contributing

Feel free to submit issues and enhancement requests!
