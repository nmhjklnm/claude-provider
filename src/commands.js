const { maskKey, readConfig, writeConfig } = require("./store");
const { logError, logInfo, logSuccess, logWarn, colorize } = require("./output");
const { getConfigFilePath } = require("./config");

function requireConfig() {
  try {
    return readConfig();
  } catch (e) {
    if (e && e.code === "CONFIG_NOT_FOUND") {
      logError(e.message);
      process.stdout.write("请先添加供应商: cctool add <name> <url> <key>\n");
      process.exit(1);
    }
    throw e;
  }
}

function getDefaultProviderName(cfg) {
  return cfg.default || "";
}

function providerExists(cfg, name) {
  return Boolean(cfg.providers && Object.prototype.hasOwnProperty.call(cfg.providers, name));
}

function getProviderField(cfg, name, field) {
  const p = cfg.providers?.[name];
  return p?.[field] ?? "";
}

function showCurrent() {
  const cfg = requireConfig();
  const def = getDefaultProviderName(cfg);
  if (!def) {
    logWarn("未设置默认供应商");
    return;
  }
  const url = getProviderField(cfg, def, "url");
  const key = getProviderField(cfg, def, "key");
  logSuccess(`当前供应商: ${def}`);
  process.stdout.write(`  URL: ${url}\n`);
  process.stdout.write(`  Key: ${colorize("dim", maskKey(key))}\n`);
}

function listProviders() {
  const cfg = requireConfig();
  const def = getDefaultProviderName(cfg);
  const names = Object.keys(cfg.providers || {}).sort();

  process.stdout.write(`${colorize("blue", `${"".padEnd(2)} ${"NAME".padEnd(12)} ${"URL".padEnd(35)} KEY`)}\n`);
  process.stdout.write(`${colorize("dim", "───────────────────────────────────────────────────────────────────────────")}\n`);

  for (const name of names) {
    const url = getProviderField(cfg, name, "url");
    const key = getProviderField(cfg, name, "key");
    const masked = maskKey(key);

    if (name === def) {
      const star = "*".padEnd(2);
      const line = `${star} ${name.padEnd(12)} ${url.padEnd(35)} ${colorize("dim", masked)}`;
      process.stdout.write(`${colorize("green", line)}\n`);
    } else {
      const line = `${"".padEnd(2)} ${name.padEnd(12)} ${url.padEnd(35)} ${colorize("dim", masked)}`;
      process.stdout.write(`${line}\n`);
    }
  }
}

function addProvider(name, url, key) {
  if (!name || !url || !key) {
    logError("参数不完整");
    process.stdout.write("用法: cctool add <name> <url> <key>\n\n");
    process.stdout.write("示例:\n  cctool add qwen https://api.qwen.ai sk-xxxxxxxxxxxxx\n");
    process.exit(1);
  }

  // 尝试读取配置，如果不存在则创建初始配置
  let cfg;
  try {
    cfg = readConfig();
  } catch (e) {
    if (e && e.code === "CONFIG_NOT_FOUND") {
      // 配置文件不存在，创建初始配置
      cfg = { default: "", providers: {} };
      logInfo("创建新的配置文件...");
    } else {
      throw e;
    }
  }

  if (providerExists(cfg, name)) {
    logError(`供应商 '${name}' 已存在`);
    process.stdout.write(`如需更新，请先删除: cctool rm ${name}\n`);
    process.exit(1);
  }

  cfg.providers[name] = { url, key };
  if (!cfg.default) cfg.default = name;
  writeConfig(cfg);

  logSuccess(`已添加供应商: ${name}`);
  process.stdout.write("\n切换到该供应商:\n");
  process.stdout.write(`  cctool ${name}\n`);
}

function removeProvider(name) {
  if (!name) {
    logError("请指定供应商名称");
    process.stdout.write("用法: cctool rm <name>\n");
    process.exit(1);
  }

  const cfg = requireConfig();
  if (!providerExists(cfg, name)) {
    logError(`供应商 '${name}' 不存在`);
    process.exit(1);
  }

  const def = getDefaultProviderName(cfg);
  if (name === def) {
    logError("不能删除当前默认供应商");
    process.stdout.write("请先切换到其他供应商: cl <other-name>\n");
    process.exit(1);
  }

  delete cfg.providers[name];
  writeConfig(cfg);
  logSuccess(`已删除供应商: ${name}`);
}

