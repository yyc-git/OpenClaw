---
name: "gts-e2e-auto"
description: "兄弟说「e2e自动」时触发。动态生成脚本 → 采集数据 → 验证目标 → 会话分析 + 飞书短通知。"
---

# E2E 自动测试（硬性操作规程）

> 触发词：兄弟说「e2e自动」/「自动e2e」/「自动测试」，附带操作描述和验证目标。
> 动态生成测试脚本 → 采集自定义数据 → 验证目标 → 结果分析 + 飞书短通知。

---

## 步骤

### Step 1：解析输入 + 设计日志

兄弟格式示例：
```
e2e自动测试：
操作巨大娘往小人方向移动，使其在移动时与小人碰撞；
验证：小人血量至少减少5点
```

**解析出：**
- **操作序列：** 巨大娘向小人方向移动，制造碰撞
- **验证目标：** 小人血量至少减少 5 点

**设计专用日志：** 在注入页面的 logger 中增加自定义 hook，采集验证所需的数据字段。例如血量验证：

```js
// 注入到页面的日志采集 hook
window.__e2eVerify = { 
  target: 'hp',
  initialHp: null,
  minHp: null,
};

// 拦截 GameState 消息，提取 hp 字段
const origOnMessage = ws.onmessage;
ws.onmessage = (e) => {
  const data = JSON.parse(e.data);
  if (data.type === 'GameState') {
    const myHp = data.players.find(p => p.id === myId)?.hp;
    if (window.__e2eVerify.initialHp === null) {
      window.__e2eVerify.initialHp = myHp;
    }
    if (myHp < (window.__e2eVerify.minHp ?? Infinity)) {
      window.__e2eVerify.minHp = myHp;
    }
  }
  if (origOnMessage) origOnMessage.call(this, e);
};
```

### Step 2：生成并运行脚本

以 `e2e-scenario2-auto.cjs` 为模板，修改：
- **操作部分：** 替换为兄弟描述的操作序列（如巨大娘 WASD 走向小人）
- **日志采集：** 注入 Step 1 设计的专用 hook
- **验收逻辑：** 替换为兄弟指定的验证条件

脚本内置：
- 双 tab 自动登录（P1 创房，P2 加入）
- 执行操作序列
- 专用数据采集（console.log + GameState hook）
- 最多重试 **3 次**，总超时 **1 小时**

生成后保存到 `test/e2e/auto/`，文件名包含日期和描述（如 `e2e-auto-0617-collision-damage.cjs`），不删除。

以 background 模式运行，启动后告知兄弟：「✅ E2E 自动测试已启动，操作：<简述>，验证：<简述>」

### Step 3：验证 + 会话分析

脚本退出后，检查采集到的数据：

```
采集数据摘要：
- 初始血量：20
- 测试后最低血量：13
- 减少值：7

验证目标：减少 ≥ 5 ✅

结论：E2E 自动测试通过 ✅
```

在会话中输出分析结果，然后发飞书短通知（≤10 字）。

---

## 执行纪律

1. **每次动态生成脚本**——根据兄弟描述定制操作+日志+验证，不跑固定脚本
2. **脚本保留不删除**——保存到 `test/e2e/auto/`，文件名含日期+描述
3. 日志设计要**精准**——只采集验证目标需要的数据，不堆无关日志
4. 重试上限 **3 次**，超时 **1 小时**
5. 结果分析**在会话中给出**，飞书只发短提醒（≤10 字）
6. 和 `gts-e2e-test`（手动双窗口版）互不触发
