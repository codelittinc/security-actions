# Security Actions

Reusable GitHub Actions workflows for Codelitt repositories: **secret scanning** and **dependency vulnerability scanning**.

## What blocks and what does not

This is the important distinction, so it is worth stating up front:

| Workflow | What it finds | Blocks the build? |
| --- | --- | --- |
| `security.yml` | Secrets introduced by the commits being pushed | **Yes** |
| `security.yml` | Secrets already present in the working tree (opt-in) | No — advisory |
| `node-security-dependency-scan.yml` | Dependency vulnerabilities (`npm audit`, OWASP) | No — reporting only |

A newly committed credential is a live incident, so it blocks. A vulnerable dependency is something to schedule, so it is reported as a warning annotation and a job summary instead.

> These workflows are consumed at `@main` and are unpinned. Changes here take effect immediately in every repository that calls them.

---

## Secret scanning (`security.yml`)

```yaml
name: Security Check

on:
  push:
    branches: ["**"]

jobs:
  security-scan:
    uses: codelittinc/security-actions/.github/workflows/security.yml@main
    with:
      show_keys: false
      notify_webhook: true
      ignore_keys: "MY_TEST_KEY,DEV_CREDENTIAL"
      scan_filesystem: false
    secrets:
      webhook_url: ${{ secrets.SECURITY_WEBHOOK_URL }}
```

### Inputs

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `show_keys` | boolean | `false` | Show the actual secret values in the logs. Leave off unless you are actively triaging |
| `notify_webhook` | boolean | `true` | Send webhook alerts for newly introduced secrets |
| `ignore_keys` | string | `""` | Comma-separated values to treat as false positives |
| `scan_filesystem` | boolean | `false` | Also scan the whole working tree for pre-existing secrets. **Advisory only — never blocks** |

`webhook_url` is only required when `notify_webhook` is `true`.

### How it works

1. **Scan.** TruffleHog scans the commits being pushed — on a feature branch, every commit not yet in the default branch. With `scan_filesystem: true` it also scans the checked-out working tree.
2. **Split by origin.** Secrets introduced by the pushed commits **block**. Secrets merely present in the tree are **advisory**.
3. **Filter.** `ignore_keys` matches are dropped from both sets, and duplicates across the two scans are collapsed. A secret found by *both* scans counts as newly introduced and stays blocking.
4. **Report.** Blocking and advisory findings are listed separately, with a job summary. Values are hidden unless `show_keys: true`.
5. **Notify.** Webhook alerts fire only for newly introduced secrets, so a pre-existing finding does not re-page on every build. Payloads redact `Raw`/`RawV2` before leaving the runner.
6. **Gate.** The build fails only if the push introduced a secret. A scan that errors or never ran also blocks — an unrun scan is not a pass.

`validate-inputs` and `secret-scan` run in parallel; the gate waits on both.

### Why pre-existing secrets do not block

A secret already committed cannot be fixed by whichever PR happens to trip over it, and **rotating the credential does not remove the old string from the file**. If those blocked, every future PR would be stuck until someone rewrote history.

The right response is to rotate the key, then clean up the leftover string — or add it to `ignore_keys` — as its own piece of work. Turning on `scan_filesystem` gives you that backlog without gating merges on it.

### Choosing `ignore_keys`

Use it for values that are genuinely not credentials: committed test fixtures, documentation examples, or detector false positives.

A common false positive is a 40-character hex string — a pinned git SHA in a lockfile, for instance — matching the shape of a legacy GitHub token. Before ignoring anything, confirm it is not live. Once a real credential has been pushed, treat it as compromised and rotate it; adding it to `ignore_keys` only hides it.

Keep the list short, review it periodically, and record why each entry is there.

---

## Dependency scanning (`node-security-dependency-scan.yml`)

```yaml
name: Node.js Security Scan

on:
  push:
    branches: ["**"]

jobs:
  node-security-scan:
    uses: codelittinc/security-actions/.github/workflows/node-security-dependency-scan.yml@main
    with:
      project_name: "my-node-project"
      node_version: "24"
      audit_level: "moderate"
      enable_retired: true
      run_owasp: true
```

**This workflow never fails the build.** Findings appear as warning annotations, a severity-count table in the job summary, and the full `npm audit` output in the log.

### Inputs

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `project_name` | string | `"node-project"` | Project name for OWASP Dependency Check |
| `node_version` | string | `"18"` | Node.js version to use |
| `audit_level` | string | `"moderate"` | Threshold passed to `npm audit`. Reporting only |
| `fail_on_cvss` | string | `"7"` | CVSS threshold passed to OWASP. Reporting only |
| `enable_retired` | boolean | `true` | Enable retired CVE checks |
| `run_owasp` | boolean | `true` | Run the OWASP job |
| `continue_on_error` | boolean | `false` | **Deprecated and ignored.** Nothing fails, so there is nothing to continue past |

### Jobs

- **`npm-audit`** — runs `npm audit`, reports counts by severity, and annotates each critical/high package. Also runs `npm audit signatures` to verify packages against npm's signed registry attestations, which catches tampering and republished typosquats that a CVE feed does not cover.
- **`owasp-dependency-check`** — runs OWASP Dependency Check and uploads the HTML report as an artifact.

The two run **in parallel**, so the slow OWASP pass does not delay npm audit feedback.

### A caveat on OWASP

The underlying action runs `dependency-check` with `--noupdate`, so its CVE database is whatever was baked into the action's Docker image rather than the live NVD feed. For npm packages, `npm audit` is the authoritative and current source. Setting `run_owasp: false` is reasonable for pure Node repositories.

---

## Maintenance

- **TruffleHog version** is pinned in `security.yml` (`TRUFFLEHOG_VERSION`). Keep it current: each release adds detectors, and an outdated binary silently misses credential types it has no rules for — it reports clean rather than erroring.
- **Third-party actions** are pinned by commit SHA. A mutable ref inside a security pipeline is the exact supply-chain exposure these workflows exist to catch.

## Examples

See `examples/`:

- `node-security-example.yml` — dependency scanning
- `security-with-ignore-keys.yml` — ignore-key configurations for secret detection

## Requirements

- GitHub Actions
- A webhook URL, only when `notify_webhook` is enabled
- TruffleHog is installed automatically, with checksum verification

## Contributing

Issues and enhancement requests welcome.
