---
name: "gts-git-commit"
description: "兄弟说「提交git」「推送」时触发。git add -A + commit 或 push 双向同步。"
---

# Git 提交 Skill

> 触发词：`提交git` / `推送`。
> 注意：「提交」已由 gts-submit-save 处理，此处不再响应。
> 与 gts-save-flow 独立，只做 Git 操作。

---

## 步骤

### 提交git（commit only）

- 对 OpenClaw 工作区和 GTS-Play 项目各自检查 `git status`
- `git add -A` + `git commit -m "<AI 自动生成的中文提交信息>"`
- **不做 push**
- 提交信息格式：`feat/fix/chore/doc: <简述>`

### 推送（push）

- OpenClaw 工作区 → `git push origin master`
- GTS-Play 项目 → `git push origin dev`

---

## 执行纪律

1. `提交git` 只 commit，不 push
2. `推送` 才 push，双向（OpenClaw + GTS-Play）
3. 不跟 gts-save-flow 混——保存走自己的流程
