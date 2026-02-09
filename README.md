# embeddings-fix Skill

## 描述
本地 Embeddings 記憶搜索修復 Skill - 用於修復和配置 OpenClaw 的本地 embeddings 智能搜索功能。

## 功能
- 診斷記憶搜索問題
- 配置本地 embeddings 模型
- 修復索引問題
- 測試搜索功能

## 安裝方法
```bash
# 1. 克隆倉庫
git clone https://github.com/jiulingyun/openclaw-embeddings-fix.git ~/.openclaw/workspace/skills/embeddings-fix

# 2. 創建符號鏈接
ln -sf ~/.openclaw/workspace/skills/embeddings-fix ~/.openclaw/skills/embeddings-fix

# 3. 重啟 OpenClaw（可選）
openclaw reset
```

## 使用方法

### 使用工具
```json
{
  "tool": "embeddings_fix",
  "arguments": {
    "action": "diagnose"
  }
}
```

### 使用腳本
```bash
# 診斷
bash ~/.openclaw/skills/embeddings-fix/scripts/fix.sh diagnose

# 修復
bash ~/.openclaw/skills/embeddings-fix/scripts/fix.sh fix

# 重新索引
bash ~/.openclaw/skills/embeddings-fix/scripts/fix.sh reindex
```

## 配置
需要確保 ~/.openclaw/openclaw.json 包含以下配置：

```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": true,
        "provider": "local",
        "local": {
          "modelPath": "hf:ggml-org/embeddinggemma-300M-GGUF/embeddinggemma-300M-Q8_0.gguf",
          "modelCacheDir": "~/.openclaw/models"
        }
      }
    }
  }
}
```

## 模型
- 名稱: embeddinggemma-300M-Q8_0.gguf
- 大小: 314 MB
- 維度: 768
- 自動下載: 是（首次使用時）

## 相容性
- OpenClaw 2026.2.3+
- Qwen 2.5 系列模型
- Ubuntu 24.04 (N100)

## 作者
OpenClaw System

## 許可證
MIT
