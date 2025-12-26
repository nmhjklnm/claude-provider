#!/bin/bash
# ============================================================================
# cl - Claude API Provider Switcher
# ============================================================================
# 公共模块：定义全局变量、颜色、工具函数
#
# 使用方式：
#   source "${CL_ROOT}/cl.d/_common.sh"
#
# 提供：
#   - 配置文件路径 CONFIG_FILE
#   - 终端颜色常量 GREEN, RED, BLUE, YELLOW, CYAN, DIM, NC
#   - check_config()  - 检查配置文件是否存在
#   - mask_key()      - 将 API Key 中间部分替换为 ...
#   - log_success()   - 输出成功信息（绿色）
#   - log_error()     - 输出错误信息（红色）
#   - log_info()      - 输出提示信息（蓝色）
#   - log_warn()      - 输出警告信息（黄色）
# ============================================================================

# -----------------------------------------------------------------------------
# 配置
# -----------------------------------------------------------------------------
CONFIG_FILE="$HOME/.claude/providers.json"

# -----------------------------------------------------------------------------
# 终端颜色（ANSI escape codes）
# 用法: echo -e "${GREEN}成功${NC}"
# -----------------------------------------------------------------------------
GREEN='\033[0;32m'   # 成功、当前选中
YELLOW='\033[1;33m'  # 警告、提示操作
BLUE='\033[0;34m'    # 信息、标题
RED='\033[0;31m'     # 错误
CYAN='\033[0;36m'    # 次要信息
DIM='\033[2m'        # 灰色/暗淡（用于 key 等敏感信息）
NC='\033[0m'         # 重置颜色

# -----------------------------------------------------------------------------
# 日志函数
# -----------------------------------------------------------------------------

# 输出成功信息
# 用法: log_success "操作完成"
log_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# 输出错误信息并退出
# 用法: log_error "发生错误"
log_error() {
    echo -e "${RED}✗ 错误: $1${NC}" >&2
}

# 输出信息
# 用法: log_info "正在处理..."
log_info() {
    echo -e "${BLUE}$1${NC}"
}

# 输出警告
# 用法: log_warn "请注意..."
log_warn() {
    echo -e "${YELLOW}! $1${NC}"
}

# -----------------------------------------------------------------------------
# 工具函数
# -----------------------------------------------------------------------------

# 检查配置文件是否存在
# 如果不存在则输出错误并退出
check_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "配置文件不存在: $CONFIG_FILE"
        echo "请先添加供应商: cl add <name> <url> <key>"
        exit 1
    fi
}

# 将 API Key 中间部分替换为 ...
# 用法: masked=$(mask_key "sk-abcdefghijklmnop")
# 输出: sk-abc...mnop
mask_key() {
    local key="$1"
    local len=${#key}
    if [[ $len -le 12 ]]; then
        echo "$key"
    else
        echo "${key:0:6}...${key: -6}"
    fi
}

# 获取当前默认供应商名称
get_default_provider() {
    jq -r '.default' "$CONFIG_FILE"
}

# 检查供应商是否存在
# 用法: if provider_exists "yunwu"; then ...
provider_exists() {
    local name="$1"
    local exists=$(jq -r ".providers[\"$name\"] // empty" "$CONFIG_FILE")
    [[ -n "$exists" ]]
}

# 获取所有供应商名称（数组）
# 用法: names=($(get_provider_names))
get_provider_names() {
    jq -r '.providers | keys[]' "$CONFIG_FILE"
}

# 获取供应商配置
# 用法: url=$(get_provider_field "yunwu" "url")
get_provider_field() {
    local name="$1"
    local field="$2"
    jq -r ".providers[\"$name\"].$field" "$CONFIG_FILE"
}
