const fs = require("fs");
const path = require("path");
const { getConfigFilePath } = require("./config");

function ensureDir(filePath) {
  const dir = path.dirname(filePath);
  fs.mkdirSync(dir, { recursive: true });
}

function readConfig(configFile = getConfigFilePath()) {
  if (!fs.existsSync(configFile)) {
    const err = new Error(`配置文件不存在: ${configFile}`);
    err.code = "CONFIG_NOT_FOUND";
    throw err;
  }
  const raw = fs.readFileSync(configFile, "utf8");
  const parsed = JSON.parse(raw);
  if (!parsed || typeof parsed !== "object") return { default: "", providers: {} };
  if (!parsed.providers || typeof parsed.providers !== "object") parsed.providers = {};
  if (typeof parsed.default !== "string") parsed.default = "";
  return parsed;
}

function writeConfig(data, configFile = getConfigFilePath()) {
  ensureDir(configFile);
  const dir = path.dirname(configFile);
  const tmp = path.join(dir, `.providers.json.tmp.${process.pid}.${Date.now()}`);
  fs.writeFileSync(tmp, JSON.stringify(data, null, 2) + "\n", "utf8");
  fs.renameSync(tmp, configFile);
}

function maskKey(key) {
  if (typeof key !== "string") return "";
  if (key.length <= 12) return key;
  return `${key.slice(0, 6)}...${key.slice(-6)}`;
}

module.exports = {
  maskKey,
  readConfig,
  writeConfig
};
