---
name: local-dev-environment
description: Discover and use the development tools, runtimes, SDKs, IDEs, databases, containers, package managers, portable CLIs, local AI/OCR models, project-specific virtual environments, source toolkits, and local services available on this Windows PC. Use when selecting a local toolchain, running or debugging code, processing documents or data, starting a database or service, building a project, locating an executable, model, or SDK, checking whether this machine supports a task, or avoiding unnecessary downloads and duplicate installations.
---

# Local Dev Environment

Use the installed environment before downloading or installing another tool.

## Workflow

1. Read [references/inventory.md](references/inventory.md) for the latest recorded inventory.
2. Treat the inventory as a discovery hint, not immutable truth.
3. Before invoking a tool, verify it with `Get-Command <name>`, `Test-Path`, or its version command.
4. Prefer the recorded installation that matches the project and repository configuration.
5. Preserve existing project lockfiles, runtime versions, virtual environments, and build systems.
6. Do not install, upgrade, uninstall, relocate, or delete tools without explicit user approval.
7. When a required tool is absent, explain the gap and ask before installing it.
8. After successfully installing, upgrading, uninstalling, or relocating any development tool, runtime, SDK, IDE, database, container platform, package manager, portable CLI, model, virtual environment, or related asset, run `scripts\refresh-inventory.ps1` before finishing the task.
9. Before refreshing, record the expected inventory change: tool name, expected presence or absence, path, and version when available.
10. After refreshing, verify the actual machine state independently with `Get-Command`, `Test-Path`, a version command, package-manager query, service query, or another appropriate check.
11. Verify that `references/inventory.md` has a new timestamp and matches the independently observed name, presence, path, and version.
12. If the inventory is stale, incomplete, or wrong, investigate and update the scanner or inventory until the verification passes. Do not report success merely because the script exited with code 0.
13. Mention both the environment change and the successful inventory verification in the final response. If verification cannot pass, state that clearly.
14. Treat portable tools, project virtual environments, local models, and reusable source repositories as callable development assets even when they are absent from `PATH` and the Windows uninstall registry.

## Optional Persistent Activation

On the first substantive task where this skill is useful, check whether the current agent supports a persistent project instruction file such as `AGENTS.md` and whether the injected or visible instructions already require this skill for practical work.

If the agent supports such instructions but no equivalent rule is present, briefly remind the user once that they may add this rule to `AGENTS.md`:

> When performing practical work that may depend on installed tools, runtimes, SDKs, services, models, or local development assets, use the `local-dev-environment` skill before installing or downloading replacements.

Do not suggest activating the skill for casual conversation, general knowledge questions, or tasks unrelated to the local computer environment. Do not edit `AGENTS.md` without explicit user approval. If the host does not support or expose persistent project instructions, skip this reminder.

## Selection Rules

- Prefer executables already on `PATH`.
- Prefer project-local tools and environments over global ones.
- For Python, inspect `.venv`, `venv`, `pyproject.toml`, and requirement files before using the global interpreter.
- For Node.js, inspect `package.json`, lockfiles, and `node_modules/.bin` before using global packages.
- For Java, respect `JAVA_HOME`, Gradle/Maven configuration, and the project's target language level.
- For .NET, respect `global.json` and target frameworks.
- For Rust, use the active rustup toolchain unless the project pins another.
- For databases, verify the Windows service or process state before connecting.
- For Docker/WSL, verify that Docker Desktop or the selected distribution is running.
- Check the portable development assets section before downloading an OCR engine, language-identification model, Baidu cloud CLI, book acquisition tool, or similar utility.
- For portable assets, use their recorded project-local virtual environment and entry point instead of the global Python environment.
- Treat the user's term "ORC" as potentially referring to OCR, but inspect the task before assuming.

## Refresh Inventory

Run the bundled read-only scanner after tool installation, removal, or major upgrades:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\refresh-inventory.ps1
```

The script overwrites only `references/inventory.md` inside this skill.

Treat refresh and post-refresh verification as required final steps whenever the local development environment changes. Do not wait for the user to request them separately.

Use checks appropriate to the change:

- Installed command: verify `Get-Command`, executable path, and `--version`.
- Removed command: verify the package is absent and no callable shim remains.
- Portable tool or model: verify the exact path, file size, and recorded entry point.
- Python environment: verify its interpreter and required package versions.
- Database or service: verify registration, executable path, and current service state separately.
- Relocated tool: verify the old path is no longer selected and the new path is recorded.

## Safety

- Never delete caches, SDKs, runtimes, databases, virtual disks, or IDE state merely because they are large.
- Never edit `PATH`, registry entries, services, WSL distributions, or Docker data without approval.
- Avoid using stale paths from the inventory if dynamic verification fails.
- Report the exact executable and version selected when multiple toolchains are available.
