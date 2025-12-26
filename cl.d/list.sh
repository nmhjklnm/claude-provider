#!/bin/bash
# ============================================================================
# cl list - 列出所有供应商
# ============================================================================
# 以表格形式展示：
#   - 供应商名称（当前默认带 * 标记，绿色高亮）
#   - API URL
#   - API Key（中间部分 mask 处理）
# ============================================================================

list_providers() {
    check_config

    local default=$(get_default_provider)

    # 表头
    printf "${BLUE}%-2s %-12s %-35s %s${NC}\n" "" "NAME" "URL" "KEY"
    printf "${DIM}%s${NC}\n" "───────────────────────────────────────────────────────────────────────────"

    # 数据行
    local names=($(get_provider_names))
    for name in "${names[@]}"; do
        local url=$(get_provider_field "$name" "url")
        local key=$(get_provider_field "$name" "key")
        local masked_key=$(mask_key "$key")

        if [[ "$name" == "$default" ]]; then
            # 当前默认供应商：绿色 + 星号标记
            printf "${GREEN}%-2s %-12s${NC} %-35s ${DIM}%s${NC}\n" "*" "$name" "$url" "$masked_key"
        else
            printf "%-2s %-12s %-35s ${DIM}%s${NC}\n" "" "$name" "$url" "$masked_key"
        fi
    done
}

# 显示当前供应商
show_current() {
    check_config

    local default=$(get_default_provider)
    local url=$(get_provider_field "$default" "url")
    local key=$(get_provider_field "$default" "key")
    local masked_key=$(mask_key "$key")

    log_success "当前供应商: $default"
    echo "  URL: $url"
    echo -e "  Key: ${DIM}${masked_key}${NC}"
}
