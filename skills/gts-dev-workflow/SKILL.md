---
name: "gts-dev-workflow"
description: "兄弟说 feat:/fix:/refactor: 时触发。TDD+契约检查+防御式编程+BDD+集成测试+飞书通知。必更新项目笔记。"
---

# gts-dev-workflow — TDD 开发流程（硬性操作规程）

> 当兄弟说 `feat:` / `fix:` / `refactor:` 时触发。
> 默认针对多人联网部分。TDD + 契约检查 + 防御式编程 + BDD + 集成测试。

> 📣 每次等待兄弟确认时，必须同时发飞书通知（含进度和确认诉求）。

---

## 触发规则

- 兄弟说 `feat:` / `fix:` / `refactor:` 开头 → 触发此 Skill
- 兄弟说「开工」「开干」→ 开始实现
- 兄弟说「不」「不要」「算了」→ 中断流程，只保留已有改动

## 流程

### Step 0：分析 + 出方案

- 分析要修改的内容，确认目标、范围、影响
- 列出待改文件清单
- 如果复杂/架构级，先出方案再等兄弟说「开工」

> ⏸️ **等兄弟确认方案。** 📣 发飞书通知。

### Step 1：测试前置

- 本次改动涉及的所有功能，先在 `frontend/test/` 写：
  1. **BDD 测试**（`.feature` + `.steps.ts`）— 定义行为期望
  2. **集成测试**（`.integration.test.ts`）— 尽量模拟真实场景中的操作，覆盖相关触发路径
- 涉及 `room-service` 的额外加 `room-service/test/` 的 BDD + 集成测试
- 只写本次改动涉及的测试，不写无关的
- 测试设计：TDD 红-绿-重构，先写期望行为再实现

### 测试规则

- **BDD 测试**：Jest + Cucumber，验证行为契约
  - 命令：`npx jest --config jest.multiplayer.json --testPathPattern <feature>`
- **集成测试**：Jest，模拟真实用户操作链路
  - 命令：`npx jest --config jest.multiplayer.json --testPathPattern .integration.`
- 全量测试：`npx jest --config jest.multiplayer.json`
- 跑测试时用 `--silent` 压掉 THREE 编译警告
- 不跑 Playwright

### 集成测试编写规则

- **存放位置：** `frontend/test/integration/`（按模块分目录）
- **命名：** `<module>.integration.test.ts`
- **原则：**
  - 尽量**模拟真实操作流程**（创建 → 操作 → 触发 → 验证结果）
  - 调用真实接口、触发真实事件，mock 仅限外部不可控依赖（网络延迟、随机种子）
  - 测试**多个相关模块的联动**，而非单个函数的孤立行为
  - 覆盖改动的**正向路径 + 边缘情况**
- **场景设计：**
  - 给定初始状态 → 执行操作序列 → 断言最终状态/事件/副作用
  - 例如：构建两个客户端 → P1 执行某操作 → 断言 P2 收到同步状态

### 服务端规则
- 启动顺序：先 room-service（4003），再 match-service（3000）
- 启动命令：`yarn dev`（tsrpc-cli dev），不是 `npx ts-node`
- 改 logic 后 → 重启 room-service + copy dist 到 `room-service/dist/logic/`
- 测试后 → 重启服务端清除脏数据
- 改 webpack 配置后 → 重启 webpack-dev-server
- 改 node_modules → 必须先经兄弟确认

### 改动范围
- 默认针对多人联网部分：`room-service/` + `logic/src/` + `frontend/src/business_layer/multiplayer/`
- 所有改动点（含 frontend）都要覆盖

### 代码规则
- 改 `.ts` 再 `tsc`，改 `.res` 再 `rescript build`，**不要直接改 `.js`**
- 改 `.gen.tsx` → 必须同步改 `.res`，否则下次编译覆盖
- **改 dist 必须同步改 src（TS源文件）**

### 更新文档规则（强制）

每次改动完成后，**必须**按实际影响范围更新 `笔记/` 中对应目录：

| 改动类型 | 更新的文档 |
|---|---|
| 架构级/重要决策 | `项目文档/` + ADR + `决策记录/` |
| 重构/功能实现细节 | `方案/` + `代码笔记/` |
| 日常调试过程 | `讨论记录/` |

> ⏸️ **如有新增知识需记录（踩坑、调试trick、架构说明），一并写入对应笔记。**

Step 1: 写测试（BDD + 集成测试，一个 feature → 一个 feature 来）
         ↓
Step 2: 对每个要修改的文件写对应测试
         → 运行这些测试（只跑新增的）→ 必须失败（红）
         ↓ 确认红（预期失败）
Step 3: 实现功能 → 更新契约检查 → 更新防御式编程
         ↓
Step 4: 运行全部 BDD 测试 + 全部集成测试 → 必须全绿
         ↓ 失败则修到全绿

### Step 3.5：编译检查

- BDD + 集成测试全绿后，跑 `npx tsc --noEmit` 检查类型编译错误
- ⚠️ jest（ts-jest）只转译不做类型检查，必须靠 `tsc` 暴露
- 有错误 → 修到零错误，回头再跑测试确认
         ↓ 通过

### Step 5：提交 + 通知 + 更新笔记

- `git add -A` + `git commit -m "feat/fix/refactor: ..."`
- **更新项目笔记**（按上方「更新文档规则」表格）
- 📣 飞书通知完成总结（含 BDD + 集成测试覆盖情况）
- 提示兄弟：**建议跑 e2e测试 确认联机环境无误**

---

## 执行纪律

1. **TDD 红-绿-重构**——先写测试，确认红，再实现，确认绿，再重构
2. **BDD + 集成测试双覆盖**——BDD 定义行为契约，集成测试覆盖真实操作链路
3. **契约检查**——每个函数入口做 `requireCheck` + `test()` + `assertTrue()`
4. **防御式编程**——参数尽量必传，不满足条件尽早 throw
5. **改动范围纪律**——只做目标改动，不顺手改无关代码
6. **完成必更新笔记**——不跳步
7. Step 5 之前如果兄弟说「算了」→ 中断流程，只保留已有改动
8. **改 dist 必须同步改 src**，反之亦然
