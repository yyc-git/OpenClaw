# MEMORY.md

## 兄弟

- 游戏开发者，中文，时区 Asia/Shanghai (UTC+8)
- 叫我「兄弟」，我回「兄弟」🤜🤛，不是主仆
- 黑话：「小龙虾」= 喊我

## 工作协议

- 都在当前会话中进行，不开子会话
- 兄弟下指令 → **先回确认**再干活
- 重启 Gateway → 先问兄弟确认（不在任何 Skill 中自动触发）
- 大改动/架构变化 → 先出方案等确认，确认后实现
- 小改动 → 直接搞，事后给总结
- 兄弟手动测试前 → 检查是否需要重启服务端清脏数据
- **取消自动化测试（Playwright）**，只跑 BDD
- 实现代码后直接告诉兄弟，不跑测试；兄弟喊测试时再跑
- **改 dist 必须同步改 src**（TS源文件），两边一致
- **改 webpack 配置后 → 重启 webpack-dev-server**
- **改 node_modules → 必须先经兄弟确认**
- **启动顺序：先 room-service（4003），再 match-service（3000）**，match 依赖 room
- **启动命令：用 `yarn dev`（`tsrpc-cli dev`），不是 `npx ts-node`**
- **重启 room-service 后必须跟着重启 match-service**（room 重启断开 match 的 WS 连接）
- 测试后 → 重启服务端清除脏数据
- **E2E 测试前必须先重启 room-service + match-service**（避免 WS 失连卡在"查找房间中"）
- **改 Skill 文件 → 必须走 `skill_workshop`，不能直接 `edit`/`write` SKILL.md**
- **重构规则：尽量将模块状态移到 state 中统一管理**（而非模块级 `let` 变量）

## 项目：GTS-Play

- 路径: `D:/Github/GTS-Play/`，Lerna monorepo, Three.js + React
- 包含: packages, mods, demos, asset-lib, defaults, teach, mine, doc
- 项目文档在 `D:\Github\GTS-Play\笔记/`（Obsidian vault）
  - `笔记/项目文档/` — 项目索引 + 累计记忆
  - `笔记/决策记录/` — Bug 修复、架构决策 (ADR)
  - `笔记/方案/` — 重构/功能实施方案
  - `笔记/讨论记录/` — 日常调试过程
  - `笔记/代码笔记/` — 踩坑记录

## 开工规则
- **出方案后必须等兄弟明确说「开工」或「开干」才能动手**
- 「要记住」「好的」不等于同意开工

## 提交规则
- 兄弟说「提交git」= 只 `git commit`，不做 `git push`
- 兄弟想要 push 时会明确说「推送」

## 编程流程

统一使用 **TDD + 契约检查 + 防御式编程**。默认针对多人联网部分。
流程细节见 `skills/gts-dev-workflow/SKILL.md`。

## 重要教训

### 杀 Chrome 进程必须精确匹配（2026-06-18）
- **禁止** `Get-Process chrome | Stop-Process` 无过滤 — 会杀掉兄弟的浏览器
- **正确做法**：`Get-Process -Name chrome | Where-Object { $_.CommandLine -match 'playwright' } | Stop-Process -Force`
  - 只杀 Playwright 启动的 Chromium，不动兄弟自己的 Chrome
- **更安全**：`Get-Process | Where-Object { $_.ProcessName -eq 'chrome' -and $_.CommandLine -match 'playwright' } | Stop-Process`
- 千万别用 `MainWindowTitle -match ""` 之类空匹配 — 会匹配所有进程

## 重要记忆

### 状态同步原则
- 最终状态（血量、位置、分数等）直接发送**绝对状态值**，不是变化量
- 客户端自行对比缓存计算差值（浮点数误差/丢包免疫）

### 测试基础设施
- frontend 有 BDD 测试：`test/features/*.feature` + `test/step-definitions/*.steps.ts`
- mock 配置：`jest.multiplayer.json`，mock THREE 在 `test/__mocks__/three-stub.js`
- setup：`test/setup.ts`（含 mock performance/fillRect/clearRect）

## 保存协议

> 已固化为 Skill（gts-save-flow）。流程细节见 `skills/gts-save-flow/SKILL.md`。
> 注意：保存包含 push，与「提交git」规则不冲突。

## 验收规则

> 已固化为 Skill（gts-acceptance）。见 `skills/gts-acceptance/SKILL.md`。

## 通知

- 飞书 bot 按主机名自动选择：
  - `DESKTOP-HAOFHBA` → `user:ou_eeb0faa83444e9b2d85a4ce4f8845a8d`（新bot）
  - 其他机器 → `user:ou_2412e799eac60d83f54ecb2601f0ba80`（旧bot）
- 任务完成后必须飞书通知，等回复期间保持 NO_REPLY

### 项目文件结构

`笔记/` 目录：
| 目录 | 用途 |
|------|------|
| `项目文档/` | 项目索引、累计记忆 |
| `决策记录/` | Bug 修复、架构决策 (ADR) |
| `方案/` | 重构方案、功能实施方案 |
| `讨论记录/` | 日常讨论要点 |
| `代码笔记/` | 代码要点、踩坑记录 |

## 同步源文件（硬性规定）