function renameProvider(oldName, newName) {
  const cfg = requireConfig();

  if (!oldName) {
    logError("请指定要重命名的供应商名称");
    process.stdout.write("用法: cctool rename <旧名称> <新名称>\n");
    process.exit(1);
  }

  if (!newName) {
    logError("请指定新的供应商名称");
    process.stdout.write("用法: cctool rename <旧名称> <新名称>\n");
    process.exit(1);
  }

  if (!providerExists(cfg, oldName)) {
    logError(`供应商 '${oldName}' 不存在`);
    process.stdout.write("使用 'cctool list' 查看所有供应商\n");
    process.exit(1);
  }

  if (providerExists(cfg, newName)) {
    logError(`供应商 '${newName}' 已存在，无法重命名`);
    process.stdout.write("请选择其他名称或先删除现有供应商\n");
    process.exit(1);
  }

  const def = getDefaultProviderName(cfg);
  cfg.providers[newName] = cfg.providers[oldName];
  delete cfg.providers[oldName];
  if (def === oldName) cfg.default = newName;
  writeConfig(cfg);

  logSuccess(`供应商已重命名: ${oldName} → ${newName}`);
  if (def === oldName) {
    logInfo(`已更新默认供应商为: ${newName}`);
  }
}

function switchProvider(name) {
  const cfg = requireConfig();

  if (!providerExists(cfg, name)) {
    logError(`供应商 '${name}' 不存在`);
    process.stdout.write("使用 'cctool list' 查看可用供应商\n");
    process.exit(1);
  }

  cfg.default = name;
  writeConfig(cfg);

  const url = getProviderField(cfg, name, "url");
  logSuccess(`已切换到: ${name}`);
  process.stdout.write(`  URL: ${url}\n`);
}

async function testSingleProvider(name, url, key) {
  const controller = new AbortController();
  const t = setTimeout(() => controller.abort(), 10_000);

  try {
    const res = await fetch(`${url.replace(/\/+$/, "")}/v1/messages`, {
      method: "POST",
      signal: controller.signal,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": key,
        "anthropic-version": "2023-06-01"
      },
      body: JSON.stringify({
        model: "claude-haiku-4-5-20251001",
        max_tokens: 10,
        messages: [{ role: "user", content: "1+1=? A:2 B:3 只回答字母" }]
      })
    });

    if (res.ok) {
      return { name, ok: true };
    }

    let msg = "连接失败";
    try {
      const data = await res.json();
      msg = data?.error?.message ?? data?.message ?? msg;
    } catch {
      msg = await res.text().catch(() => msg);
    }

    return { name, ok: false, detail: `${res.status}: ${msg}` };
  } catch (e) {
    const msg = e?.name === "AbortError" ? "超时" : (e?.message ?? "连接失败");
    return { name, ok: false, detail: msg };
  } finally {
    clearTimeout(t);
  }
}

async function initTest() {
  const cfg = requireConfig();
  logInfo("测试所有供应商连接...");
  process.stdout.write("\n");

  const names = Object.keys(cfg.providers || {}).sort();
  const tasks = names.map((name) => {
    const url = getProviderField(cfg, name, "url");
    const key = getProviderField(cfg, name, "key");
    return testSingleProvider(name, url, key);
  });

  const results = await Promise.all(tasks);

  for (const r of results) {
    if (r.ok) {
      process.stdout.write(`${colorize("green", "✓") } ${r.name}\n`);
    } else {
      process.stdout.write(`${colorize("red", "✗") } ${r.name} (${r.detail})\n`);
    }
  }

  process.stdout.write("\n");
  process.stdout.write(`${colorize("dim", "使用 claude-haiku-4-5-20251001 模型测试")}\n`);
}

function updateCmd() {
  logInfo("npm 包版本请使用 npm 进行更新:");
  process.stdout.write("  npm i -g @nmhjklnm/cctool@latest\n");
}

