#!/bin/bash

#==============================================================================
# 本地 Embeddings 智能搜索修復腳本
# 
# 功能：
# 1. 診斷當前記憶搜索配置
# 2. 修復常見問題
# 3. 重新索引記憶文件
# 
# 使用方法：
#   bash embeddings-fix/scripts/fix.sh
#
# 參數：
#   diagnose - 只診斷，不修復
#   fix      - 診斷並修復
#   reindex  - 只重新索引
#   status   - 只顯示狀態
#
#==============================================================================

set -e  # 遇到錯誤時退出

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 輸出函數
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 路徑變量
MEMORY_DIR="$HOME/.openclaw/memory"
WORKSPACE_MEMORY_DIR="$HOME/.openclaw/workspace/memory"
MODELS_DIR="$HOME/.openclaw/models"
EMBEDDINGS_MODELS_DIR="$MODELS_DIR/embeddings"
CONFIG_FILE="$HOME/.openclaw/openclaw.json"

#==============================================================================
# 診斷函數
#==============================================================================

diagnose() {
    print_header "本地 Embeddings 診斷報告"
    
    # 檢查配置文件
    print_info "檢查配置文件..."
    if [ -f "$CONFIG_FILE" ]; then
        print_success "配置文件存在: $CONFIG_FILE"
        
        # 檢查是否有 memorySearch 配置
        if grep -q "memorySearch" "$CONFIG_FILE"; then
            print_success "memorySearch 配置已找到"
            
            # 檢查 provider
            if grep -q '"provider": "local"' "$CONFIG_FILE"; then
                print_success "Provider 設置為 local"
            else
                print_warning "Provider 可能不是 local"
            fi
        else
            print_warning "memorySearch 配置不存在"
        fi
    else
        print_error "配置文件不存在: $CONFIG_FILE"
    fi
    
    echo ""
    
    # 檢查模型
    print_info "檢查本地 embeddings 模型..."
    if [ -f "$EMBEDDINGS_MODELS_DIR/embeddinggemma-300M-Q8_0.gguf" ]; then
        MODEL_SIZE=$(du -h "$EMBEDDINGS_MODELS_DIR/embeddinggemma-300M-Q8_0.gguf" | cut -f1)
        print_success "本地模型已存在: embeddinggemma-300M-Q8_0.gguf ($MODEL_SIZE)"
    else
        print_warning "本地模型不存在，將在首次使用時自動下載"
    fi
    
    echo ""
    
    # 檢查記憶目錄
    print_info "檢查記憶目錄..."
    if [ -d "$WORKSPACE_MEMORY_DIR" ]; then
        FILE_COUNT=$(ls -1 "$WORKSPACE_MEMORY_DIR"/*.md 2>/dev/null | wc -l)
        print_success "記憶目錄存在: $WORKSPACE_MEMORY_DIR ($FILE_COUNT 個文件)"
    else
        print_error "記憶目錄不存在: $WORKSPACE_MEMORY_DIR"
    fi
    
    echo ""
    
    # 檢查 OpenClaw 狀態
    print_info "檢查 OpenClaw 記憶狀態..."
    if command -v openclaw &> /dev/null; then
        STATUS=$(openclaw memory status 2>&1)
        echo "$STATUS" | head -10
        
        if echo "$STATUS" | grep -q "Provider: local"; then
            print_success "使用本地 embeddings"
        elif echo "$STATUS" | grep -q "Provider: openai"; then
            print_warning "使用 OpenAI embeddings（如果沒有 API key會失敗）"
        fi
        
        if echo "$STATUS" | grep -q "Indexed: 0/0"; then
            print_error "沒有索引任何文件！"
        else
            print_success "已有索引"
        fi
    else
        print_error "openclaw 命令不存在"
    fi
    
    echo ""
    print_header "診斷完成"
}

#==============================================================================
# 修復函數
#==============================================================================

fix() {
    print_header "開始修復本地 Embeddings 配置"
    
    # 步驟 1: 確保目錄結構正確
    print_info "步驟 1/4: 創建正確的目錄結構..."
    mkdir -p "$WORKSPACE_MEMORY_DIR"
    mkdir -p "$EMBEDDINGS_MODELS_DIR"
    print_success "目錄結構已創建"
    
    # 步驟 2: 複製記憶文件
    print_info "步驟 2/4: 複製記憶文件到正確目錄..."
    if [ -d "$MEMORY_DIR" ]; then
        cp "$MEMORY_DIR"/*.md "$WORKSPACE_MEMORY_DIR/" 2>/dev/null || true
        COPIED=$(ls -1 "$WORKSPACE_MEMORY_DIR"/*.md 2>/dev/null | wc -l)
        print_success "已複製 $COPIED 個記憶文件"
    else
        print_warning "源目錄不存在: $MEMORY_DIR"
    fi
    
    # 步驟 3: 確保配置正確
    print_info "步驟 3/4: 檢查配置文件..."
    if [ -f "$CONFIG_FILE" ]; then
        if grep -q "memorySearch" "$CONFIG_FILE"; then
            print_success "memorySearch 配置已存在"
        else
            print_warning "需要手動添加 memorySearch 配置到 $CONFIG_FILE"
        fi
    else
        print_error "配置文件不存在"
    fi
    
    # 步驟 4: 重新索引
    print_info "步驟 4/4: 重新索引記憶..."
    if command -v openclaw &> /dev/null; then
        openclaw memory index
        print_success "索引完成"
    else
        print_error "openclaw 命令不存在，無法索引"
    fi
    
    echo ""
    print_header "修復完成！"
    echo "請執行 'openclaw memory status' 驗證結果"
}

#==============================================================================
# 重新索引函數
#==============================================================================

reindex() {
    print_header "重新索引記憶文件"
    
    # 確保目錄存在
    mkdir -p "$WORKSPACE_MEMORY_DIR"
    
    # 複製新文件
    if [ -d "$MEMORY_DIR" ]; then
        cp "$MEMORY_DIR"/*.md "$WORKSPACE_MEMORY_DIR/" 2>/dev/null || true
    fi
    
    # 重新索引
    if command -v openclaw &> /dev/null; then
        print_info "正在重新索引..."
        openclaw memory index
        print_success "索引完成"
        
        echo ""
        print_info "當前狀態:"
        openclaw memory status | grep -E "(Provider|Model|Indexed|Vector)"
    else
        print_error "openclaw 命令不存在"
    fi
}

#==============================================================================
# 主程序
#==============================================================================

main() {
    echo "=============================================="
    echo "  本地 Embeddings 智能搜索修復腳本"
    echo "=============================================="
    echo ""
    
    ACTION=${1:-"diagnose"}
    
    case $ACTION in
        diagnose)
            diagnose
            ;;
        fix)
            fix
            ;;
        reindex)
            reindex
            ;;
        status)
            if command -v openclaw &> /dev/null; then
                openclaw memory status
            else
                print_error "openclaw 命令不存在"
            fi
            ;;
        help|--help|-h)
            echo "用法: $0 [命令]"
            echo ""
            echo "命令:"
            echo "  diagnose  - 診斷當前配置（默認）"
            echo "  fix       - 診斷並自動修復"
            echo "  reindex   - 重新索引記憶文件"
            echo "  status    - 顯示當前狀態"
            echo "  help      - 顯示此幫助信息"
            echo ""
            echo "示例:"
            echo "  $0              # 診斷"
            echo "  $0 fix          # 修復"
            echo "  $0 reindex      # 重新索引"
            ;;
        *)
            print_error "未知命令: $ACTION"
            echo "使用 '$0 help' 查看幫助"
            exit 1
            ;;
    esac
}

# 執行主程序
main "$@"
