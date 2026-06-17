# MEMORY.md

## 兄弟

- 游戏开发者，中文，时区 Asia/Shanghai (UTC+8)
- 叫我「兄弟」，我回「兄弟」🤜🤛，不是主仆
- 黑话：「小龙虾」= 喊我

## 工作协议

- 都在当前会话中进行，不开子会话
- 兄弟下指令 → **先回确认**再干活
- 重启 Gateway/服务端 → 直接自动重启，不问
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

统一使用 **TDD + 契约检查 + 防御式编程**

默认针对**多人联网**部分（room-service + logic/src + frontend/business_layer/multiplayer）
所有改动点（含 frontend）都要覆盖

### feat（实现功能）
1. **出方案 → 飞书通知** → **等确认** → **然后对每个要修改的文件写对应测试**
2. 先增加对应的测试 → 然后运行这些测试（**只跑新增的测试**）→ 应该按照预期而失败
3. 实现功能 → 更新契约检查 → 更新防御式编程
4. 运行测试 → 全通过（**跑全部 BDD 测试**）
5. 重构（大改需再出方案确认）→ 运行测试 → 全通过（**跑全部 BDD 测试**）
6. 看情况更新项目文档
7. **准备好手动测试环境**（webpack-dev-server / 服务端等按需启动）
8. **飞书通知总结（含代码要点，便于兄弟检查）**

### fix（修复）
1. **出方案 → 飞书通知** → **等确认** → **然后对每个要修改的文件写对应测试**
2. 先增加对应的测试 → 然后运行这些测试（**只跑新增的测试**）→ 应该按照预期而失败
3. 修复 → 更新契约检查 → 更新防御式编程
4. 运行测试 → 全通过（**跑全部 BDD 测试**）
5. 看情况更新项目文档
6. **准备好手动测试环境**（webpack-dev-server / 服务端等按需启动）
7. **飞书通知总结（含代码要点，便于兄弟检查）**

### refactor（重构）
1. 出方案 → 飞书通知 → 等确认
2. 重构 → 更新契约检查 → 更新防御式编程
3. 运行测试（**跑全部 BDD 测试**）
4. 看情况更新项目文档
5. **准备好手动测试环境**（webpack-dev-server / 服务端等按需启动）
6. **飞书通知总结（含代码要点，便于兄弟检查）**

### 其它
- 大改：出方案 → 飞书通知 → 等确认 → 修改 → 通知总结
- 小改：直接改 → 通知总结

## 重要记忆

### 状态同步原则
- 最终状态（血量、位置、分数等）直接发送**绝对状态值**，不是变化量
- 客户端自行对比缓存计算差值（浮点数误差/丢包免疫）

### 测试基础设施
- frontend 有 BDD 测试：`test/features/*.feature` + `test/step-definitions/*.steps.ts`
- mock 配置：`jest.multiplayer.json`，mock THREE 在 `test/__mocks__/three-stub.js`
- setup：`test/setup.ts`（含 mock performance/fillRect/clearRect）

## 保存协议

> 注意：保存协议第7步「同步到 GitHub」包含 push，与上面的「提交git」规则不冲突

每次兄弟说「保存」时，执行以下流程：
1. **自动代码审核 + 重构** — 全自动，不打断
   — 读 `.last-review`（存于 `笔记/决策记录/`），`git diff` 出改动文件清单
   — 对每个改动文件执行重构规则（见下表），改完直接跑全部 BDD 测试
   — 测试不通过 → 回退本次重构，记警告到审核摘要
   — 摘要写入 `memory/`，更新 `.last-review = HEAD`

   重构规则表：
   | 优先级 | 规则 | 自动操作 |
   |--------|------|----------|
   | 🔴 | 测试代码残留（`window.__xxx`, `[DBG]`） | 直接删 |
   | 🔴 | 未使用 import | 直接删 |
   | 🟡 | 文件 >500 行 | 按 export 拆文件 |
   | 🟡 | 函数 >100 行 | 提子函数 |
   | 🟡 | 重复代码 ≥3 处 | 提公共函数 |
   | 🟢 | 混合 logic+render 职责 | 记摘要（不自动改） |
   | 🟢 | 条件嵌套 >3 层 | 加 `// TODO: 降低复杂度` |
   | 🟢 | 导出函数缺 JSDoc | 补占位注释 |

