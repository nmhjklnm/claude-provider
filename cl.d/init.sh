#!/bin/bash
# ============================================================================
# cl init - 测试所有供应商连接
# ============================================================================
# 并发向所有配置的供应商发送测试请求
# 使用 Claude Haiku 4.5 模型进行连通性测试
#
# 输出:
#   ✓ provider-name          # 连接成功
#   ✗ provider-name (错误)   # 连接失败
# ============================================================================

# 测试单个供应商连接（内部函数）
_test_single_provider() {
    local name="$1"
    local url="$2"
    local key="$3"

    # 发送测试请求（超时 10 秒）
    local response=$(curl -s -w "\n%{http_code}" --max-time 10 \
        "${url}/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: ${key}" \
        -H "anthropic-version: 2023-06-01" \
        -d '{
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 10,
            "messages": [{"role": "user", "content": "1+1=? A:2 B:3 只回答字母"}]
        }' 2>/dev/null)

    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')

    if [[ "$http_code" == "200" ]]; then
        echo -e "${GREEN}✓${NC} $name"
    else
        # 尝试解析错误信息
        local error=$(echo "$body" | jq -r '.error.message // .message // "未知错误"' 2>/dev/null || echo "连接失败")
        echo -e "${RED}✗${NC} $name (${http_code}: ${error})"
    fi
}

# 并发测试所有供应商
init_test() {
    check_config

    log_info "测试所有供应商连接..."
    echo ""

    local tmp_dir=$(mktemp -d)
    local names=($(get_provider_names))

    # 并发启动测试（每个供应商一个后台进程）
    for name in "${names[@]}"; do
        local url=$(get_provider_field "$name" "url")
        local key=$(get_provider_field "$name" "key")
        (_test_single_provider "$name" "$url" "$key" > "$tmp_dir/$name") &
    done

    # 等待所有测试完成
    wait

    # 按顺序输出结果
    for name in "${names[@]}"; do
        cat "$tmp_dir/$name"
    done

    # 清理临时文件
    rm -rf "$tmp_dir"

    echo ""
    echo -e "${DIM}使用 claude-haiku-4-5-20251001 模型测试${NC}"
}
