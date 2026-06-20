---
name: "gts-screenshot-optimize"
description: "截图分析时自动降质/局部/OCR/先问后图，节省token"
---

# gts-screenshot-optimize - 截图分析 Token 优化

## 触发词
- `截图分析`
- `帮我看下截图`
- 任何需要看图的请求

## 流程

### Step 0：先问不传图
当兄弟说「帮我看下XXX」涉及截图时：
- 先问：「这需要看图还是文字描述就够了？」
- 如果不需要图 → 走正常文字分析，省一次传图 token

### Step 1：确认截图范围
如果需要看图，且兄弟还没发图：
- 问：「想看全屏还是具体哪块区域？」
- 按回答的局部范围处理，不传全屏

如果兄弟已经发了图：
- 自己判断是否局部裁剪更省，可以的话先裁剪再传

### Step 2：优先 exec 提取结构化数据
看图前先判断：图中主要是文字/UI/还是画面本身？

**文字/UI 场景**（日志弹窗、游戏 UI、聊天记录、报错信息等）：
- 尝试用 Lightweight 工具提取文字（OCR / 截图文字识别）
- 只有提取失败时才传图
- OCR 工具优先级：
  1. Windows 自带截图文字提取（如有）
  2. Tesseract OCR（如已安装）
  3. 无工具 → fallback 到 Step 3

**画面/3D 场景**（游戏画面、模型效果等）：
- 无法用文字替代 → 走 Step 3

### Step 3：截图降质
用工具压缩截图后再传给 AI：

尝试顺序：
1. **ImageMagick**（`magick convert`）→ 缩放到宽度 800px + JPEG quality 70%
2. **PowerShell System.Drawing**（`Add-Type -AssemblyName System.Drawing`）→ 同一标准
3. **Windows Photo API** → 兜底压缩

输出规则：
- 最大宽度：800px
- 格式：JPEG（不传 PNG）
- Quality：70%（文字清晰，画面可辨识）
- 原图不删，只在压缩后的副本上操作

### Step 4：传图分析
把处理后的图片传给 AI 做最终分析。

## 依赖探测（自动执行）
在 Step 2/3 开始前自动检查所需工具是否存在：
- `Get-Command magick -ErrorAction SilentlyContinue` → ImageMagick 可用
- `Get-Command tesseract -ErrorAction SilentlyContinue` → Tesseract OCR 可用
- 都没装 → 只走 Step 0 + Step 1 + 最长边 600px 的 PowerShell 缩放

## Token 节省预估
| 优化手段 | 节省幅度 |
|---------|---------|
| Step 0（先问不传图） | 100%（那一轮） |
| Step 1（局部截图） | 50-80% |
| Step 2（OCR替代） | 100%（替代的那次） |
| Step 3（降质压缩） | 60-80% |
| **综合** | **60-90%** |

## 注意事项
- Step 3 压缩只作用于传给 AI 的图，不影响兄弟发的原始截图
- 如果兄弟明确要求「看全屏/不压缩」→ 尊重，不走 Step 3
- 第一次使用 OCR/ImageMagick 需要先安装，问兄弟确认后再装
