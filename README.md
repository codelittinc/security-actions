Usage on any Codelitt repository

```
name: Security Check

on:
  push:
    branches: ['**']
  pull_request:
    branches: [main, develop, master]

jobs:
  security-scan:
    uses: codelittinc/security-actions/.github/workflows/security.yml@main
```
