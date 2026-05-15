---
name: openclaw-backup-sync
description: Backup, restore, and sync OpenClaw memory/data between machines. Use when the user wants to save their OpenClaw workspace, MEMORY.md, daily logs, config, or channel credentials to the cloud, or restore them on another computer. Covers Git-based sync, cloud drive sync, and `openclaw backup` archive creation.
---

# OpenClaw Backup & Sync

## Overview

The user's OpenClaw state lives in `~/.openclaw/`. Key files to back up:

| Path | What | Priority |
|------|------|----------|
| `~/.openclaw/workspace/` | MEMORY.md, USER.md, IDENTITY.md, daily logs (memory/*.md) | ⭐ 最高 |
| `~/.openclaw/openclaw.json` | Config (channels, plugins, model) | ⭐ 高 |
| `~/.openclaw/agents/` | Agent configs, auth profiles | ⭐ 高 |
| `~/.openclaw/credentials/` | Channel login tokens (微信/QQ等) | ⚠️ 敏感 |

## Method 1: Git Sync (推荐 for workspace)

最适合同步记忆 markdown 文件，版本历史清晰。

```powershell
# 初始化
cd $env:USERPROFILE\.openclaw\workspace
git init
git add .
git commit -m "init: memory backup"

# 推送到私人仓库
git remote add origin <your-private-repo-url>
git push -u origin main

# 另一台电脑
git clone <your-private-repo-url> $env:USERPROFILE\.openclaw\workspace
```

**优点:** 增量同步、版本回溯、diff 可见
**缺点:** 不含 credentials/config（需单独处理）

## Method 2: Cloud Drive 同步 (OneDrive)

Windows 上最简单的方式，自动静默同步。

```powershell
# 把 workspace 移到 OneDrive
Move-Item $env:USERPROFILE\.openclaw\workspace $env:USERPROFILE\OneDrive\openclaw-workspace

# 建立符号链接
New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\.openclaw\workspace `
  -Target $env:USERPROFILE\OneDrive\openclaw-workspace
```

另一台 Windows 装 OneDrive → 自动同步。

## Method 3: `openclaw backup` 全量归档

内置命令，打包全部状态。

```bash
# 创建归档（含 workspace）
openclaw backup create

# 仅配置文件
openclaw backup create --only-config

# 不包含 workspace（要小包时）
openclaw backup create --no-include-workspace

# 验证归档完整性
openclaw backup verify ./<archive>.tar.gz
```

归档上传到云盘/网盘，另一台电脑下载后解压到对应位置。

## 完整迁移方案

在新电脑上：

```bash
# 1. 安装 OpenClaw
npm install -g openclaw

# 2. 同步 workspace（Git clone 或 OneDrive 自动同步）

# 3. 恢复配置
# 复制 openclaw.json 到 ~/.openclaw/

# 4. 恢复渠道凭证
# 复制 credentials 目录

# 5. 验证
openclaw doctor
```

## 安全提醒

- `credentials/` 含渠道 login token，**不要提交到公开 Git 仓库**
- 推 Git 时加 `.gitignore`，排除 credentials 和 session 文件
- 云盘同步建议加密敏感文件
