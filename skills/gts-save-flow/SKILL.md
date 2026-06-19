---
name: "gts-save-flow"
description: "兄弟说「保存」时触发。7+1步：审核→扫描→BDD→契约→防御式→笔记→记忆→GitHub同步"
---

# gts-save-flow — 保存协议（硬性操作规程）

> 触发词：兄弟说「保存」（仅二字）。
> 注意：保存包含 push（两段提交保 last-save），与「提交git」规则不冲突。

---

## 流程（8+1 步）

兄弟说「保存」后，严格按以下顺序执行每一步：

### Step 0：改动总结 + 问题预警

> 📣 **先发飞书通知**，包含以下内容

1. 获取上次保存到现在的改动清单：
   - 读取 `笔记/决策记录/.last-save` 获取上次保存的 commit SHA
   - `git log --oneline <last-save-sha>..HEAD` 列出所有中间 commit
   - `git diff <last-save-sha>..HEAD --stat` 列出文件改动统计
   - 记录 上次保存时间 + commit 数
   - 生成简洁的 **改动摘要**（改了哪些模块、做了什么）

2. **问题分析**：
   - 是否改了服务端代码 → 是否重启了服务？
   - 是否改动了 `node_modules` → 是否经兄弟确认？
   - 是否改了 webpack 配置 → 是否重启了 webpack？
   - 是否改了 `.res` 文件 → 是否跑了 `rescript build`？
   - 是否动到了 `dist` 文件 → `src` 源文件是否同步修改？
   - 测试是否跑过？结果如何？
   - 是否有未处理的 todo/FIXME？

3. **飞书通知** 发送改动摘要 + 问题分析 + **请求确认**

> ⏸️ **等 5 分钟**，超时则自动进入下一步。
> 兄弟回复「确认」「继续」或超时 → 继续执行 Step 1。
> 兄弟指出问题 → 修好再继续。

### Step 1：快速审核改动

- `git status` 看改动文件
- 快速过一遍改动的合理性（防止意外改动混入）
- 有问题 → 通知兄弟确认

### Step 2：扫描敏感信息

- 扫描改动文件中是否有：密码、token、密钥、内网 IP、真实姓名等
- 有 → 先去敏感化再继续

### Step 3：跑 BDD 测试

- 如果 `packages/frontend/test/` 或 `packages/frontend/src/` 有改动：
  - `cd packages/frontend && npx jest --config jest.multiplayer.json --silent`
- 如果 `packages/room-service/test/` 或 `packages/room-service/src/` 有改动：
  - `cd packages/room-service && npx jest --config jest.json --silent`
- 如果 `packages/match-service/test/` 或 `packages/match-service/src/` 有改动：
  - `cd packages/match-service && npx jest --config jest.json --silent`
- 测试失败 → 修到全绿再继续

### Step 3.5：编译检查

- 如果 TypeScript 文件有改动，BDD 全绿后追加 `npx tsc --noEmit`
- ⚠️ jest（ts-jest）只转译不做类型检查，必须靠 `tsc` 暴露
- 有错误 → 修到零错误，回头再跑 BDD 确认

### Step 4：契约检查

- 确保改动符合项目已有的契约检查模式（`requireCheck` / `test()` / `assertTrue()`）
- 新增函数尽量加 `requireCheck`

### Step 5：防御式编程检查

- 确保参数尽量必传，没有 `null` 兜底或 `||` 给默认值
- `if (!x) return` 只在调用方能合理处理 null 时使用

### Step 6：更新笔记

- 看情况更新 `笔记/` 中对应目录：
  - 架构级/决策 → `项目文档/` + `决策记录/`
  - 重构/功能实现 → `方案/` + `代码笔记/`
  - 日常调试 → `讨论记录/`

### Step 7：更新持久记忆

- 更新 `memory/` 对应日期的文件
- 如果 `MEMORY.md` 中的配置/规则/教训需要更新 → 同时更新

### Step 8：GitHub 同步（两段提交）

> 📣 此步骤可能需翻墙，如果失败通知兄弟手动 push。

#### 第一部分：last-save（先提交到本地）

```
git add -A
git commit -m "save: <日期> <改动摘要>"
```

#### 第二部分：push 到 GitHub

```
git push origin dev
```

如果 push 失败（网络/翻墙问题）→ 通知兄弟手动推。

---

## 提交纪律

1. 所有 step 串行执行，不能跳步
2. Step 3 测试不过必须修，不能跳过
3. Step 4-5 发现违规 → 修了再继续
4. Step 8 两段提交不合并，确保 `last-save` 留在本地

### last-save 更新机制

- 保存成功后，将**当前 HEAD 的完整 SHA** 写入 `笔记/决策记录/.last-save` 文件
- 下次「保存」时读取此文件确定上次保存点
- ⚠️ 不要用 `git tag` 或 `git stash` 记录 last-save，只用 `笔记/决策记录/.last-save` 文本文件
