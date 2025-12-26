#!/bin/bash
# ============================================================================
# cl add - 添加新供应商
# ============================================================================
# 用法: cl add <name> <url> <key>
#
# 参数:
#   name  - 供应商名称（用于切换时引用，如 yunwu, openai）
#   url   - API Base URL（如 https://api.openai.com）
#   key   - API Key
#
# 示例:
#   cl add qwen https://api.qwen.ai sk-xxxxxxxxxxxxx
# ============================================================================

add_provider() {
    local name="$1"
    local url="$2"
    local key="$3"

    # 参数校验
    if [[ -z "$name" || -z "$url" || -z "$key" ]]; then
        log_error "参数不完整"
        echo "用法: cl add <name> <url> <key>"
        echo ""
        echo "示例:"
        echo "  cl add qwen https://api.qwen.ai sk-xxxxxxxxxxxxx"
        exit 1
    fi

    check_config

    # 检查是否已存在
    if provider_exists "$name"; then
        log_error "供应商 '$name' 已存在"
        echo "如需更新，请先删除: cl remove $name"
        exit 1
    fi

    # 添加到配置（原子写入）
    local tmp=$(mktemp)
    jq ".providers[\"$name\"] = {\"url\": \"$url\", \"key\": \"$key\"}" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"

    log_success "已添加供应商: $name"
    echo ""
    echo "切换到该供应商:"
    echo "  cl $name && source ~/.zshrc"
}
