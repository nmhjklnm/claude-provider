#!/bin/bash
# ============================================================================
# cl help - 显示帮助信息
# ============================================================================
# 输出所有可用命令及其用法
# ============================================================================

show_help() {
    cat << 'EOF'
cl - Claude API 供应商切换工具

用法:
  cl                      显示当前供应商
  cl <name>               切换到指定供应商
  cl list, ls             列出所有供应商
  cl add <name> <url> <key>  添加供应商
  cl rm <name>            删除供应商
  cl init                 测试所有连接
  cl help                 显示帮助

示例:
  cl                      # 查看当前
  cl yunwu                # 切换到 yunwu
  cl ls                   # 列出所有
  cl add qwen https://api.qwen.com sk-xxx

配置: ~/.claude/providers.json
EOF
}