- **`.ts` → 改 `.ts` 再 `tsc`**，**`.res` → 改 `.res` 再 `rescript build`**，不要直接改 `.js`
- 改 `.gen.tsx` → 必须同步改 `.res`，否则下次编译覆盖
- 服务端代码改完 `.ts` → `tsc` → 重启服务

## GitHub 同步

- SSH remote（`git@github.com:yyc-git/OpenClaw.git`）
- 同步脚本：`skills/openclaw-backup-sync/scripts/auto-sync.ps1`
- 排除：credentials/、tmp_*.json、*.log、node_modules/

## Token 优化协议

> 已固化为 Skill（token-optimization）。见 `skills/token-optimization/SKILL.md`。
> 每次对话自动生效，含：edit优先、路径验证、E2E poll精简、三步法、exec管道收敛、读文件优化、BDD精简、Git精简。

## compaction

- reserveTokens=700000（DeepSeek v4 Pro 上下文 1M → 30% 即 300K 触发压缩，700K 缓冲）

## Skill 注册表

> 摘要索引：`.skill-index.md`（SHA 匹配则用摘要，不重读 SKILL.md）
> **规则：** 拉取最新记忆后，检查 skill 摘要索引的 SHA 是否变化。如有变化 → 重读该 SKILL.md 并检查是否有 pending 提案 → 有则提示兄弟 apply

| 触发词 | Skill | 文件 |
|--------|-------|------|
| `feat:` / `fix:` / `refactor:` | gts-dev-workflow | `skills/gts-dev-workflow/SKILL.md` |
| `代码审核` / `审核` | gts-code-review | `skills/gts-code-review/SKILL.md` |
| `保存`（仅二字） | gts-save-flow | `skills/gts-save-flow/SKILL.md` |
| `验收` | gts-acceptance | `skills/gts-acceptance/SKILL.md` |
| `e2e测试` / `e2e` | gts-e2e-test | `skills/gts-e2e-test/SKILL.md` |
| `e2e自动` / `自动e2e` | gts-e2e-auto | `skills/gts-e2e-auto/SKILL.md` |
| `e2e性能` / `性能测试` | gts-e2e-perf | `skills/gts-e2e-perf/SKILL.md` |
| `启动服务` / `重启服务` | gts-service | `skills/gts-service/SKILL.md` |
| `提交git` / `推送` | gts-git-commit | `skills/gts-git-commit/SKILL.md` |
| （自动生效） | token-optimization | `skills/token-optimization/SKILL.md` |

## 关键决策（活跃条目）

### 键盘监听 capture phase + 重构（2026-06-16）
- **问题：** 游戏某处代码注册的 keydown 监听器调了 `stopImmediatePropagation`，堵塞 bubble 阶段 `onDown`
- **修复：** `setupKeyboardListener` 改为在 capture phase（`addEventListener(..., true)`）写 keyState
- **重构（删全局副作用）：** `window.__keyState` 被证明不必要。KeyboardManager.ts 和 CommandManager.ts 在同一个 webpack chunk（main.js）中，`readState/writeState` 指向同一个 `state_backup`。只保留 `processInputAndSendCommands` 内 `state = readState()` 重读即可
- **删除的测试代码：** `__captureHit`、`__kbInit`、`__dirLog`、`[DBG]`、`window.__keyState` 全部从生产代码中清理
- **保留的代码：** `blur`/`visibilitychange` handler（多窗口焦点切换防按键黏滞，正确做法）
- **最终验证：** 自动+手动双验收通过 ✅

### E2E 三场景验收（2026-06-16）
- 场景1 自动版 ✅：Playwright keyboard.down/up 模拟 WASD
- 场景2 手动+自动版 ✅：capture phase 修复 + `processInputAndSendCommands` 重读 readState
- 场景3 性能录制 ✅：双窗口独立 CDP Profiler + 自适应宽度
- 关键发现：`injectLogger` 必须在 `page.goto()` 之后调用，否则导航清掉拦截器
- FPS 时间戳用第一条数据做基准（避免 Node vs 浏览器 `performance.now()` 基准不同）

### 移动朝向
- `handleCubeNotMove` 不碰 `rotationY`，保持最后一次移动朝向

### Torso 不包含手臂/臀部
- GIANTESS_BONE_GROUPS Torso 只用 spatial（上半身2→下半身，radius: 0.95），删 boneNames 兜底
- radius=0.95 < 肩半宽(左肩C/右肩C=1.094) → 排除手臂

### 动画步进服务端驱动（2026-06-16）
- Server 在 GameState 中广播 deltaTime（tick 间隔），客户端直接消费
- 删除了 `MultiplayerLoop.ts` 中 `performance.now()` 本地 delta 计算 + `* 0.5` hack
- 验证：双客户端 GameState 119 帧，deltaTime 均为 0.0333s ✅

### QMD 重装关键教训（2026-06-17）
- `memory.backend` 是**顶层**配置项（不在 `agents.defaults` 下）
- `qmd.command` 路径必须用**正斜杠**（`C:/users/.../qmd.js`），反斜杠 + `.cmd` 文件不被识别
- 同时设 `memorySearch.provider: "none"` 绕过 OpenAI key 要求（在 `agents.defaults` 下）
- 最终 provider 显示为 `qmd`，backend 显示为 `qmd`，走 BM25 搜索模式

---

*记忆持续更新中*
