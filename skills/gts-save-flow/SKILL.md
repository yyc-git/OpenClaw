---
name: "gts-save-flow"
description: "兄弟说「保存」时触发。7+1步：审核→扫描→BDD→契约→防御式→笔记→记忆→GitHub同步（两段提交保last-save）"
---

# 保存协议（硬性操作规程）

> 触发词：兄弟说「保存」（仅「保存」二字）。「保存记忆」「保存笔记」等不触发。
> 全自动模式，不打断，一次跑完。
> ⚠️ 此 Skill 独立于 `gts-code-review`，保存不触发手动代码审核。

---

## 步骤

### Step 0：代码审核检查（前置）

- 检查最近 1 小时内是否已进行代码审核
- 如有→跳过；如无→中止保存，提示兄弟

### Step 1：确定改动范围

- 读 `.last-save` 获取上次保存的 commit hash
- `git diff --stat <hash>..HEAD` 列出改动文件

### Step 2：更新 BDD 测试

- 针对有业务逻辑修改的文件，检查是否需更新对应 BDD
- 跑一轮确认全绿

### Step 3：契约检查

- 检查 `Contract.ensureCheck` / `Contract.requireCheck` 是否保留

### Step 4：防御式编程

- 检查 null/edge-case 处理

### Step 5：更新笔记

- 新决策→写 `笔记/决策记录/<日期>-<描述>.md`

### Step 6：更新记忆

- 更新 `memory/YYYY-MM-DD.md`

### Step 7：同步到 GitHub

**⚠️ 关键：两段提交，确保 .last-save 不丢失**

GTS-Play 项目：
```
git add -A
git commit -m "<变更描述>"                        # ① 第一段：变更
git rev-parse HEAD | Set-Content "笔记/决策记录/.last-save"  # ② 写新 SHA
git add "笔记/决策记录/.last-save"                 # ③ 加暂存
git commit -m "chore: update .last-save"          # ④ 第二段：last-save
git push origin dev                                # ⑤ 推送（包含两个 commit）
```

OpenClaw 工作区：
```
cd C:\Users\one\.openclaw\workspace
git add -A
git commit -m "save: <日期> <简述>"
git push origin master
```

---

## 执行纪律

1. Step 0→Step 1-7 全自动不打断
2. Step 7 必须两段提交：先改代码，再单独提交 .last-save
3. 绝不能用 `--amend`（会改写已推送历史）
4. 飞书通知在完成后发一次总结
