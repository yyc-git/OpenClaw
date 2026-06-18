---
name: "gts-git-pull"
description: "兄弟说「拉取」「更新」「同步」时触发。从 GitHub 拉取最新的记忆和 skill。"
---

# Git 拉取 Skill

> 触发词：`拉取` / `更新` / `同步`
> 跟 `gts-save-flow`（推）成对，反向操作。
> 只做拉取，不做提交/推送。

---

## 步骤

### Step 1：确认 stash（可选）

- 如果本地有未提交改动，先问兄弟要不要 stash 再拉：
  ```
  git stash push -m "auto-stash before pull"
  ```

### Step 2：git pull

对 OpenClaw 工作区执行：

```powershell
Set-Location $env:USERPROFILE\.openclaw\workspace
git pull origin master
```

### Step 3：检测 skill 变更并更新 MEMORY.md

拉取后对比 skill 文件变化：

```powershell
# 列出 skills/ 目录下的变更（新增/修改/删除）
git diff --name-status HEAD@{1}..HEAD -- skills/
```

针对每类变更：

- **新增 skill（SKILL.md）**
  - 读取新 SKILL.md 的 `name` 和触发词（`---` 头部的 `name` 字段）
  - 写入 MEMORY.md 的 Skill 注册表（触发词 → skill 名 → 文件路径）
  - 如果兄弟在对话中，问他要不要现在触发试试

- **修改 skill**
  - 读新内容，确认变化点
  - 通知兄弟：XXX skill 已更新，下次触发时生效

- **删除 skill**
  - 从 MEMORY.md 注册表中移除对应条目

### Step 4：处理冲突

- 如果拉取失败或有冲突：
  - 列出冲突文件清单
  - 问兄弟如何处理（保留本地/接受远程/手动合并）
- 成功则继续

### Step 5：通知完成

- 列出拉的改动摘要（`git log --oneline HEAD@{1}..HEAD`）
- 列明 skill 变更详情（新增/修改/删除）
- 飞书通知兄弟：拉取完成 + 改动内容

---

## 执行纪律

1. 只拉取 OpenClaw 工作区，**不拉取 GTS-Play 项目**
2. 不跟 `gts-save-flow` / `gts-git-commit` 混用
3. **本地有未提交改动时先问兄弟**，不自动 stash
4. 冲突情况下不自动解决，问兄弟
5. 拉取完成后飞书通知
6. MEMORY.md 注册表自动同步 skill 变更
