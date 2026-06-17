# AGENTS.md

> 工作协议详见 MEMORY.md → 工作协议

## 🔄 模型切换检测

- 每条消息收到后，先检查 Dashboard 是否被兄弟手动切了模型（对比 runtime model 和上次已知的模型）
- 如果发现切换了 → 立即用 `session_status()` 切回原来的模型，并提醒兄弟「Dashboard 切换被检测到，已切回 XXX」
- 兄弟想换模型 → 他直接告诉我，我来切

## 💓 Heartbeats

- 收到心跳时批量检查（邮件+日历+通知）
- 23:00-08:00 不主动打扰
- 定期 review memory/ 并清理过期信息
