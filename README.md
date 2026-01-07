# cl - Claude API Provider Switcher

Version: v0.1.2

快速切换 Claude API 供应商配置的命令行工具。

## 安装

```bash
npm i -g cctool
```

## 使用

```bash
cctool                      # 查看当前供应商
cctool list                 # 列出所有供应商
cctool <name>               # 切换到指定供应商
cctool add <name> <url> <key>  # 添加供应商
cctool rm <name>            # 删除供应商
cctool init                 # 测试所有连接
```

在脚本/非交互场景更新环境变量：

```bash
# 切换并输出 export（可用于 eval）
cctool yunwu | bash

# 或只输出当前默认的 export
cctool --print-env | bash
```

## 示例

```bash
# 添加供应商
cctool add yunwu https://yunwu.ai/v1 sk-xxx
cctool add official https://api.anthropic.com sk-ant-xxx

# 切换
cctool yunwu      # 切换到 yunwu
cctool official   # 切换到官方

# 查看
cctool            # 显示当前: yunwu
cctool ls         # 列出所有供应商
```

## 原理

切换供应商时自动设置环境变量：

- `ANTHROPIC_BASE_URL` - API 基础 URL
- `ANTHROPIC_AUTH_TOKEN` - API 密钥

配置存储在 `~/.claude/providers.json`。

## 卸载

```bash
npm rm -g cctool
```

## License

MIT