function printEnv() {
  const cfg = requireConfig();
  const def = getDefaultProviderName(cfg);
  if (!def) {
    process.exit(1);
  }
  const url = getProviderField(cfg, def, "url");
  const key = getProviderField(cfg, def, "key");
  process.stdout.write(`export ANTHROPIC_BASE_URL=${JSON.stringify(url)}\n`);
  process.stdout.write(`export ANTHROPIC_AUTH_TOKEN=${JSON.stringify(key)}\n`);
}

function setupShell() {
  const os = require("os");
  const path = require("path");
  const fs = require("fs");

  const shell = process.env.SHELL || "";
  const home = os.homedir();

  let rcFile = "";
  let funcName = "cctool";

  if (shell.includes("zsh")) {
    rcFile = path.join(home, ".zshrc");
  } else if (shell.includes("bash")) {
    rcFile = path.join(home, ".bashrc");
  } else {
    logError("不支持的 shell，目前仅支持 bash 和 zsh");
    process.exit(1);
  }

  const shellFunction = `
# cctool - 自动更新环境变量
${funcName}() {
  if [ "$1" = "setup" ]; then
    command cctool setup
    return
  fi
  
  local output
  output=$(command cctool "$@" 2>&1)
  local exit_code=$?
  
  echo "$output"
  
  if [ $exit_code -eq 0 ] && [ -n "$1" ] && [ "$1" != "list" ] && [ "$1" != "ls" ] && [ "$1" != "help" ] && [ "$1" != "add" ] && [ "$1" != "rm" ] && [ "$1" != "rename" ] && [ "$1" != "mv" ] && [ "$1" != "init" ] && [ "$1" != "test" ] && [ "$1" != "update" ] && [ "$1" != "upgrade" ] && [ "$1" != "--version" ] && [ "$1" != "-v" ] && [ "$1" != "--help" ] && [ "$1" != "-h" ]; then
    eval "$(command cctool --print-env 2>/dev/null)"
  fi
  
  return $exit_code
}
`;

  try {
    let content = "";
    if (fs.existsSync(rcFile)) {
      content = fs.readFileSync(rcFile, "utf8");
    }

    // 检查是否已经存在该函数
    if (content.includes(`${funcName}()`)) {
      logWarn(`${funcName} 函数已存在于 ${rcFile}`);
      process.stdout.write("\n如需重新安装，请手动删除旧的函数定义后再运行\n");
      return;
    }

    // 添加函数到文件末尾
    const newContent = content.trim() + "\n" + shellFunction;
    fs.writeFileSync(rcFile, newContent, "utf8");

    logSuccess(`已添加 ${funcName} 函数到 ${rcFile}`);
    process.stdout.write("\n请运行以下命令使配置生效:\n");
    process.stdout.write(`  ${colorize("cyan", `source ${rcFile}`)}\n\n`);
    process.stdout.write("或者重新打开终端\n\n");
    process.stdout.write(`现在切换供应商时，环境变量会自动更新！\n`);
  } catch (e) {
    logError(`设置失败: ${e.message}`);
    process.exit(1);
  }
}

function help() {
  process.stdout.write(
    [
      "cctool - Claude API 供应商切换工具",
      "",
      "用法:",
      "  cctool                      显示当前供应商",
      "  cctool <name>               切换到指定供应商",
      "  cctool list, ls             列出所有供应商",
      "  cctool add <name> <url> <key>  添加供应商",
      "  cctool rm <name>            删除供应商",
      "  cctool rename <old> <new>   重命名供应商",
      "  cctool setup                安装 shell 集成（自动更新环境变量）",
      "  cctool update               更新到最新版本",
      "  cctool init                 测试所有连接",
      "  cctool --version, -v        显示版本",
      "  cctool help                 显示帮助",
      "",
      "配置: ~/.claude/providers.json"
    ].join("\n") + "\n"
  );
}

module.exports = {
  addProvider,
  getConfigFilePath,
  help,
  initTest,
  listProviders,
  printEnv,
  removeProvider,
  renameProvider,
  setupShell,
  showCurrent,
  switchProvider,
  updateCmd
};
