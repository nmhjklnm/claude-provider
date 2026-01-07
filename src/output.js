const COLORS = {
  green: "\u001b[0;32m",
  yellow: "\u001b[1;33m",
  blue: "\u001b[0;34m",
  red: "\u001b[0;31m",
  cyan: "\u001b[0;36m",
  dim: "\u001b[2m",
  nc: "\u001b[0m"
};

function supportsColor() {
  return Boolean(process.stdout.isTTY);
}

function colorize(color, text) {
  if (!supportsColor()) return text;
  return `${COLORS[color] ?? ""}${text}${COLORS.nc}`;
}

function logSuccess(msg) {
  process.stdout.write(`${colorize("green", `✓ ${msg}`)}\n`);
}

function logError(msg) {
  process.stderr.write(`${colorize("red", `✗ 错误: ${msg}`)}\n`);
}

function logInfo(msg) {
  process.stdout.write(`${colorize("blue", msg)}\n`);
}

function logWarn(msg) {
  process.stdout.write(`${colorize("yellow", `! ${msg}`)}\n`);
}

module.exports = {
  COLORS,
  colorize,
  logError,
  logInfo,
  logSuccess,
  logWarn,
  supportsColor
};
