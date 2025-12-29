#!/bin/bash
# ============================================================================
# cl rename - 重命名供应商
# ============================================================================
# 将现有供应商重命名为新名称
# 用法: cl rename <旧名称> <新名称>
# ============================================================================

rename_provider() {
    local old_name="$1"
    local new_name="$2"

    # 检查配置文件
    check_config

    # 参数验证
    if [[ -z "$old_name" ]]; then
        log_error "请指定要重命名的供应商名称"
        echo "用法: cl rename <旧名称> <新名称>"
        exit 1
    fi

    if [[ -z "$new_name" ]]; then
        log_error "请指定新的供应商名称"
        echo "用法: cl rename <旧名称> <新名称>"
        exit 1
    fi

    # 检查旧名称是否存在
    if ! provider_exists "$old_name"; then
        log_error "供应商 '$old_name' 不存在"
        echo "使用 'cl list' 查看所有供应商"
        exit 1
    fi

    # 检查新名称是否已存在
    if provider_exists "$new_name"; then
        log_error "供应商 '$new_name' 已存在，无法重命名"
        echo "请选择其他名称或先删除现有供应商"
        exit 1
    fi

    # 获取当前默认供应商
    local default_provider=$(get_default_provider)

    # 使用 jq 重命名供应商
    local temp_file="${CONFIG_FILE}.tmp"

    # 重命名 providers 中的 key
    jq --arg old "$old_name" --arg new "$new_name" \
       '.providers |= (to_entries | map(if .key == $old then .key = $new else . end) | from_entries)' \
       "$CONFIG_FILE" > "$temp_file"

    # 如果重命名的是默认供应商，同时更新 default 字段
    if [[ "$default_provider" == "$old_name" ]]; then
        jq --arg new "$new_name" '.default = $new' "$temp_file" > "${temp_file}.2"
        mv "${temp_file}.2" "$temp_file"
    fi

    # 原子替换配置文件
    mv "$temp_file" "$CONFIG_FILE"

    log_success "供应商已重命名: $old_name → $new_name"

    # 如果是默认供应商，提示重新加载
    if [[ "$default_provider" == "$old_name" ]]; then
        log_info "已更新默认供应商为: $new_name"
        log_warn "请运行 'source ~/.zshrc' 或 'source ~/.bashrc' 使更改生效"
    fi
}
