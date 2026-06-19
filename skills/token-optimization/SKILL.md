---
name: "token-optimization"
description: "Token优化：调用链预检、搜索合并、jest静默、E2E不debug停止按钮、增量测试、精准读文件"
---

# Token 预算优化协议

> 每次对话自动生效。目标是减少不必要的 token 消耗。

## 调用链预检
- 改某个函数前，先 `Select-String` 确认：谁调它、它调谁
- 避免修了 `setEnterGame` 但实际没人调的路径

## 搜索合并
- 多个模式一次搜索：
  ```
  Select-String "pattern1|pattern2|pattern3"
  ```
- 不用反复 Select-String 同一个目录

## 精准读文件
- 优先 `offset` + `limit`，不读完整文件
- 调 `read` 前先估算需要的行数范围

## Jest 精简
- 必加 `--silent` 压掉 console.log/console.warn
- 改完代码只跑新增/相关的测试文件：`--testPathPattern "file-name"`
- 不跑全量测试套件

## E2E poll 精简
- 启动后单次 poll（5-10s 超时），确认进游戏即告知用户，不反复 poll
- **停止按钮被点 = 用户主动停止，不分析不重试**
- 不注入专用 log（无验收标准时）
- E2E 输出只显示关键状态行，不全文贴

## Exec 管道收敛
- 复杂操作一次 exec 完成，不拆多个
- 尽量用管道 `|` 连接而不是多次 `;`

## 读文件优化
- 优先 `Select-String` 定位再 `read` 精确段
- 避免 `read` 整个大文件

## edit 优先
- 用 `edit` 做精确替换，不用 `read` 全文再 `write` 整文件

## 三步法
1. 先 `Select-String` 搜索定位
2. `read` 精确行范围
3. `edit` 修改

## Git 精简
- 提交时 diff 摘要就够了，不贴全量 diff
