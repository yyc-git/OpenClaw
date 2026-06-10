# MEMORY.md

## 主人

- 游戏开发者，使用中文交流，时区 Asia/Shanghai (UTC+8)
- 他叫我「兄弟」，我回他「兄弟」🤜🤛
- 互相叫兄弟，不是主仆关系

## 工作协议
- 兄弟下指令后，**先回一句确认信息**再开始干活
- 重启 Gateway 时直接自动重启，不问
- 大改动/架构变化：先出方案等兄弟确认，确认后再实现
- 小改动：直接搞，事后给详细总结
- 兄弟手动测试前，注意检查是否需要重启服务端清除脏数据
- **取消自动化测试（Playwright auto-test.cjs）**，只跑 BDD 测试
- 实现代码后直接告诉兄弟，不跑任何测试
- 兄弟喊测试时再跑 BDD 测试
- **改 dist 时必须同步改 src（TS源文件），两边保持一致**
- **改 webpack 配置后，必须重启 webpack-dev-server 才能生效**
- **涉及修改 node_modules 的操作，必须先经兄弟确认！**
- BDD 测试后，重启服务端清除脏数据，方便兄弟手动测试

## 测试策略（必须遵守）
每次实现需求、修 Bug、更新代码时：
1. **先改代码**（实现需求/修复 Bug）
2. **然后更新测试用例**（改/删/新增）
3. **运行测试**
4. 如果有报错 → 先出方案，确认后直接修复
5. 继续循环，直到全部通过

## 重构策略（必须遵守）
改代码后，检查是否需要重构：
- 单个文件超过 **500 行** → 考虑拆分
- 单个函数超过 **100 行** → 考虑拆分
- **有重复代码** → 合并/提取
- **代码不方便测试**（依赖过重、依赖太多外部环境）→ 解耦

如需重构：
1. **给出重构方案**（要动哪些文件、怎么拆、影响范围）
2. **等兄弟确认**后再动手
3. 重构完走测试流程（改测试 → 跑测试 → 修到过）

**影响小的重构**（如重命名、提取小函数、删除死代码等）直接搞，事后说一声就行。

## 任务完成通知
- **后台任务/子会话完成后，必须发消息通知兄弟**，不静默结束
- 因为兄弟可能在别的 tab，不会盯着等
- **优先通过飞书发送通知**（已配好 feishu 渠道），切出去也能在手机上收到
- 飞书用户 ID：`ou_2412e799eac60d83f54ecb2601f0ba80`
- 通知内容包含：做了什么、结果、下一步（如果有）

## 已接入的渠道
- **微信** — 正常
- **QQ Bot** — 已接入（AppID: 1904014751）
- **Discord** — 已配但被GFW墙了，目前禁用

## 多人联机改造（状态同步 MVP）
- 2026-06-08：基于已有帧同步 demo（basic1）创建了状态同步 MVP（new_basic2）
- 做了完整的状态同步改造：服务端 authoritative tick 循环 + 状态插值渲染
- 目录：`demos/new_basic2/`（客户端），`demos/room-service/`（服务端，Game.ts 重写）
- 服务端端口 4003，客户端 dev server 端口 8094
- 技术栈：TSRPC WebSocket + 自定义 meta3d 引擎
- 2026-06-08 13:04：跑通！两个玩家联机成功，方块移动+碰撞检测正常
- 关键决策：去掉 meta3d 引擎（setLocalPosition 运行时不生效），改用纯 Three.js 渲染
- 包大小：20.6MB → 7.95MB

## 优化
- thinking 级别改为 low（日常），高复杂度任务用子会话跑 high

## 已接入的数据源
- **DeepSeek 网页版** — 已登录，可查历史对话
- **博客园** — https://www.cnblogs.com/chaogex
- **知乎** — https://www.zhihu.com/people/chaogex
- **GTS-Play 项目** — 本地代码

## 项目

### GTS-Play
- 路径: `D:/Github/GTS-Play/`
- Lerna monorepo, Three.js + React
- 单位类型: Giantess、LittleMan、Army（步兵/车辆/炮塔）、Boss
- 包含: packages, mods, demos, asset-lib, defaults, teach, mine, doc

