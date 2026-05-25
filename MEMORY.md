# MEMORY.md

## 主人

- 游戏开发者，使用中文交流，时区 Asia/Shanghai (UTC+8)
- 他叫我「兄弟」，我回他「兄弟」🤜🤛
- 互相叫兄弟，不是主仆关系

## 工作协议
- 兄弟下指令后，**先回一句确认信息**再开始干活
- 重启 Gateway 时直接自动重启，不问

## 已接入的渠道
- **微信** — 正常
- **QQ Bot** — 已接入（AppID: 1904014751）
- **Discord** — 已配但被GFW墙了，目前禁用

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

---

## 工作协议

- 每次对话结束后，**提取重点保存到记忆系统**（daily log + MEMORY.md）
- 保存间隔：最少1分钟，最多5分钟（由 heartbeat 触发检查）
- 重要的决定、偏好、项目进展都归档到 memory/
- 跟踪文件：memory/save-state.json

---

## QMD 记忆系统
- 已启用 ✅（2026-05-26）
- 后端：QMD v2.5.2（本地语义搜索引擎）
- 模型：embeddinggemma-300M + qwen3-reranker-0.6b + qmd-query-expansion-1.7B（共 ~2.1GB）
- 使用 hf-mirror.com 下载 GGUF 模型
- SQLite at C:\sqlite，bun at ~\.bun\bin
- GPU 加速：RTX 2060 SUPER（Vulkan）

---

*记忆持续更新中*
