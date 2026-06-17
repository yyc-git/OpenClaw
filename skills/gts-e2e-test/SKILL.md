---
name: "gts-e2e-test"
description: "兄弟说「e2e测试」「e2e」「e2e test」时触发。启动手动双窗口测试脚本，完毕后飞书通知。"
---

# E2E 手动测试（硬性操作规程）

> 触发词：兄弟说「e2e测试」/「e2e」/「e2e test」。
> 启动双 Playwright 窗口，兄弟手动测试，点停止后发飞书通知。

---

## 步骤

### Step 1：启动测试脚本

运行命令：
```
node D:\Github\GTS-Play\packages\frontend\test\e2e\e2e-scene2-manual.cjs
```

- 工作目录：`D:\Github\GTS-Play\packages\frontend`
- 以 background 模式运行（脚本会打开双浏览器窗口，长期运行）
- 启动后告知兄弟：「✅ E2E 双窗口已启动，操作角色测试，点停止按钮结束」

### Step 2：等待测试结束

- 脚本在后台运行，用户操作窗口中的人物测试
- 用户点任一窗口的 **「⏹ 停止」** 按钮后，脚本自动关闭浏览器并退出
- **不要主动 poll 脚本状态**，等兄弟说「停了」或脚本自然结束

### Step 3：发送飞书通知

脚本结束后，发飞书通知：

```
openclaw message send --channel feishu --target "user:ou_2412e799eac60d83f54ecb2601f0ba80"
```

通知内容：`E2E 手动测试已结束 ✅`

---

## 执行纪律

1. 脚本只启动一次，不重复跑
2. 等待期间**不 poll、不催促**，兄弟自己操作
3. **不拉日志**——脚本结束后直接通知，不执行任何日志收集
4. 测试结束只发飞书，不额外分析或出报告
5. 如果兄弟中途说「停下」或「停止」，kill 对应进程
