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

## 测试策略（必须遵守）

每次改代码后：
1. 先改代码
2. **然后补上/更新测试用例，不能漏**
3. 跑测试
4. 报错 → 出方案 → 确认后修复
5. 继续循环直到全过

## 重构策略（必须遵守）

改代码后检查：
- 单文件 >500行 → 拆分
- 单函数 >100行 → 拆分
- 重复代码 → 合并/提取
- 代码难测试 → 解耦

需重构 → 出方案等确认 → 走测试流程。小重构（重命名/提函数/删死代码）直接搞，事后说一声。

## 开工规则
- **出方案后必须等兄弟明确说「开工」或「开干」才能动手**
- 「要记住」「好的」不等于同意开工

## 修改代码后必做
- **更新 BDD 测试**
- **更新契约检查**（新加/调整 requireCheck/ensureCheck）
- **更新防御式编程** — 检查新增/修改的代码中是否有中间位置的非空/边界校验（不应该用 requireCheck），统一用 `if/else throw` 模式
- **更新项目文档**（memory/ 中的项目文档）

## 编程流程

统一使用 **TDD + 契约检查 + 防御式编程**

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
5. 重构（大改需方案确认）→ 运行测试 → 全通过（**跑全部 BDD 测试**）
6. 看情况更新项目文档
7. **准备好手动测试环境**（webpack-dev-server / 服务端等按需启动）
8. **飞书通知总结（含代码要点，便于兄弟检查）**

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

## 任务完成通知

- **任何任务完成后必须发飞书通知兄弟**：验收通过、中途终止、需要兄弟确认，都要发
- **验收类任务的通知要详细点**：写明结果（通过/终止）、关键指标、改动要点，10 字不够就多写
- 普通确认场景（方案、需求完成）：可以简短
- 飞书用户 ID：`ou_2412e799eac60d83f54ecb2601f0ba80`
- 飞书用户 ID：`ou_2412e799eac60d83f54ecb2601f0ba80`
- 通知方式（优先级）
  - **首选：`exec` 调用 `OpenClaw message send --channel feishu`**
    - 直接发，不弹窗，不依赖 cron/Task Scheduler
    - 用法：后台 `exec` → `OpenClaw message send --channel feishu --target "user:ou_2412e799eac60d83f54ecb2601f0ba80" --message "消息"`
    - 首次调用初始化 ~10s，后续快
  - **备选：`write` → `notify-queue.txt` + `exec` 后台发**
    - 写队列文件后用 `exec background` 调用 CLI 发
  - **备选2：`sessions_send` 到 feishu direct session**
    - sessionKey: `agent:main:feishu:direct:ou_2412e799eac60d83f54ecb2601f0ba80`
    - 能投递但触发 bot 自动回复
  - ~~`cron add` / Task Scheduler 轮询~~（已弃用）
- **等回复期间保持 NO_REPLY，不消耗 token**（包括发通知后等确认 / 等兄弟测试后反馈）

## 已接入渠道

微信 ✅ | QQ Bot（AppID: 1904014751）✅ | Discord ❌（GFW）

## 项目：GTS-Play

- 路径: `D:/Github/GTS-Play/`，Lerna monorepo, Three.js + React
- 记忆/索引：`memory/CONSOLIDATED-MEMORY.md` + `memory/GTS-Play-Project-Index.md`
- 代码规范/架构详见项目文档
- 每次保存记忆时顺便更新项目文档（日期、状态等）

## 开发流程

复杂改动 → **先出 Spec → 兄弟确认 → 写代码 → 走测试**
关键决策（为什么选 A 不选 B、踩了什么坑）提炼到 MEMORY.md

## QMD 记忆系统

已启用 ✅

## 代码规范（要点）

详细中文注释、函数式编程、纯函数优先、state 不可变
详见 `memory/CONSOLIDATED-MEMORY.md#八设计原则`

## Obsidian 笔记库

