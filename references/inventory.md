# Local Development Environment Inventory

No machine inventory is bundled with the public skill.

Run the scanner after installation:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\refresh-inventory.ps1
```

The scanner replaces this file with a local inventory. Review the result before sharing it because it may contain machine names, software versions, drive labels, services, environment variables, and filesystem paths.
