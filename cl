#!/bin/bash
# ============================================================================
# cl - Claude API Provider Switcher
# ============================================================================
# 管理多个 Claude API 供应商配置，快速切换
#
# 快速开始:
#   cl                      # 查看当前供应商
#   cl list                 # 查看所有供应商
#   cl <name>               # 切换供应商
#   source ~/.zshrc         # 使切换生效
#
# 完整命令:
#   cl help                 # 查看所有命令
#
# 项目结构:
#   ~/.claude/bin/cl        # 本文件（入口）
#   ~/.claude/bin/cl.d/     # 模块目录
#     ├── _common.sh        # 公共变量和函数
#     ├── help.sh           # 帮助信息
#     ├── list.sh           # list 命令
#     ├── switch.sh         # 切换命令
#     ├── add.sh            # add 命令
#     ├── remove.sh         # remove 命令
#     ├── rename.sh         # rename 命令
#     └── init.sh           # init/test 命令
#   ~/.claude/providers.json # 供应商配置
# ============================================================================

set -e

# 获取脚本所在目录
CL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CL_MODULES="${CL_ROOT}/cl.d"

# -----------------------------------------------------------------------------
# 加载模块
# -----------------------------------------------------------------------------
source "${CL_MODULES}/_common.sh"
source "${CL_MODULES}/help.sh"
source "${CL_MODULES}/list.sh"
source "${CL_MODULES}/switch.sh"
source "${CL_MODULES}/add.sh"
source "${CL_MODULES}/remove.sh"
source "${CL_MODULES}/rename.sh"
source "${CL_MODULES}/init.sh"

# -----------------------------------------------------------------------------
# 命令路由
# -----------------------------------------------------------------------------
case "${1:-}" in
    # 无参数：显示当前供应商
    "")
        show_current
        ;;

    # 帮助
    "help"|"-h"|"--help")
        show_help
        ;;

    # 列出供应商
    "list"|"ls")
        list_providers
        ;;

    # 添加供应商
    "add")
        add_provider "$2" "$3" "$4"
        ;;

    # 删除供应商
    "rm")
        remove_provider "$2"
        ;;

    # 重命名供应商
    "rename"|"mv")
        rename_provider "$2" "$3"
        ;;

    # 测试连接
    "init"|"test")
        init_test
        ;;

    # 切换供应商（默认行为）
    *)
        switch_provider "$1"
        ;;
esac
