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
- **更新项目文档**（memory/ 中的项目文档）

## 任务完成通知

- **任何任务完成后必须发飞书通知兄弟**，内容 **不超过 10 个字**
- **需要兄弟确认的场景也要发飞书通知**（不超过 10 个字）：给出方案后、完成需求后、完成任务后，都要发通知让兄弟切回来确认
- 飞书用户 ID：`ou_2412e799eac60d83f54ecb2601f0ba80`
- 通知方式：`cron add` 一次性 job + delivery announce feishu
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

## 关键决策

### MMD IK 修复 (`_animatePMXMesh`)
- Loop 前 save/zero mesh.transform + `mesh.updateMatrixWorld(true)` → IK 在 mesh-local 空间解算
- 修改文件：`packages/meta3d-jiehuo-abstract/src/three/MMDAnimationHelper.js`

### 移动朝向
- `handleCubeNotMove` 不碰 `rotationY`，保持最后一次移动朝向
- `applyMove` 用 `atan2(moveX, moveZ)` 计算
- 空闲时相机旋转不追踪模型（客户端渲染层待优化）

### 通知协议
- 改 logic 后重启 room-service（不是 match-service）+ copy dist 到 `room-service/dist/logic/`
- Match-service 不直接运行 logic 代码，走 HTTP/WS 调 room-service

---

*记忆持续更新中*