2. **更新 BDD 测试** — 检查今天改动的代码（含重构后的），补充/修改 feature + step 文件；修复旧测试中不匹配 API 的命令格式
3. **更新契约检查** — 检查 requireCheck/ensureCheck 是否覆盖了新增/修改的函数；删除的校验路径不补
4. **更新防御式编程** — 检查新增/修改的代码中是否有中间位置的非空/边界校验（不应该用 requireCheck），统一用 `if/else throw` 模式
5. **更新项目文档** — 更新 `笔记/项目文档/GTS-Play-Project-Index.md` 和 `笔记/项目文档/CONSOLIDATED-MEMORY.md`
6. **保存今日记忆** — 更新 `memory/2026-06-16.md` + `MEMORY.md`
7. **同步到 GitHub** — OpenClaw（个人同步）→ `master`，GTS-Play（项目代码）→ `dev`

## 验收规则（硬性规定）

兄弟设置验收标准后：
- 默认必须通过，不通过则一直修改直到通过
- 默认总超时 1 小时
- 每次改完自动跑测试，不通过继续修

## 通知协议

- 改 logic 后重启 room-service（不是 match-service）+ copy dist 到 `room-service/dist/logic/`
- Match-service 不直接运行 logic 代码，走 HTTP/WS 调 room-service
- **任务完成后必须飞书通知**（验证通过/终止/需确认）
- 通知方式：`exec` → `openclaw message send --channel feishu --target "user:ou_2412e799eac60d83f54ecb2601f0ba80"`
- 等回复期间保持 NO_REPLY

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

### exec 管道收敛（每次 exec 必须做）
- `| Select-Object -First 5` / `-Last 5` 截断输出
- `| Select-String "pattern"` 过滤，不用 `| findstr` 再 `| wc -l`
- `2>$null` 过滤 stderr（Node deprecation warnings 是 token 大户）
- `du -sh` 代替 `ls -la`，`Measure-Object` 代替 `grep -c`
- 独立的小命令合并到 1 个 exec（如同时 grep 多个文件，多个轻量检查写在一起）
- 搜索路径加 `-ErrorAction SilentlyContinue`，范围限到 packages/ 内，避免扫 node_modules

### 读文件优化
- 大文件用 `offset`/`limit` 采样，不整篇读（>100 行必做）
- 已在上下文里的文件不重复读
- 搜关键字段用 `Select-String` 而非 `read`，避免读整文件
- 已知路径的小文件（如 `.last-review`）用 `Get-Content -TotalCount N`

### 验证脚本优化
- 临时代码文件（测试协议用）允许写，但：
  - 直接跑，不行就原地改，不删了重写
  - 用 `exec(yieldMs)` + `process.poll(timeout)` 单次等结果，不重复跑
  - 验证成功后直接提交，不删除

### BDD / 测试优化
- 每次至多跑 1 轮测试：`exec(yieldMs=15000)` → 没返回则 `process.poll(timeout=15000)`
- 输出用 `2>&1 | Select-String "关键字段" -First 10` 截断
- 不重复跑失败的测试（除非修复后有理由相信通过了）

### yield / 等待优化
- yieldMs 设到刚好够的时长（多数命令 8-15s），不要设 30s+ 空等
- 长进程（Playwright 窗口）跑在 background，不 poll 等

### 通用
- 不确定的内容先用 `Select-String -List` 搜出位置，再 `read(offset=N, limit=M)` 读
- 不在 exec 里写即用即删的临时脚本

## compaction

- reserveTokens=800000（20% 自动压缩）

## Skill 流程固化

- **gts-dev-workflow** — `feat:` / `fix:` / `refactor:` 触发，TDD+契约+BDD+飞书硬性流程
- **gts-code-review** — `代码审核` / `审核` 触发，全手动 4 步交互式审查
- 两个 Skill 的完整内容见 `skills/gts-dev-workflow/SKILL.md` 和 `skills/gts-code-review/SKILL.md`
- 保存协议不触发 gts-code-review

## 代码审核协议

> 已固化为 Skill（gts-code-review），以下为原始协议留存

兄弟说「代码审核」时进入审核流程：
1. 给出距离上次代码审核或者保存后的代码要点、改动要点
2. 分析需要重构/修改的地方，出方案

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

---

*记忆持续更新中*
