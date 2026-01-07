const os = require("os");
const path = require("path");

function getConfigFilePath() {
  return path.join(os.homedir(), ".claude", "providers.json");
}

module.exports = {
  getConfigFilePath
};
