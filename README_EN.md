# Local Dev Environment Skill

**Language: [简体中文](README.md) | English**

[![GitHub stars](https://img.shields.io/github/stars/Hachimeder/local-dev-environment-skill?style=social)](https://github.com/Hachimeder/local-dev-environment-skill/stargazers)
[![Release](https://img.shields.io/github/v/release/Hachimeder/local-dev-environment-skill)](https://github.com/Hachimeder/local-dev-environment-skill/releases/latest)
[![Windows](https://img.shields.io/badge/platform-Windows-0078D4)](#)

> Before coding, building, or debugging, help your AI inventory and verify existing runtimes, SDKs, IDEs, databases, CLIs, local models, and project environments so it can reuse the right tools and avoid duplicate installations or version conflicts.

AI agents usually know how to install Python, Node.js, JDK, or Docker. What they often do not know is that your computer may already contain multiple versions, project virtual environments, portable CLIs, local models, and reusable source trees.

`local-dev-environment` is a Skill for Windows AI agents. It builds a local development-tool inventory, requires agents to verify the real environment before practical work, and refreshes and validates the inventory after tools are installed, upgraded, removed, or relocated.

## Why Use It

- **Avoid duplicate installations**: inspect `PATH`, the Windows registry, project environments, and common development directories first.
- **Select the right version**: respect lockfiles, virtual environments, `JAVA_HOME`, `global.json`, and project constraints.
- **Discover hidden assets**: find portable CLIs, local models, OCR tools, and source repositories that are not on `PATH`.
- **Track environment changes**: refresh the inventory after changes and independently verify that the result matches the machine.
- **Put safety first**: never install, delete, relocate, or change `PATH`, services, or the registry without explicit approval.
- **Activate only when useful**: use the Skill for practical work that depends on the local environment, not casual conversation or general questions.

## How It Works

```text
The user requests practical work
             ↓
The agent reads the environment inventory
             ↓
It verifies commands, paths, versions, and services
             ↓
It reuses the best available local tools
             ↓
It refreshes the inventory after environment changes
             ↓
It independently checks that the inventory matches reality
```

The inventory is a discovery hint, not immutable truth. Before invoking a tool, the agent must confirm it with version commands, `Get-Command`, `Test-Path`, package-manager queries, or service checks.

## Quick Installation

### Codex

```powershell
git clone https://github.com/Hachimeder/local-dev-environment-skill.git `
  "$HOME\.codex\skills\local-dev-environment"
```

### Claude Code

```powershell
git clone https://github.com/Hachimeder/local-dev-environment-skill.git `
  "$HOME\.claude\skills\local-dev-environment"
```

### TRAE

```powershell
git clone https://github.com/Hachimeder/local-dev-environment-skill.git `
  "$HOME\.trae-cn\skills\local-dev-environment"
```

You can also download the ZIP from [Releases](https://github.com/Hachimeder/local-dev-environment-skill/releases/latest) and extract it into the corresponding skills directory.

Generate the local inventory after installation:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File scripts\refresh-inventory.ps1
```

## Optional Activation for Practical Work

If your agent supports `AGENTS.md`, add:

```markdown
When performing practical work that may depend on installed tools, runtimes,
SDKs, services, models, or local development assets, use the
`local-dev-environment` skill before installing or downloading replacements.
```

This rule applies to practical work such as programming, building, debugging, and data processing. It does not require the Skill for casual conversation or general knowledge questions.

## Privacy

The public repository **does not contain the author's machine inventory or personal paths**. The bundled `references/inventory.md` is only a placeholder.

After running the scanner locally, the generated inventory may contain:

- Computer names, drive letters, and volume labels
- Software versions and installation paths
- Development services and environment variables
- Local models, tools, and project directories

Review and sanitize the generated `inventory.md` before sharing it publicly.

## Current Scope

- Primarily designed for Windows and PowerShell.
- Uses the Codex-style Skill structure and can work with agents that understand `SKILL.md`.
- Not every portable tool is guaranteed to be discovered automatically; use `LOCAL_DEV_SCAN_ROOTS` to add scan directories.
- The scanner handles discovery, but the agent must still dynamically verify tools before using them.

## Support the Project

If this Skill helps your AI avoid a duplicate installation, rediscover a forgotten tool, or complete development work more reliably, please give the repository a **Star**. It helps other AI-agent users discover the project.

Issues and contributions about missing tools, agent compatibility, and improvements are welcome.
