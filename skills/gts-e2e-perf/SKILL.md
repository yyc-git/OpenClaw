---
name: "gts-e2e-perf"
description: "兄弟说「e2e性能」「性能测试」时触发。双窗口+CDP Profiler录制，自动分析FPS/CPU热点+飞书短通知。"
---

# E2E 性能测试（硬性操作规程）

> 触发词：兄弟说「e2e性能」/「性能测试」/「性能录制」。
> 双窗口 + CDP Profiler 录制，用户操控，自动分析摘要 + 飞书短通知。

---

## 步骤

### Step 1：启动性能录制脚本

运行命令：
```
node D:\Github\GTS-Play\packages\frontend\test\e2e\e2e-scenario3.cjs
```

- 工作目录：`D:\Github\GTS-Play\packages\frontend`
- 以 background 模式运行
- 脚本流程：
  - 双窗口并排登录（P1 创房，P2 加入）
  - 每个窗口右上角出现「▶ 录制此窗口」按钮
  - 用户点要录制的窗口的按钮 → CDP Profiler 启动
  - 浮层实时显示 FPS + 已录制时长
  - 用户点「⏹ 停止」或 2 分钟超时 → 自动分析

启动后告知兄弟：「✅ 性能录制已就绪，双窗口并排，点要录制的窗口上的「▶ 录制此窗口」，操作角色，点停止结束」

### Step 2：等待录制完成

- 不 poll，等脚本自然退出
- 用户自己操控：点开始 → 操作角色 → 点停止

### Step 3：输出分析 + 飞书短通知

脚本退出后，在会话中输出：

```
=== 性能摘要 — player1 (28.3s) ===

FPS：平均 106 | 最低 29

耗时 Top 函数：
1. renderThree  485ms (17.1%)
2. animateMMD   312ms (11.0%)
3. updateBones  198ms (7.0%)

API 耗时：
- Move 平均 2.1ms (N=47)
- GameState 间隔 平均 33ms

建议：renderThree 占比偏高，考虑 LOD 或裁剪优化
```

飞书短通知（≤10 字）：
```
openclaw message send --channel feishu --target "<FEISHU_TARGET>" --message "性能录制完成 ✅"
```

---

## 执行纪律

1. 跑固定脚本 `e2e-scenario3.cjs`，不动态生成
2. 原始数据自动保存到 `test/e2e/monitor/`
3. 不 poll，等脚本自然退出
4. 分析结果在会话中给出，飞书只发短提醒
5. 和 `gts-e2e-test`（手动双窗口）、`gts-e2e-auto`（自动验收）互不触发