游戏项目笔记统一写入 `D:\Github\GTS-Play\笔记/`（Obsidian vault），`memory/` 目录已删除。

| 目录 | 用途 |
|------|------|
| `笔记/项目文档/` | 项目索引、累计记忆（`GTS-Play-Project-Index.md` + `CONSOLIDATED-MEMORY.md`） |
| `笔记/决策记录/` | Bug 修复、架构决策 (ADR) |
| `笔记/方案/` | 重构方案、功能实施方案 |
| `笔记/讨论记录/` | 日常讨论要点 |
| `笔记/代码笔记/` | 代码要点、踩坑记录 |

**保存流程中自动写入 Obsidian：**
- 更新 `笔记/项目文档/GTS-Play-Project-Index.md`
- 更新 `笔记/项目文档/CONSOLIDATED-MEMORY.md`
- 代码有改动 → 生成/更新 `笔记/代码笔记/` 对应条目
- 有重要决策 → 写入 `笔记/决策记录/`

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

## 保存协议

每次兄弟说「保存」时，执行以下流程：
1. **更新 BDD 测试** — 检查今天改动的代码，补充/修改 feature + step 文件；修复旧测试中不匹配 API 的命令格式
2. **更新契约检查** — 检查 requireCheck/ensureCheck 是否覆盖了新增/修改的函数；删除的校验路径不补
3. **更新防御式编程** — 检查新增/修改的代码中是否有中间位置的非空/边界校验（不应该用 requireCheck），统一用 `if/else throw` 模式
4. **更新项目文档** — 更新 `笔记/项目文档/GTS-Play-Project-Index.md` 和 `笔记/项目文档/CONSOLIDATED-MEMORY.md`
5. **保存今日记忆** — 更新 `memory/2026-06-16.md` + `MEMORY.md`
6. **同步到 GitHub** — OpenClaw（个人同步）→ `master`，GTS-Play（项目代码）→ `dev`

## compaction

- reserveTokens=800000（20% 自动压缩）

## 代码审核协议

兄弟说「代码审核」时进入审核流程：
1. 给出距离上次代码审核或者保存后的代码要点、改动要点
2. 分析需要重构/修改的地方，出方案

## 验收规则（硬性规定）

兄弟设置验收标准后：
- 默认必须通过，不通过则一直修改直到通过
- 默认总超时 1 小时
- 每次改完自动跑测试，不通过继续修

## 关键决策

### MMD IK 修复 (`_animatePMXMesh`)
- Loop 前 save/zero mesh.transform + `mesh.updateMatrixWorld(true)` → IK 在 mesh-local 空间解算
- 修改文件：`packages/meta3d-jiehuo-abstract/src/three/MMDAnimationHelper.js`

### 移动朝向
- `handleCubeNotMove` 不碰 `rotationY`，保持最后一次移动朝向

### 架构重构完毕（2026-06-13 19:56）
- `logic_layer/` 零 render 依赖：MMDManager/LittleManManager 纯逻辑状态机，CommandManager 移除 MR import
- `business_layer/multiplayer/` 新建：ManageScene 编排逻辑+渲染，MultiplayerLoop 游戏循环
- 50/50 BDD 测试全过 ✅
- `applyMove` 用 `atan2(moveX, moveZ)` 计算
- 空闲时相机旋转不追踪模型（客户端渲染层待优化）

### 通知协议
- 改 logic 后重启 room-service（不是 match-service）+ copy dist 到 `room-service/dist/logic/`
- Match-service 不直接运行 logic 代码，走 HTTP/WS 调 room-service

### E2E 验收通过（2026-06-16）
- 根因：heartbeat timeout（5s）在 `initForMultiplayer` 加载 FBX 期间触发，导致 WS 断开
- 修复：
  - `MultiplayerManager.connect()` 心跳 timeout 从 5s 改为 15s，加 `_waitWsReady` 确认底层 ready
  - `MultiplayerLoop.loopForMultiplayer()` 加 `mp.isConnected` 守卫，未连接时跳过命令发送