### 多人联机架构
- 服务端: `packages/room-service/`（WebSocket, 15FPS tick, port 4003）
- 共享逻辑: `packages/logic/`（playerState, executeCommand, isCollision）
- 客户端渲染: `ThreeRenderer` 实现 `IRenderer` 接口
- 渲染循环: `Loop.loopForMultiplayer(15)` → `renderFrame()`
- MVP 页面: `ui_layer/index/multiplayer/components/MultiplayerHall.tsx`
- BDD 测试: `packages/logic/test/`（5 场景）, `packages/frontend/test/`（6 场景）
- 自动化测试: `packages/frontend/test/multiplayer/auto-test.cjs`（Playwright）

---

## 工作协议
- 需要重启服务端时直接自动重启，不问
- 需要重启 Gateway 时直接自动重启，不问
- **架构变化、设计思考** → 尽量全部记录（做什么、为什么、取舍）
- **代码修改** → 尽量详细记录要点，因为后续新对话中要继续改（改了哪些文件、改动内容、注意点）
- 重要的决定、偏好、项目进展都归档到 memory/
- 跟踪文件：memory/save-state.json
- **GTS-Play 项目相关工作都要记录详细记忆**，便于新对话快速复现上下文

## 开发流程（2026-06-10 起）
1. 复杂改动：**先出 Spec → 兄弟确认 → 再写代码 → 走测试流程**
2. 关键决策（为什么选 A 不选 B、踩了什么坑）提炼到 MEMORY.md，不只是记流水账
3. 充分利用 QMD + session 索引，定期把 memory log 中的关键决策提炼到 MEMORY.md

---

## QMD 记忆系统
- 已启用 ✅（2026-05-26）
- 后端：QMD v2.5.2（本地语义搜索引擎）
- 模型：embeddinggemma-300M + qwen3-reranker-0.6b + qmd-query-expansion-1.7B（共 ~2.1GB）
- 使用 hf-mirror.com 下载 GGUF 模型
- SQLite at C:\sqlite，bun at ~\.bun\bin
- GPU 加速：RTX 2060 SUPER（Vulkan）
- 已启用会话索引（sessions.enabled = true）

---

## 黑话
- 「小龙虾」= 喊我（OpenClaw-bot）

## 代码规范
- 所有代码必须提供详细的中文注释，说明函数的作用、参数含义、返回值
- **rescript 中尽量不要用 `%raw`，必须用时需先问兄弟确认**
- **对象字面量用函数返回**（如 `let getX = () => {...}`），避免全局修改
- 尽量用函数式编程，不用 class
- **state 作为参数传入，修改后返回新 state，不修改入参**
- 逻辑层、接口层、抽象层的代码都必须要写 BDD 测试
- 优先写：纯函数、算法、依赖外部较少的代码
- UI 代码可以不写 BDD 测试（有必要时通知兄弟）
- 测试复杂时先通知兄弟，由他决定是否继续

## yarn 修复
`demos/` 和 `packages/` 有同名包时 yarn workspace 会冲突。
修复方法：在项目根目录执行 `yarn clean`，然后 `yarn bootstrap`。

重命名项目后也要执行 `yarn bootstrap`（不需要先 clean）。

一般不需要先 `yarn clean`，除非依赖坏了需要重装依赖。

新增项目到已有 workspace glob（如 `packages/*`）后，只需 `yarn install` 即可更新链接，不用跑完整的 `yarn bootstrap`。

如果新项目无/少外部 npm 依赖（纯源码），可以在 `node_modules` 直接建 junction 加速：
```bash
cd D:\Github\GTS-Play\node_modules
mklink /J meta3d-commonlib-new ..\packages\meta3d-commonlib-new
```

## GitHub 自动同步
- 远程仓库：https://github.com/yyc-git/OpenClaw.git（master 分支）
- ~~每整点自动同步（已取消）~~
- 同步脚本：`skills/openclaw-backup-sync/scripts/auto-sync.ps1`
- 排除：credentials/、tmp_*.json、*.log、node_modules/

## Token 节省优化
- AGENTS.md 精简：2042→1004 tok（砍半）
- context pruning 已启用（cache-ttl, 5min）
- 后台 cron 用 DeepSeek Chat 轻模型 + light-context

---

*记忆持续更新中*
