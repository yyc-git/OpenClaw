# MEMORY.md

## 兄弟

- 游戏开发者，中文，时区 Asia/Shanghai (UTC+8)
- 叫我「兄弟」，我回「兄弟」🤜🤛，不是主仆
- 黑话：「小龙虾」= 喊我

## 工作协议

### 📣 等待确认必发飞书通知

> **最高优先级规则。** 任何 Skill 或流程中，只要涉及「停住等兄弟确认」，
> 必须同时发飞书通知（含上下文和确认诉求）。禁止静默等待。

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

## 保存信息

- `last-save` 记录在 `笔记/决策记录/.last-save`（文本文件，存完整 commit SHA）
- 不是 git tag，不是 git stash，是文件
- 上次保存：f787999（2026-06-19 21:03）

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

### Plugin hook 注册问题（2026-06-19）
- 当前 OpenClaw 2026.6.5 external plugin 的 `api.on(...)` 注册始终不生效（hookCount=0）
- linked .ts 和 .js 均无法正确注册 typed hooks
- `openclaw config set --json` 可能损坏配置文件——改为手动编辑 `openclaw.json`
- 结论：external plugin hook 方案暂时放弃，靠 SKILL + MEMORY.md 规则约束

### 杀 Chrome 进程必须精确匹配（2026-06-18）
- **禁止** `Get-Process chrome | Stop-Process` 无过滤 — 会杀掉兄弟的浏览器
- **正确做法**：`Get-Process -Name chrome | Where-Object { $_.CommandLine -match 'playwright' } | Stop-Process -Force`
  - 只杀 Playwright 启动的 Chromium，不动兄弟自己的 Chrome
- **更安全**：`Get-Process | Where-Object { $_.ProcessName -eq 'chrome' -and $_.CommandLine -match 'playwright' } | Stop-Process`
- 千万别用 `MainWindowTitle -match ""` 之类空匹配 — 会匹配所有进程

### 场景重入必须 dispose 旧 renderer（2026-06-18）
- 每次 `new ThreeRenderer()` 后旧实例被覆盖但不 dispose → scene（含 OBB/HUD/entity）残留
- **修复**：`MR.init` 先 dispose 旧 renderer，再挂新
- `ThreeRenderer.dispose()` 用项目标准 `deepDispose(scene, true)`（`meta3d-jiehuo-abstract/src/scene/utils/DisposeUtils`），递归清理所有 Three.js 几何体/材质/纹理/骨骼
- 模块级缓存（`_localHullOBB`、`_remoteHullCache`）也要在 `initForMultiplayer` 中清空

### sendExit 是 async，必须 await（2026-06-18）
- `sendExit` 是 async API 调用，不能 fire-and-forget
- `onConfirm` 中必须在 `disconnect` 之前 await 完成，否则 WS 在 API 飞行中断开 → `WS_NOT_OPEN`
- 双重防御：`sendExit` 内检查 client null 和 `isConnected`

### 状态标志必须在 disconnect 中重置（2026-06-18）
- `gameOverShown`、`gameOverData` 在 disconnect 时重置，否则二次进游戏弹窗不触发
- `setEnterGame` 实际没人调，不能依赖它

### Token 浪费教训（2026-06-18）
- 改代码前先 `Select-String` 确认调用链，避免修了没人用的函数
- jest 必加 `--silent` 压掉 THREE 警告
- E2E 停止按钮被点 = 用户主动停止，不分析不重试
- 搜索合并：多模式用 `|` 一次搜完

## 重要记忆

### 状态同步原则
- 最终状态（血量、位置、分数等）直接发送**绝对状态值**，不是变化量
- 客户端自行对比缓存计算差值（浮点数误差/丢包免疫）

### 测试基础设施
- frontend 有 BDD 测试：`test/features/*.feature` + `test/step-definitions/*.steps.ts`
- mock 配置：`jest.multiplayer.json`，mock THREE 在 `test/__mocks__/three-stub.js`
- setup：`test/setup.ts`（含 mock performance/fillRect/clearRect）
- **WebGL E2E 调试体系**（2026-06-20）：四层架构
  - L1: `window.__GL_STATS__` 每帧聚合（DC/tri/tex/programs）
  - L2: `window.__SHADER_ERRORS__` GLSL 编译错误自动捕获
  - L3: `scene.traverseVisible` 按 Mesh/Line/Sprite/SkinnedMesh 分桶
  - L4: `window.__GL_TRACE__.captureMs(n)` 逐条 GL 命令追踪（嵌入 ThreeRenderer.init）
  - E2E helpers: `test/e2e/e2e-helpers.cjs` 含 GPU 断言函数
  - 详细: `笔记/决策记录/WebGLE2E调试体系-2026-06-20.md`

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

