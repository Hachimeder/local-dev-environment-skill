# Local Dev Environment Skill

[![GitHub stars](https://img.shields.io/github/stars/Hachimeder/local-dev-environment-skill?style=social)](https://github.com/Hachimeder/local-dev-environment-skill/stargazers)
[![Release](https://img.shields.io/github/v/release/Hachimeder/local-dev-environment-skill)](https://github.com/Hachimeder/local-dev-environment-skill/releases/latest)
[![Windows](https://img.shields.io/badge/platform-Windows-0078D4)](#)

> 让 AI 在下载和重复安装之前，先看懂你的本机开发环境。

很多 AI Agent 会知道怎么安装 Python、Node.js、JDK 或 Docker，却不知道你的电脑上其实已经有多个版本、项目虚拟环境、便携 CLI、本地模型和可复用源码。

`local-dev-environment` 是一个面向 Windows AI Agent 的 Skill。它会建立本机开发工具清单，引导 Agent 在实际工作前验证现有环境，并在安装、升级、卸载或迁移工具后自动刷新和核对清单。

## 为什么需要它

- **少装重复工具**：先检查 `PATH`、注册表、项目环境和常见开发目录。
- **选对工具版本**：尊重项目的锁文件、虚拟环境、`JAVA_HOME`、`global.json` 等约束。
- **发现隐藏资产**：识别不在 `PATH` 中的便携 CLI、本地模型、OCR 工具和源码仓库。
- **环境变更可追踪**：安装或卸载后，不只运行刷新脚本，还会独立验证结果是否真的写入清单。
- **安全优先**：未经用户明确同意，不安装、删除、迁移工具，也不修改 `PATH`、服务或注册表。
- **按需启用**：只在实际工作可能依赖本机环境时使用，不打扰聊天和普通知识问答。

## 它如何工作

```text
用户提出实际任务
       ↓
Agent 读取环境清单
       ↓
动态验证命令、路径、版本和服务状态
       ↓
优先复用合适的本机工具
       ↓
环境发生变化时刷新清单
       ↓
再次独立检查，确认清单与真实状态一致
```

清单只是发现线索，不是不可质疑的事实。Skill 要求 Agent 在调用工具前使用版本命令、`Get-Command`、`Test-Path`、包管理器或服务查询进行确认。

## 快速安装

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

也可以从 [Releases](https://github.com/Hachimeder/local-dev-environment-skill/releases/latest) 下载 ZIP，并解压到对应的 skills 目录。

安装后生成本机清单：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File scripts\refresh-inventory.ps1
```

## 可选：在实际工作时自动启用

如果你的 Agent 支持 `AGENTS.md`，可以加入：

```markdown
When performing practical work that may depend on installed tools, runtimes,
SDKs, services, models, or local development assets, use the
`local-dev-environment` skill before installing or downloading replacements.
```

这条规则只针对编程、构建、调试、数据处理等实际工作，不要求普通聊天或知识问答也加载 Skill。

## 隐私说明

公开仓库**不包含作者电脑的环境清单或个人路径**。仓库中的 `references/inventory.md` 只是占位文件。

在你的电脑上运行扫描器后，生成的清单可能包含：

- 电脑名、盘符和卷标
- 软件版本与安装路径
- 开发服务和环境变量
- 本地模型、工具及项目目录

请在公开分享生成后的 `inventory.md` 前自行检查和脱敏。

## 当前范围

- 主要面向 Windows 和 PowerShell。
- 支持 Codex 风格 Skill 结构，并可用于能够读取 `SKILL.md` 的 Agent。
- 不保证每一种便携工具都能自动识别；可通过 `LOCAL_DEV_SCAN_ROOTS` 添加额外扫描目录。
- 扫描器负责发现，Agent 仍需在使用前动态验证。

## English

`local-dev-environment` helps Windows AI agents understand and reuse the development tools already installed on a machine before downloading duplicates.

It inventories runtimes, SDKs, IDEs, databases, containers, package managers, portable CLIs, local models, virtual environments, services, and reusable source trees. Agents must verify paths and versions before use, request approval before changing the environment, refresh the inventory after changes, and independently confirm that the refresh matches reality.

The public repository contains no personal machine inventory. Run the bundled PowerShell scanner locally after installation and review generated data before sharing it.

## 支持项目

如果它帮你的 AI 少装了一套重复环境、找到了被遗忘的工具，或者让开发任务更可靠，请点一个 **Star**。这会让更多需要本机环境管理能力的 Agent 用户看到它。

欢迎提交 Issue，分享未识别的工具、Agent 兼容性问题和改进建议。
