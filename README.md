# Readme

Details about script:

1. It does not find keys if they are submited in the first commit of the repository

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
