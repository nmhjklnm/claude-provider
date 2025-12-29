#!/bin/bash
# ============================================================================
# cl update - 更新到最新版本
# ============================================================================
# 从 GitHub 仓库下载最新版本的 cl 工具
# 用法: cl update
# ============================================================================

update_cl() {
    local install_dir="$HOME/.claude/bin"
    local repo_url="https://raw.githubusercontent.com/nmhjklnm/claude-provider/main"

    log_info "正在检查更新..."
    echo ""

    # 备份当前版本
    local backup_dir="${install_dir}/.backup.$(date +%s)"
    mkdir -p "$backup_dir"

    if [[ -f "${install_dir}/_cl" ]]; then
        cp "${install_dir}/_cl" "$backup_dir/" 2>/dev/null || true
        cp -r "${install_dir}/cl.d" "$backup_dir/" 2>/dev/null || true
        log_info "已备份当前版本到: $backup_dir"
    fi

    # 下载主脚本
    echo ""
    log_info "下载主程序..."
    if ! curl -fsSL "$repo_url/cl" -o "${install_dir}/_cl.new"; then
        log_error "下载主程序失败"
        rm -f "${install_dir}/_cl.new"
        exit 1
    fi
    chmod +x "${install_dir}/_cl.new"
    mv "${install_dir}/_cl.new" "${install_dir}/_cl"
    log_success "主程序已更新"

    # 下载所有模块
    log_info "下载模块..."
    local modules=("_common.sh" "help.sh" "list.sh" "switch.sh" "add.sh" "remove.sh" "rename.sh" "init.sh" "update.sh")
    local failed=0

    for mod in "${modules[@]}"; do
        if curl -fsSL "$repo_url/cl.d/$mod" -o "${install_dir}/cl.d/${mod}.new" 2>/dev/null; then
            mv "${install_dir}/cl.d/${mod}.new" "${install_dir}/cl.d/$mod"
            echo -e "  ${GREEN}✓${NC} $mod"
        else
            echo -e "  ${RED}✗${NC} $mod (下载失败)"
            rm -f "${install_dir}/cl.d/${mod}.new"
            failed=1
        fi
    done

    echo ""

    if [[ $failed -eq 0 ]]; then
        log_success "更新完成！"
        echo ""
        log_info "当前版本已是最新"

        # 清理旧备份（保留最近 3 个）
        local backup_count=$(ls -d "${install_dir}/.backup."* 2>/dev/null | wc -l)
        if [[ $backup_count -gt 3 ]]; then
            ls -dt "${install_dir}/.backup."* | tail -n +4 | xargs rm -rf
        fi
    else
        log_warn "部分模块更新失败，但核心功能应该可用"
        log_info "如遇问题，可从备份恢复: $backup_dir"
    fi
}
