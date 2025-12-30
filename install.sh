#!/bin/bash
# ============================================================================
# cl - 安装脚本
# ============================================================================
# 用法: curl -fsSL https://raw.githubusercontent.com/nmhjklnm/claude-provider/main/install.sh | bash
# ============================================================================

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  cl - Claude API Provider Switcher 安装程序${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 安装目录
INSTALL_DIR="$HOME/.claude/bin"
REPO_URL="https://raw.githubusercontent.com/nmhjklnm/claude-provider/main"

# 创建目录
echo -e "\n${YELLOW}[1/4]${NC} 创建安装目录..."
mkdir -p "$INSTALL_DIR/cl.d"

# 下载主脚本
echo -e "${YELLOW}[2/4]${NC} 下载 cl 主程序..."
curl -fsSL "$REPO_URL/cl" -o "$INSTALL_DIR/_cl"
chmod +x "$INSTALL_DIR/_cl"

# 下载模块
echo -e "${YELLOW}[3/4]${NC} 下载模块..."
modules=("_common.sh" "help.sh" "list.sh" "switch.sh" "add.sh" "remove.sh" "rename.sh" "update.sh" "init.sh")
for mod in "${modules[@]}"; do
    curl -fsSL "$REPO_URL/cl.d/$mod" -o "$INSTALL_DIR/cl.d/$mod"
done

# Download VERSION file
if curl -fsSL "$REPO_URL/VERSION" -o "$INSTALL_DIR/VERSION" 2>/dev/null; then
    :
fi

# 配置 shell
echo -e "${YELLOW}[4/4]${NC} 配置 shell..."

# Shell 函数 (需要添加到 .zshrc 或 .bashrc)
SHELL_FUNC='
# BEGIN cl-provider
# cl - Claude API Provider Switcher
_cl_load_env() {
    local config="$HOME/.claude/providers.json"
    [[ -f "$config" ]] || return 0
    # 使用 jq 可靠地读取 JSON 字段
    if ! command -v jq &> /dev/null; then
        return 0
    fi
    local default=$(jq -r ".default // empty" "$config" 2>/dev/null)
    [[ -z "$default" ]] && return 0
    local url=$(jq -r ".providers[\"$default\"].url // empty" "$config" 2>/dev/null)
    local key=$(jq -r ".providers[\"$default\"].key // empty" "$config" 2>/dev/null)
    [[ -n "$url" ]] && export ANTHROPIC_BASE_URL="$url"
    [[ -n "$key" ]] && export ANTHROPIC_API_KEY="$key"
}
cl() {
    "$HOME/.claude/bin/_cl" "$@"
    local ret=$?
    if [[ $ret -eq 0 && "$1" != "help" && "$1" != "-h" && "$1" != "--help" && "$1" != "list" && "$1" != "ls" && "$1" != "init" && "$1" != "test" && "$1" != "version" && "$1" != "--version" && "$1" != "--ver" && "$1" != "-v" ]]; then
        _cl_load_env
    fi
    return $ret
}
_cl_load_env  # 启动时加载
# END cl-provider
'

# 检测 shell 配置文件
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.profile"
fi

# 检查是否已安装
if grep -q "cl - Claude API Provider Switcher" "$SHELL_RC" 2>/dev/null; then
    echo -e "  ${YELLOW}已存在配置，跳过${NC}"
else
    echo "$SHELL_FUNC" >> "$SHELL_RC"
    echo -e "  ${GREEN}已添加到 $SHELL_RC${NC}"
fi

# 初始化配置文件
if [[ ! -f "$HOME/.claude/providers.json" ]]; then
    echo '{"default": "", "providers": {}}' > "$HOME/.claude/providers.json"
fi

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  安装完成!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\n运行以下命令使配置生效："
echo -e "  ${BLUE}source $SHELL_RC${NC}"
echo -e "\n然后尝试："
echo -e "  ${BLUE}cl help${NC}"
echo ""
