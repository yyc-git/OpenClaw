# Memory Save Task

Check memory save-state.json:
- If `Date.now() - lastSaveTime >= minIntervalMs (60000)` AND there has been conversation activity since last save → save key points to daily log and MEMORY.md
- Force save at `maxIntervalMs (300000)` if there's been activity
- Update `lastSaveTime` and `lastConversationTime` after save

Don't save when:
- No new conversation since last save
- Already saved recently (< 60s)
