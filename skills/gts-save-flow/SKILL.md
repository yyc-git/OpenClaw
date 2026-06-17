---
name: "gts-save-flow"
description: "兄弟说「保存」时触发。全自动7步：扫描改动→更新BDD→契约检查→防御式编程→笔记文档→记忆→GitHub同步。"
---

# 保存协议（硬性操作规程）

> 触发词：兄弟说「保存」（仅「保存」二字）。「保存记忆」「保存笔记」等不触发。
> 全自动模式，不打断，一次跑完。
> ⚠️ 此 Skill 独立于 `gts-code-review`，保存不触发手动代码审核。

---

## 步骤

### Step 1：确定改动范围

- 读 `.last-save`（`笔记/决策记录/`），获取上次保存的 commit
- `git diff <last-save>..HEAD` 出改动文件清单
- 筛掉：`.gitignore` 中匹配的内容、`node_modules/`、`dist/`、`*.gen.tsx`
- 后续 Step 2-4 **仅针对这批改动文件**，不扫全项目

### Step 2：更新 BDD 测试

- 对改动文件中新增/修改的代码，补充/修改对应的 feature + step 文件
- 修复旧测试中不匹配 API 的命令格式

### Step 3：更新契约检查

- 检查改动文件中新增/修改的函数是否被 `requireCheck`/`ensureCheck` 覆盖
- 删除的校验路径不补

### Step 4：更新防御式编程

- 检查改动文件中中间位置的非空/边界校验（不应该用 `requireCheck`）
- 统一用 `if/else throw` 模式

### Step 5：更新笔记文档

按改动类型更新 `笔记/` 对应目录：
- 新功能 → `笔记/项目文档/` + `笔记/方案/`
- Bug 修复 → `笔记/决策记录/` + `笔记/代码笔记/`
- 重构 → `笔记/方案/` + `笔记/代码笔记/`
- 架构级 → `笔记/项目文档/` + `笔记/决策记录/`（新增 ADR）

### Step 6：保存今日记忆

- 更新 `memory/YYYY-MM-DD.md`
- 更新 `MEMORY.md`（如有新规则/决策）
- 更新 `.last-save = HEAD`（`笔记/决策记录/`）

### Step 7：同步到 GitHub

- OpenClaw 工作区 → `git push origin master`
- GTS-Play 项目 → `git push origin dev`

---

## 执行纪律

1. **全自动**——从 Step 1 到 Step 7 不打断、不提问
2. Step 2-4 只针对本次改动文件，不扫全项目
3. 不在保存流程中混入新功能开发
4. **不触发 `gts-code-review` Skill**
5. 飞书通知在完成后发一次总结