- E2E 测试改用 Playwright（`e2e-pw.cjs`），不依赖 OpenClaw browser CLI
- 场景1/2 跑完后日志先保留，分析总结后问兄弟是否删除

### E2E 调试（2026-06-15）
- 多人联机调试用 `user` profile（chrome-mcp），不开隔离浏览器
- 两个玩家用 `?user=player1` / `?user=player2` URL 参数区分（三处文件改动：backend/Main.ts, App.tsx, Login.tsx）
- 脚本操作优先用 `evaluate` 替代 `snapshot`（0 snapshot，JS 直接操作 DOM）
- `evaluate` 在 openclaw 隔离浏览器下页面未完全加载会挂住，user profile 下正常
- `openclaw browser stop` 不杀 Chrome 进程，需要手动 kill 带 `.openclaw\browser` user-data-dir 的 Chrome 进程
- 服务端启动顺序：room-service → match-service → frontend，必须在同一持续进程中
- E2E 脚本路径：`packages/frontend/test/e2e/e2e-multiplayer.ps1`（场景1）、`e2e-monitor.ps1`（场景2）

#### Console 日志捕获
- `console --level all` 在 `user` profile 下**不捕获页面 console.log**（只抓 Doctor warnings）
- 替代方案：用 `evaluate` 注入拦截器覆写 `console.log`/`error`，写入 `window.__logStore`
- `Get-Logs` 读取并清空 store
- 拦截器跳过 `[RecvMsg] GameState` / `[Client] GameState received`（数据量太大），保留 `[ApiReq]`、`[ApiRes]`、`[ERR]`、`[Client] GameState players:`

#### Tab 切换策略
- `user` profile 通过 Chrome MCP 连接，一次只暴露一个活跃 tab，无法不 focus 就抓指定 tab 的日志
- **场景1（全自动）**：先读当前活跃 tab（player2）再 focus player1，读前 URL 验证，结束时异步开 about:blank
- **场景2（手动玩）**：不 focus，只读当前 tab，不打断用户操作
- tab 关闭：`Start-Process powershell -WindowStyle Hidden` 异步独立进程，不受脚本 kill 影响
- 场景2 的 tab ID 存 `session.json`，手动停时读文件关

### 重构原则（2026-06-13）
- **实现代码中不能有测试代码** — `deps: { loadFbx?: mockFn }` 是测试开后门，不对
- 正确做法：**依赖倒置（DIP）+ 单一职责**
  - MMD 的 Three.js 操作下沉到渲染层（MultiplayerRender），ManageScene 通过 IRenderer 接口操作
  - ThreeRenderer 只做原子渲染操作（addSceneNode/removeSceneNode/setPosition等）
  - `loadFbx` 作为函数参数是正规的 DIP 模式，调用方（MultiplayerLoop）传入真实实现
  - MultiplayerHall 创建 `new MultiplayerRender(new ThreeRenderer())` 组合调用
- **预存错误必须解决** — 发现预存的编译/测试错误后不能跳过

---

*记忆持续更新中*
### Torso 不包含手臂/臀部
- **方案**：GIANTESS_BONE_GROUPS Torso 只用 spatial（上半身2→下半身，radius: 0.95），删 boneNames 兜底
- radius=0.95 < 肩半宽(左肩C/右肩C=1.094) → 排除手臂，Z 方向不覆盖胸部
- boneNames 兜底去掉 → 不包含 TrigoneAndButt 区域（下半身权重顶点）

### E2E 场景1 自动测试（2026-06-16）
- 会话 ba0c6e11 经历 3 轮迭代修复
- **关键发现：** Playwright `page.on('console', ...)` 监听器在页面关闭后会导致赋值失败，变量进入 TDZ
- **修复：** 日志收集变量加 `if (!logs1) continue` 守卫
- **教训：** exec 启动的 Node 进程在会话 abort 后成为孤儿，需要额外清理
- 当前代码已修但未跑通过，状态：代码就绪，待重新执行
