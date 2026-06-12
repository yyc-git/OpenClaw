# MEMORY.md

## 兄弟

- 游戏开发者，中文，时区 Asia/Shanghai (UTC+8)
- 叫我「兄弟」，我回「兄弟」🤜🤛，不是主仆

## 工作协议

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

## 任务完成通知

- **任何任务完成后必须发消息通知兄弟**，不管是不是后台/子会话
- **优先飞书**（已配好渠道），手机上也能收到
- **需要兄弟确认的情况也必须发飞书通知**，不干等
- **等回复期间保持 NO_REPLY，不消耗 token**
- 飞书用户 ID：`ou_2412e799eac60d83f54ecb2601f0ba80`
- 通知方式：`cron add` 一次性 job，`delivery: { mode: "announce", channel: "feishu", to: "user:ou_..." }`
- **通知内容 <10 字**

## 已接入渠道

- **微信** ✅ | **QQ Bot** ✅（AppID: 1904014751） | **Discord** ❌（GFW墙了）

## 项目：GTS-Play

- 路径: `D:/Github/GTS-Play/`，Lerna monorepo, Three.js + React
- 完整记忆: `D:\Github\GTS-Play\memory\CONSOLIDATED-MEMORY.md`
- 项目索引: `D:\Github\GTS-Play\memory\GTS-Play-Project-Index.md`
- 代码规范/架构详见上述文档
- **记忆优先存到项目文档中**，内容尽量详细
- 每次保存记忆时，顺便检查更新项目文档（日期、状态等）

## 开发流程

1. 复杂改动 → **先出 Spec → 兄弟确认 → 写代码 → 走测试**
2. 关键决策（为什么选 A 不选 B、踩了什么坑）提炼到 MEMORY.md
3. 子会话写代码 → 主会话跑 BDD → 报错自动修复 → 补新测试 → 全过 → 飞书通知

## QMD 记忆系统

已启用 ✅ 后端 QMD v2.5.2，模型共 ~2.1GB（embeddinggemma-300M + qwen3-reranker-0.6b + qmd-query-expansion-1.7B），SQLite at C:\sqlite，RTX 2060 SUPER（Vulkan）GPU 加速。已启用会话索引。

## 黑话

- 「小龙虾」= 喊我（OpenClaw-bot）

## 代码规范（要点）

- 详细中文注释、函数式编程、纯函数优先、state 不可变
- 详见 `D:\Github\GTS-Play\memory\CONSOLIDATED-MEMORY.md#八设计原则`

## 同步源文件（硬性规定）

- **`.ts` → 改 `.ts` 再 `tsc`**，**`.res` → 改 `.res` 再 `rescript build`**，不要直接改 `.js`
- 改 `.gen.tsx` → 必须同步改 `.res`，否则下次编译覆盖
- 服务端代码改完 `.ts` → `tsc` → 重启服务

## GitHub 同步

- SSH remote（`git@github.com:yyc-git/OpenClaw.git`，SSH 不会被 GFW 封）
- 同步脚本：`skills/openclaw-backup-sync/scripts/auto-sync.ps1`
- 排除：credentials/、tmp_*.json、*.log、node_modules/

# compaction 配置
- reserveTokens=800000（20% 就自动压缩）

---

*记忆持续更新中*
