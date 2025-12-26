# cl - Claude API Provider Switcher

快速切换 Claude API 供应商配置的命令行工具。

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/nmhjklnm/cl-tool/main/install.sh | bash
```

安装后执行：
```bash
source ~/.zshrc  # 或 ~/.bashrc
```

## 使用

```bash
cl                      # 查看当前供应商
cl list                 # 列出所有供应商
cl <name>               # 切换到指定供应商
cl add <name> <url> <key>  # 添加供应商
cl rm <name>            # 删除供应商
cl init                 # 测试所有连接
```

## 示例

```bash
# 添加供应商
cl add yunwu https://yunwu.ai/v1 sk-xxx
cl add official https://api.anthropic.com sk-ant-xxx

# 切换
cl yunwu      # 切换到 yunwu
cl official   # 切换到官方

# 查看
cl            # 显示当前: yunwu
cl ls         # 列出所有供应商
```

## 原理

切换供应商时自动设置环境变量：
- `ANTHROPIC_BASE_URL` - API 基础 URL
- `ANTHROPIC_API_KEY` - API 密钥

配置存储在 `~/.claude/providers.json`。

## 卸载

```bash
rm -rf ~/.claude/bin/_cl ~/.claude/bin/cl.d
# 然后从 ~/.zshrc 中删除 cl 相关配置
```

## License

MIT
