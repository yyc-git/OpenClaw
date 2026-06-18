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
- 测试后 → 重启服务端清除脏数据

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

- 飞书通知目标（旧bot）：`user:ou_2412e799eac60d83f54ecb2601f0ba80`
- 飞书通知目标（新bot）：`user:ou_eeb0faa83444e9b2d85a4ce4f8845a8d`
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

## Token 优化协议 v2

### 🔴 edit 优先于 write（最高优先）
- 改动 < 20 行 → 用 `edit`（精确文本替换），**不需要** `read` 全文
- 改动 > 20 行 → 先 `read(offset, limit=10)` 采样确认 → 再用 `edit`
- 只有新建文件 / 完全重写 → 才用 `write`
- 不确定改动范围 → 先 `Select-String -List` 定位 → `read(offset, limit=10)` → `edit`

### exec 管道收敛（每次 exec 必须做）
- `| Select-Object -First 5` / `-Last 5` 截断输出
- `| Select-String "pattern" -List` 搜到即停
- `2>$null` 过滤 stderr
- Windows 用 `(Get-ChildItem | Measure-Object -Property Length -Sum).Sum / 1MB`，不用 `du -sh`
- 计数用 `(Select-String "pattern" | Measure-Object).Count`，不用 `grep -c`
- 同类独立命令合并到 1 个 exec（见下方标准模板）
- 搜索限 `D:\Github\GTS-Play\` 范围，排除 `node_modules`、`.git`、`dist`

### 读文件优化
- 大文件用 `offset`/`limit` 采样（>100 行必做）
- 已在上下文里的文件不重复读
- 搜关键字段用 `Select-String -List`，不用 `read` 整文件
- 小文件用 `Get-Content -TotalCount N`
- Skill 文件：会话首次读后记摘要，后续触发用摘要判断（版本号变了才重读）

### Git 操作精简
- `git status --porcelain | Select-Object -First 20`（不用 `git status` 全量）
- `git log --oneline -10`
- `git diff --stat` 先看统计，再加 `-- <file>` 看具体

### exec 标准模板
| 操作 | 命令 |
|------|------|
| 搜代码 | `Select-String -Path "packages\*\*.ts" -Pattern "..." -List -ErrorAction SilentlyContinue` |
| tsc 错误 | `tsc --noEmit 2>&1 \| Select-String "error TS" \| Select-Object -First 10` |
| 服务日志 | `Get-Content log.txt -Tail 20` |
| BDD 单feature | `npx jest --testPathPattern="feature-name" 2>&1 \| Select-String "✓\|✗\|PASS\|FAIL" \| Select-Object -First 15` |
| 合并检查 | git status --porcelain + git diff --stat + 文件计数 写一个 exec |

### 验证脚本优化
- 临时代码文件允许写，但：直接跑，不行就原地改，不删了重写
  - 用 `exec(yieldMs)` + `process.poll(timeout)` 单次等结果
  - 验证成功后**清理临时文件**，不提交

### BDD / 测试优化
- 每次至多跑 1 轮测试：`exec(yieldMs=15000)` → 没返回则 `process.poll(timeout=15000)`
- 输出用 `2>&1 | Select-String "✓|✗|PASS|FAIL|Error" | Select-Object -First 15` 截断
- 不重复跑失败的测试（除非修复后有理由相信通过了）
- 能用 `--testPathPattern` 定位单个 feature 就别全跑

### yield / 等待优化
- yieldMs 设到刚好够的时长（多数命令 8-15s），不要设 30s+ 空等
- 长进程跑在 background，不 poll 等

### 通用
- 不确定的内容先用 `Select-String -List` 搜出位置，再 `read(offset, limit)` 读
- 不在 exec 里写即用即删的临时脚本
- 多重检查（git状态+diff+文件计数）合并到1个 exec，用 `echo '---SECTION---'` 分隔

## compaction

- reserveTokens=700000（DeepSeek v4 Pro 上下文 1M → 30% 即 300K 触发压缩，700K 缓冲）

## Skill 注册表

> 摘要索引：`.skill-index.md`（SHA 匹配则用摘要，不重读 SKILL.md）

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
