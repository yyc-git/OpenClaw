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
2. **然后补上/更新测试用例**（改/删/新增），**不能漏**
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
- **任何任务完成后，必须发消息通知兄弟**，不管是不是子会话/后台任务
- 因为兄弟可能在别的 tab，不会盯着等
- **优先通过飞书发送通知**（已配好 feishu 渠道），切出去也能在手机上收到
- **需要兄弟确认/回复的情况，也必须发飞书通知**，不要干等
- **等待兄弟回复/确认期间，不要消耗 token**，保持 NO_REPLY
- **发完飞书通知后 = 任务结束**，不要回复飞书 bot，等兄弟进一步指示
- 飞书用户 ID：`ou_2412e799eac60d83f54ecb2601f0ba80`
- 飞书通知方式：使用 cron announce（代替 sessions_send/message）
- **飞书通知内容必须小于 10 个字**，简短到飞书消息卡片能直接显示一句话
  ```json
  // 一次性通知
  cron add job={
    name: "feishu-notify",
    schedule: { kind: "at", at: "<ISO-timestamp>" },
    payload: { kind: "agentTurn", message: "告诉用户：<通知内容>", lightContext: true },
    delivery: { mode: "announce", channel: "feishu", to: "user:ou_2412e799eac60d83f54ecb2601f0ba80" },
    sessionTarget: "isolated",
    deleteAfterRun: true,
    timeoutSeconds: 30
  }
  ```
  优点：不创建持久会话，不积累上下文，用完即删，token 消耗极低

## 已接入的渠道
- **微信** — 正常
- **QQ Bot** — 已接入（AppID: 1904014751）
- **Discord** — 已配但被GFW墙了，目前禁用

## 项目

### GTS-Play
- 路径: `D:/Github/GTS-Play/`
- Lerna monorepo, Three.js + React
- 单位类型: Giantess、LittleMan、Army、Boss
- 完整记忆：`D:\Github\GTS-Play\memory\CONSOLIDATED-MEMORY.md`
- 项目索引：`D:\Github\GTS-Play\memory\GTS-Play-Project-Index.md`
- 代码规范/yarn修复/多人联机架构等详见上述文档

---

## 工作协议
- 需要重启服务端时直接自动重启，不问
- 需要重启 Gateway 时直接自动重启，不问
- **架构变化、设计思考** → 尽量全部记录（做什么、为什么、取舍）
- **代码修改** → 尽量详细记录要点，因为后续新对话中要继续改（改了哪些文件、改动内容、注意点）
- 重要的决定、偏好、项目进展都归档到 memory/
- 跟踪文件：memory/save-state.json
- **GTS-Play 项目相关工作，记忆优先存到 `D:\Github\GTS-Play\memory\` 下的项目文档中**，内容尽量详细，便于新对话快速复现上下文
- 每次保存记忆时，顺便检查并更新项目文档（日期、状态、头信息等）

## 工作方式优化（2026-06-11）
1. **grep 代替 read** — 用 `Select-String` 定位信息，需要时才 `read` 全文
2. **上下文裁剪** — 跑 `/compact` 压缩旧上下文
3. **logic/ 中只有 .res 代码**，不包含 .ts 文件
4. **客户端只渲染，服务端做逻辑** — 旋转补偿等在 Movement.res 处理

## 开发流程（2026-06-10 起）
1. 复杂改动：**先出 Spec → 兄弟确认 → 再写代码 → 走测试流程**
2. 关键决策（为什么选 A 不选 B、踩了什么坑）提炼到 MEMORY.md，不只是记流水账
3. 充分利用 QMD + session 索引，定期把 memory log 中的关键决策提炼到 MEMORY.md

## 子会话→代码→测试→通知 完整流程
1. **子会话写代码**（high thinking，直接改文件，不依赖跨会话消息）
2. **主会话跑 BDD 测试**
3. **有错误 → 自动修复**（如 MockRenderer 缺接口方法）
4. **无错误 → 检查是否需要新增 BDD 测试**（覆盖改动的代码）
5. **全部通过 → 飞书通知兄弟**
   - 使用 cron announce 一次性通知（详见上方「飞书通知方式」）

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
- 详见 `D:\Github\GTS-Play\memory\CONSOLIDATED-MEMORY.md#八设计原则`
- 要点：详细中文注释、函数式编程、纯函数优先、state 不可变

## 同步源文件（硬性规定）
- **`.ts` → 改 `.ts` 再 `tsc` 编译**，不要直接改 `.js`
- **`.res` → 改 `.res` 再 `rescript build` 编译**，不要直接改 `.js`
- 改 `.gen.tsx`（生成的 TS 类型）→ 必须同步改 `.res`
- 否则下次编译会覆盖手动改动，源文件不一致
- 服务端代码改完 `.ts` → `tsc` 编译 → 重启服务

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
