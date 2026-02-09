# 本地 Embeddings 記憶搜索修復 Skill

## 概述
本 Skill 用於修復和配置 OpenClaw 的本地_embeddings 智能搜索功能。當遇到記憶搜索問題或需要重新配置時，可以使用本 Skill。

## 功能
- 診斷記憶搜索問題
- 配置本地 embeddings 模型
- 修復索引問題
- 測試搜索功能

## 使用場景
- 記憶搜索返回空結果
- 想要啟用本地 embeddings（不需要 OpenAI API key）
- 索引損壞需要重新索引
- 遷移或升級後需要重新配置

## 前置條件
- OpenClaw 已安裝
- Node.js 環境
- 網絡連接（下載本地模型需要）

## 使用方法

### 方式一：手動執行修復
```bash
# 1. 檢查當前狀態
openclaw memory status

# 2. 如果有問題，執行修復腳本
bash ~/.openclaw/skills/embeddings-fix/scripts/fix.sh

# 3. 重新索引
openclaw memory index

# 4. 驗證
openclaw memory status
```

### 方式二：使用工具調用
```
工具: embeddings_fix
參數: {"action": "diagnose" | "fix" | "reindex" | "test", "query": "可選搜索詞"}
```

## 參數說明

### action 參數
- `diagnose`: 診斷當前狀態，報告問題
- `fix`: 自動修復已知問題
- `reindex`: 重新索引所有記憶文件
- `test`: 測試搜索功能，可選指定搜索詞

### query 參數
- 可選的搜索詞，用於測試搜索功能
- 示例: "測試" 或 "embeddings"

## 範例

### 範例 1：診斷問題
```json
{
  "tool": "embeddings_fix",
  "arguments": {
    "action": "diagnose"
  }
}
```

### 範例 2：執行修復
```json
{
  "tool": "embeddings_fix",
  "arguments": {
    "action": "fix"
  }
}
```

### 範例 3：測試搜索
```json
{
  "tool": "embeddings_fix",
  "arguments": {
    "action": "test",
    "query": "測試"
  }
}
```

### 範例 4：完整修復流程
```json
{
  "tool": "embeddings_fix",
  "arguments": {
    "action": "reindex"
  }
}
```

## 修復腳本內容 (fix.sh)

腳本會執行以下操作：

```bash
#!/bin/bash

echo "=== 本地 Embeddings 修復腳本 ==="

# 1. 檢查目錄結構
echo "1. 檢查目錄結構..."
mkdir -p ~/.openclaw/workspace/memory/

# 2. 複製記憶文件
echo "2. 複製記憶文件..."
cp ~/.openclaw/memory/*.md ~/.openclaw/workspace/memory/ 2>/dev/null || true

# 3. 重新索引
echo "3. 重新索引..."
openclaw memory index

# 4. 驗證
echo "4. 驗證狀態..."
openclaw memory status

echo "=== 修復完成 ==="
```

## 配置說明

### openclaw.json 配置
本 Skill 需要以下配置（通常已預設）：

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

### 模型信息
- **名稱**: embeddinggemma-300M-Q8_0.gguf
- **大小**: 314 MB
- **維度**: 768
- **來源**: HuggingFace (ggml-org)
- **自動下載**: 是（首次使用時）

## 輸出說明

### 診斷輸出
- **Provider**: 當前使用的 embeddings  provider（應為 local）
- **Model**: 使用的模型名稱
- **Indexed**: 已索引的文件數
- **Vector dims**: 向量維度（應為 768）
- **Issues**: 發現的問題

### 修復輸出
- **Status**: 修復後的狀態
- **Indexed files**: 索引的文件數
- **Chunks**: 索引的塊數

## 故障排除

### 問題 1：索引顯示 0/0 files
**原因**: 記憶文件不在正確目錄
**解決**:
```bash
mkdir -p ~/.openclaw/workspace/memory/
cp ~/.openclaw/memory/*.md ~/.openclaw/workspace/memory/
openclaw memory index
```

### 問題 2：Provider 不是 local
**原因**: 配置未正確設置
**解決**: 檢查 openclaw.json 中的 memorySearch 配置

### 問題 3：模型下載失敗
**原因**: 網絡連接問題
**解決**: 
1. 檢查網絡連接
2. 手動下載模型：
```bash
mkdir -p ~/.openclaw/models/embeddings/
cd ~/.openclaw/models/embeddings/
curl -L -o embeddinggemma-300M-Q8_0.gguf \
  "https://huggingface.co/ggml-org/embeddinggemma-300M-GGUF/resolve/main/embeddinggemma-300M-Q8_0.gguf"
```

### 問題 4：搜索返回空結果
**原因**: 索引損壞或文件未被索引
**解決**:
```bash
openclaw memory index
openclaw memory status
```

## 重要提醒

### 目錄結構
- **記憶文件**: ~/.openclaw/workspace/memory/
- **模型緩存**: ~/.openclaw/models/embeddings/
- **配置文件**: ~/.openclaw/openclaw.json

### 權限要求
- 需要能夠讀寫 ~/.openclaw/ 目錄
- 需要執行 openclaw 命令

## 與 Qwen 模型的兼容性

本 Skill 已針對 Qwen 系列模型優化：
- ✅ qwen2.5:14b-instruct-q8_0-ctx131072
- ✅ qwen2.5:32b-instruct-q4_1-ctx64k
- ✅ qwen-coder-64k:latest

所有指令和參數都使用簡單的中文描述，方便模型理解和執行。

## 相關資源

- **詳細文檔**: ~/memory/memory-embeddings-fix.md
- **配置示例**: 參考 SKILL.md 中的配置說明
- **OpenClaw 文檔**: https://docs.openclaw.ai/

## 版本信息
- **版本**: 1.0.0
- **創建日期**: 2026-02-09
- **作者**: OpenClaw System
- **兼容性**: OpenClaw 2026.2.3+
