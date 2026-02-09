# embeddings-fix

Auto-generate comprehensive README.md files by analyzing project structure and configuration.

## Features

- Diagnose memory search issues
- Configure local embeddings model
- Fix index problems
- Test search functionality

## Installation

```bash
# Clone repository
git clone https://github.com/18gogogo/openclaw-embeddings-fix.git ~/.openclaw/workspace/skills/embeddings-fix

# Create symlink
ln -sf ~/.openclaw/workspace/skills/embeddings-fix ~/.openclaw/skills/embeddings-fix

# Restart OpenClaw (optional)
openclaw reset
```

## Usage

### Tool Usage
```json
{
  "tool": "embeddings_fix",
  "arguments": {
    "action": "diagnose"
  }
}
```

### Script Usage
```bash
# Diagnose
bash ~/.openclaw/skills/embeddings-fix/scripts/fix.sh diagnose

# Fix
bash ~/.openclaw/skills/embeddings-fix/scripts/fix.sh fix

# Reindex
bash ~/.openclaw/skills/embeddings-fix/scripts/fix.sh reindex
```

## Configuration

Ensure `~/.openclaw/openclaw.json` contains:

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

## Model Information

| Property | Value |
|----------|-------|
| Name | embeddinggemma-300M-Q8_0.gguf |
| Size | 314 MB |
| Dimensions | 768 |
| Auto-download | Yes (first use) |

## Use Cases

- Memory search returns empty results
- Enable local embeddings (no OpenAI API key required)
- Index corruption needing reindex
- Migration or upgrade requiring reconfiguration

## Prerequisites

- OpenClaw installed
- Node.js environment
- Network connection (for model download)

## Compatibility

- OpenClaw 2026.2.3+
- Qwen 2.5 series models
- Ubuntu 24.04 (N100)

## Author

OpenClaw System

## License

MIT
