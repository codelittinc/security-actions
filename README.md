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
| `scan_filesystem` | boolean | No      | `false` | Also scan the whole working tree. **Advisory only — never blocks** |

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

1. **Scanning**: TruffleHog scans the commits being pushed (on a feature branch,
   every commit not yet in the default branch). With `scan_filesystem: true` it
   additionally scans the whole working tree.
2. **Splitting**: Findings are separated by origin. Secrets introduced by the
   pushed commits **block**. Secrets merely present in the working tree are
   **advisory** and never fail the build.
3. **Filtering**: If `ignore_keys` is specified, matching findings are dropped
   from both sets, and duplicates across the two scans are collapsed.
4. **Reporting**: Blocking and advisory findings are reported separately, with a
   job summary. Key values are hidden unless `show_keys: true`.
5. **Notification**: Webhook alerts fire only for newly introduced secrets, so a
   pre-existing finding does not re-page on every build.
6. **Security Gate**: The build fails only if the push introduced a secret. A
   scan that errors or never ran also blocks — an unrun scan is not a pass.

### Why pre-existing secrets do not block

A secret already committed cannot be fixed by whichever PR happens to trip over
it, and rotating the credential does not remove the old string from the file. If
those blocked, every future PR would be stuck until someone rewrote history. The
correct response is to rotate the key, then clean up the string (or add it to
`ignore_keys`) as its own piece of work.

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
      run_owasp: true
```

> **This workflow is reporting-only — it never fails the build.** Vulnerabilities
> are surfaced as warning annotations and a job summary table so they can be
> reviewed. Secret scanning (`security.yml`) still blocks.

### Node.js Security Configuration Options

| Parameter                    | Type    | Required | Default          | Description                                              |
| ---------------------------- | ------- | -------- | ---------------- | -------------------------------------------------------- |
| `project_name`      | string  | No       | `"node-project"` | Project name for OWASP Dependency Check                                       |
| `node_version`      | string  | No       | `"18"`           | Node.js version to use                                                        |
| `fail_on_cvss`      | string  | No       | `"7"`            | CVSS threshold passed to OWASP. Reporting only — does not fail the build      |
| `enable_retired`    | boolean | No       | `true`           | Enable retired CVE checks                                                     |
| `audit_level`       | string  | No       | `"moderate"`     | Threshold passed to `npm audit`. Reporting only — does not fail the build     |
| `run_owasp`         | boolean | No       | `true`           | Run the OWASP job. It is slow; `npm audit` alone covers most npm cases        |
| `continue_on_error` | boolean | No       | `false`          | **Deprecated and ignored.** Nothing fails, so there is nothing to continue past |

The `npm-audit` and `owasp-dependency-check` jobs run in parallel, so the slow
OWASP pass no longer delays npm audit feedback.

## Requirements

- GitHub Actions
- A webhook URL for notifications (optional — only needed when `notify_webhook` is true)
- TruffleHog will be automatically installed during execution

## Contributing

Feel free to submit issues and enhancement requests!
