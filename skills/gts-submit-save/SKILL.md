---
name: "gts-submit-save"
description: "兄弟说「提交」时触发。同时做git commit + 记忆保存，不做push。"
---

# gts-submit-save — 提交+记忆

> 触发词：`提交`（仅二字）。
> 同时做两件事：git commit + 保存记忆。不做 push。
> 跟 gts-save-flow（保存）是不同触发词，不同流程。

---

## 流程

### Step 1：提交 git

- OpenClaw 工作区：`cd ~/.openclaw/workspace && git add -A && git commit -m "<AI 自动生成的中文提交信息>"`
- 提交信息格式：`feat/fix/chore/doc: <简述>`
- **不做 push**
- 如果当前没有改动 → 跳过，直接进入 Step 2

### Step 2：保存记忆

- 检查当前会话中有哪些需要记住的信息：
  - 重要教训、决策 → 写入 `MEMORY.md` 对应节
  - 日常对话要点 → 写入 `memory/YYYY-MM-DD.md`
- 更新 HEARTBEAT.md 中的记忆保存时间戳
- 格式规范：时间戳 `[YYYY-MM-DD HH:MM]`、分类清晰、写清楚上下文

### Step 3：给总结

- 飞书通知兄弟：提交了什么 + 记忆保存了什么
- 简洁，一两句话

---

## 执行纪律

1. 只 commit，不 push（想 push 请说「推送」）
2. git commit 失败（没改动）→ 只做记忆保存，正常通知
3. 跟 gts-save-flow 不是一回事——「保存」走完整 8 步流程，这个只做 git + 记忆，轻量快速
