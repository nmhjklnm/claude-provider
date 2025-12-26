#!/bin/bash
# ============================================================================
# cl remove - 删除供应商
# ============================================================================
# 用法: cl remove <name>
#
# 注意:
#   - 不能删除当前默认供应商（请先切换到其他供应商）
# ============================================================================

remove_provider() {
    local name="$1"

    # 参数校验
    if [[ -z "$name" ]]; then
        log_error "请指定供应商名称"
        echo "用法: cl remove <name>"
        exit 1
    fi

    check_config

    # 检查是否存在
    if ! provider_exists "$name"; then
        log_error "供应商 '$name' 不存在"
        exit 1
    fi

    # 不能删除当前默认
    local default=$(get_default_provider)
    if [[ "$name" == "$default" ]]; then
        log_error "不能删除当前默认供应商"
        echo "请先切换到其他供应商: cl <other-name>"
        exit 1
    fi

    # 删除（原子写入）
    local tmp=$(mktemp)
    jq "del(.providers[\"$name\"])" "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"

    log_success "已删除供应商: $name"
}
