---
name: "gts-save-flow"
description: "兄弟说「保存」时触发。7+1步：审核检查→扫描改动→BDD→契约→防御式→笔记→记忆→GitHub同步"
---

# 保存协议（硬性操作规程）

> 触发词：兄弟说「保存」（仅「保存」二字）。「保存记忆」「保存笔记」等不触发。
> 全自动模式，不打断，一次跑完。
> ⚠️ 此 Skill 独立于 `gts-code-review`，保存不触发手动代码审核。

---

## 步骤

### Step 0：代码审核检查（前置）

- 检查最近 1 小时内是否已进行代码审核：
  - 读 `memory/YYYY-MM-DD.md`，搜索「代码审核」条目
  - 搜索 `笔记/决策记录/` 中当天文件名包含「审核」的文档
- 如有审核记录 → 跳过手动审核，直接进入 Step 1
- 如无审核记录 → 中止保存，提示兄弟「今日尚未代码审核，建议先审核」
- ⚠️ 此检查不调用 `gts-code-review` Skill

### Step 1：确定改动范围

- 读 `.last-save` 获取上次保存的 commit hash
- `git diff --stat <last_save_hash>..HEAD` 列出改动文件

### Step 2：更新 BDD 测试

- 针对有业务逻辑修改的文件，检查是否需更新对应 BDD feature + steps
- 更新后跑一轮确认，必须全绿

### Step 3：契约检查

- 检查 `Contract.ensureCheck` / `Contract.requireCheck` 是否保留（无删、无弱化）

### Step 4：防御式编程

- 检查新增/修改的代码是否有合理的 null/edge-case 处理

### Step 5：更新笔记

- 如有新决策 → 写 `笔记/决策记录/<日期>-<描述>.md`
- 如有新人坑 → 更新 `笔记/代码笔记/` 相关文件

### Step 6：更新记忆

- 将关键决策、新规则更新到 `memory/YYYY-MM-DD.md`

### Step 7：同步到 GitHub

**执行顺序（关键）：**
1. `git add -A`
2. `git rev-parse HEAD | Set-Content "笔记/决策记录/.last-save"` ← **必须在 commit 之前写**
3. `git commit -m "..."`  ← .last-save 此时已在暂存区
4. `git push origin dev`

- OpenClaw 工作区同样提交 + push

⚠️ 注意：`.last-save` 的 `Set-Content` 必须放在 `git commit` 之前（但可以在 `git add -A` 之后，因为 add -A 后再写文件需要重新 add）

正确顺序：
```
git add -A
git rev-parse HEAD | Set-Content ".last-save"   # 先写
git add ".last-save"                              # 再 add
git commit -m "..."                               # 然后 commit（包含 .last-save）
git push
```

---

## 执行纪律

1. Step 0 审核检查 → Step 1-7 全自动不打断
2. Step 2-4 只针对本次改动文件，不扫全项目
3. 不在保存流程中混入新功能开发
4. **不触发 `gts-code-review` Skill**
5. 飞书通知在完成后发一次总结
6. **Step 7 必须按正确顺序：先写 .last-save，再 commit，最后 push**
