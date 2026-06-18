---
name: "token-optimization"
description: "Token 预算优化规则：edit优先、路径验证、E2E poll精简、三步法、exec管道收敛、读文件优化、Git精简。每次对话自动生效。"
---

# Token 优化协议 v3

> 每次对话自动生效。目标：每个 feat 控制在 ~60k tokens 以内。

---

## 🔴 edit 优先于 write（最高优先）

- 改动 < 20 行 → 用 `edit`（精确文本替换），**不需要** `read` 全文
- 改动 > 20 行 → 先 `Select-String -List` 定位 → `read(offset, limit=10)` 采样确认 → 再用 `edit`
- 只有新建文件 / 完全重写 → 才用 `write`
- **同文件多处改动合并到 1 个 edit**（多个 edits[]），减少重复读

## 🟡 路径验证（import/require 防错）

- **写完动态导入立刻验证**：`tsc --noEmit` 或 `Get-ChildItem -Path "目标路径" -ErrorAction SilentlyContinue`
- 不要等 webpack/jest 报错再修（损失 ~8k tokens/轮）
- require/import 路径规则：
  - 同级目录：`./`
  - 上一级：`../`
  - 上两级：`../../`（很少用，仔细数目录层级）
- **新依赖预判 jest 兼容性**：ESM 包需加 `transformIgnorePatterns` + mock

## 🟡 E2E poll 优化

- 首次 poll 给足够 timeout（30-60s），后续只 poll 1-2 次
- 不要循环 poll 等进展（损失 ~10k tokens/分钟）
- E2E 日志只取最后 15 行：`Get-Content -Tail 15` 或 `Select-Object -Last 15`

## 🟡 三步法（先搜→再读→后改）

- Step 1：`Select-String -List` 搜关键符号/函数名，定位文件+行号
- Step 2：`read(offset, limit=10)` 采样确认上下文
- Step 3：`edit` 精确替换
- **禁止**：不知道文件内容就直接 `read` 全量
- **禁止**：已经在上下文中的文件重复 `read`

## exec 管道收敛（每次 exec 必须做）

- `| Select-Object -First 5` / `-Last 5` 截断输出
- `| Select-String "pattern" -List` 搜到即停
- `2>$null` 过滤 stderr
- Windows 用 `(Get-ChildItem | Measure-Object -Property Length -Sum).Sum / 1MB`，不用 `du -sh`
- 计数用 `(Select-String "pattern" | Measure-Object).Count`，不用 `grep -c`
- 同类独立命令合并到 1 个 exec（见下方标准模板）
- 搜索限 `D:\Github\GTS-Play\` 范围，排除 `node_modules`、`.git`、`dist`

## 读文件优化

- 大文件用 `offset`/`limit` 采样（>100 行必做）
- 已在上下文里的文件不重复读
- 搜关键字段用 `Select-String -List`，不用 `read` 整文件
- 小文件用 `Get-Content -TotalCount N`
- Skill 文件：会话首次读后记摘要，后续触发用摘要判断（版本号变了才重读）

## Git 操作精简

- `git status --porcelain | Select-Object -First 20`（不用 `git status` 全量）
- `git log --oneline -10`
- `git diff --stat` 先看统计，再加 `-- <file>` 看具体

## exec 标准模板

| 操作 | 命令 |
|------|------|
| 搜代码 | `Select-String -Path "packages\\*\\*.ts" -Pattern "..." -List -ErrorAction SilentlyContinue` |
| tsc 错误 | `tsc --noEmit 2>&1 \| Select-String "error TS" \| Select-Object -First 10` |
| 服务日志 | `Get-Content log.txt -Tail 20` |
| BDD 单feature | `npx jest --testPathPattern="feature-name" 2>&1 \| Select-String "✓\\|✗\\|PASS\\|FAIL" \| Select-Object -First 15` |
| 合并检查 | git status --porcelain + git diff --stat + 文件计数 写一个 exec |

## 验证脚本优化

- 临时代码文件允许写，但：直接跑，不行就原地改，不删了重写
  - 用 `exec(yieldMs)` + `process.poll(timeout)` 单次等结果
  - 验证成功后**清理临时文件**，不提交

## BDD / 测试优化

- 每次至多跑 1 轮测试：`exec(yieldMs=15000)` → 没返回则 `process.poll(timeout=15000)`
- 输出用 `2>&1 | Select-String "✓|✗|PASS|FAIL|Error" | Select-Object -First 15` 截断
- 不重复跑失败的测试（除非修复后有理由相信通过了）
- 能用 `--testPathPattern` 定位单个 feature 就别全跑

## yield / 等待优化

- yieldMs 设到刚好够的时长（多数命令 8-15s），不要设 30s+ 空等
- 长进程跑在 background，不 poll 等

## 通用

- 不确定的内容先用 `Select-String -List` 搜出位置，再 `read(offset, limit)` 读
- 不在 exec 里写即用即删的临时脚本
- 多重检查（git状态+diff+文件计数）合并到1个 exec，用 `echo '---SECTION---'` 分隔
