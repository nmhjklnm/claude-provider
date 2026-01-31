# cctool - Claude API Provider Switcher

Version: v0.1.6

快速切换 Claude API 供应商配置的命令行工具。
此工具最大的优势不是人来使用，而是为Coding Agent自己使用提供方便。你可以直接要求它"cctool -h 然后把这个 xxx新供应商给我配上"

## 安装

```bash
npm i -g @nmhjklnm/cctool
```

## 🎉 新功能：自动更新环境变量（无需重开终端）

安装 shell 集成后，切换供应商时会自动更新当前终端的环境变量：

```bash
# 一次性设置（推荐）
cctool setup

# 使配置生效
source ~/.zshrc  # 或重新打开终端

# 现在切换供应商会自动更新环境变量！
cctool yunwu     # 环境变量立即生效，无需重开终端
```

支持的 Shell：
- ✅ zsh
- ✅ bash

## 使用

```bash
cctool                      # 查看当前供应商
cctool list                 # 列出所有供应商
cctool <name>               # 切换到指定供应商
cctool add <name> <url> <key>  # 添加供应商
cctool rm <name>            # 删除供应商
cctool rename <old> <new>   # 重命名供应商
cctool setup                # 安装 shell 集成（自动更新环境变量）
cctool init                 # 测试所有连接
cctool update               # 查看更新命令
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

## 高级用法

### 手动获取环境变量（用于脚本）

```bash
# 输出当前默认供应商的环境变量
cctool --print-env

# 在脚本中使用
eval "$(cctool --print-env)"
```

## 原理

切换供应商时自动设置环境变量：

- `ANTHROPIC_BASE_URL` - API 基础 URL
- `ANTHROPIC_AUTH_TOKEN` - API 密钥

配置存储在 `~/.claude/providers.json`。

## 卸载

```bash
npm rm -g @nmhjklnm/cctool

# 如果安装了 shell 集成，需要手动从 ~/.zshrc 或 ~/.bashrc 中删除 cctool 函数
```

## License

MIT
