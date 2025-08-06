Usage on any Codelitt repository

```
name: Security Check

on:
  push:
    branches: ["**"]
  pull_request:
    branches: [main, develop, master]

jobs:
  security-scan:
    uses: codelittinc/security-actions/.github/workflows/security.yml@main
    secrets:
      webhook_url: ${{ secrets.SECURITY_WEBHOOK_URL }}
```

Notice that the SECURITY_WEBHOOK_URL will be defined in the organization level. You can assume it will be available for your project.
If you need a specific URL, you can set it on your repository
