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

## 测试策略（必须遵守）

每次改代码后：
1. 先改代码
2. **然后补上/更新测试用例，不能漏**
3. 跑测试
4. 报错 → 出方案 → 确认后修复
5. 继续循环直到全过

## 开工规则
- **出方案后必须等兄弟明确说「开工」或「开干」才能动手**
- 「要记住」「好的」不等于同意开工

## 保存协议

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

### 读文件优化
- 大文件用 `offset`/`limit` 采样，不整篇读
- 已在上下文里的文件不重复读

## compaction

- reserveTokens=800000（20% 自动压缩）

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

---

*记忆持续更新中*