## 监控

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
| `拉取` / `更新` / `同步` | gts-git-pull | `skills/gts-git-pull/SKILL.md` |
| `回忆` / `回顾` / `recollect` | gts-recall | `skills/gts-recall/SKILL.md` |
| `截图分析` | gts-screenshot-optimize | `skills/gts-screenshot-optimize/SKILL.md` |

## 代码审核重构规则（2026-06-19）

> 规则已在 `skills/gts-code-review/SKILL.md` Step 2 的 🟡/🟢 表格中列明，以 SKILL.md 为准。
>
> ⚠️ 代码审核 Step 2 的回复规则：
> - **没写内容** = 该项直接要重构
> - **写了内容** = 按写的内容修改
> - 只有写「不处理」「跳过」「忽略」等明确词才不处理

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

## WebGPU 与多线程分析（2026-06-20）

### Three.js 0.184 WebGPU 状态
- WebGPURenderer 已在核心 `src/renderers/webgpu/`，独立构建 `three/webgpu`
- 标准材质自动映射（StandardNodeLibrary），内置 SkinningNode、ComputeNode、IndirectDraw
- 自动回退 WebGL2（不支持的用户静默切换）
- 成熟度 ~75%，对 GTS-Play 多人路径够用（不需要后处理/自定义 shader）
- 移动端：Chrome Android 149+ ✅，Safari iOS 26.0+ ✅，QQ/UC/百度浏览器 ❌（走回退）

### 迁移成本（多人路径）
- ThreeRenderer 改动 ~15 行，其余文件 0 行（IRenderer 抽象保护）
- 工期 2-3 天（升级 three + 双后端 + 验证）
- ⚠️ 如果先加 WebGL 专用功能（EffectComposer/GLSL），将来重写成本 2-3 倍

### GPU-Driven Pipeline
- 积木齐全（ComputeNode/StorageBuffer/IndirectDraw/Atomic），管线需手写
- GPU 碰撞检测 把握 75%（骨骼矩阵已在 GPU，逻辑简单）← 推荐第一优先级
- GPU LOD 把握 85%（逻辑简单，多人场景收益大）
- Instance Frustum Cull 把握 75%
- Hi-Z 遮挡剔除 把握 55%（多 pass 调度不确定）
- Meshlet Triangle Cull 把握 25%（研究级）

### 多线程
- **动画分层**：MMD + FBX 小人动画 → CPU Worker 执行；海量敌人动画 → GPU-Driven Pipeline (GPU Skin)
- Logic Worker (MMD动画 + OBB/寻路) 把握 90%，现在就能做，不依赖 WebGPU
- OffscreenCanvas + Data-Oriented SAB 架构可行（把握 70%），但工程量大（4-6周）
- 核心原则：SAB 存纯数据，Worker 维护独立 Scene + 对象池，双缓冲 + AtomicNotify

### 迁移铁律（现在就该做的）
1. 动画用纯数据接口（已做到：`setMMDAnimation(id, name, duration)`）
2. Entity 状态 TypedArray 化（方便将来映射 SAB）
3. 新功能走 TSL，不走 GLSL（`material.onBeforeCompile`）
4. 不走 WebGL 专用 API（`getContext()`/`getExtension()`/`WEBGL_*`）
5. 不碰 WebGLRenderTarget，用通用 RenderTarget
6. 渲染层不持有游戏状态（当前 MultiplayerRender 已做到）
7. Game Logic 不直接碰 Three.js（通过 IRenderer）

### 方案文档
- 总体分析：`D:\Github\GTS-Play\笔记\方案\WebGPU与多线程迁移分析.md`
- 具体改造方案（含代码）：`D:\Github\GTS-Play\笔记\方案\多人联网架构改造-WebGPU多线程就绪.md`
  - **动画分层**：CPU Worker (MMD + FBX 少量角色动画+碰撞) + GPU Pipeline (海量敌人 GPU Skin)
  - EntityStore (TypedArray 数据层，SAB 就绪)
  - IRenderer 扩展 (BackendCapabilities + Compute + syncFromEntityStore)
  - 对象池渲染 + 后处理走 TSL
  - Logic Worker (MMD + FBX 动画 + OBB 碰撞) → SAB 输出
  - GPU Swarm (Compute Skin + Frustum Cull + LOD + Indirect Draw)
  - SAB 双缓冲 + Render Worker
  - 8 项改造，5 个 Phase，向后兼容

---

*记忆持续更新中*
