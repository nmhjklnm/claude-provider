#!/bin/bash
# ============================================================================
# cl <name> - 切换供应商
# ============================================================================
# 将指定供应商设为默认，持久化到 providers.json
# wrapper 函数会自动重新加载环境变量
# ============================================================================

switch_provider() {
    local name="$1"

    check_config

    # 验证供应商存在
    if ! provider_exists "$name"; then
        log_error "供应商 '$name' 不存在"
        echo "使用 'cl list' 查看可用供应商"
        exit 1
    fi

    # 更新默认供应商（原子写入）
    local tmp=$(mktemp)
    jq ".default = \"$name\"" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"

    # 输出结果
    local url=$(get_provider_field "$name" "url")
    log_success "已切换到: $name"
    echo "  URL: $url"
}
