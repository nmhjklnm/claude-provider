#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const {
  addProvider,
  help,
  initTest,
  listProviders,
  printEnv,
  removeProvider,
  renameProvider,
  showCurrent,
  switchProvider,
  updateCmd
} = require("../src/commands");

function readVersion() {
  const versionFile = path.join(__dirname, "..", "VERSION");
  try {
    return fs.readFileSync(versionFile, "utf8").trim() || "unknown";
  } catch {
    return "unknown";
  }
}

async function main(argv) {
  const args = argv.slice(2);
  const cmd = args[0] ?? "";

  switch (cmd) {
    case "": {
      process.stdout.write(`cctool 版本: ${readVersion()}\n`);
      showCurrent();
      return;
    }

    case "help":
    case "-h":
    case "--help": {
      help();
      return;
    }

    case "version":
    case "--version":
    case "--ver":
    case "-v": {
      process.stdout.write(readVersion() + "\n");
      return;
    }

    case "list":
    case "ls": {
      listProviders();
      return;
    }

    case "add": {
      addProvider(args[1], args[2], args[3]);
      return;
    }

    case "rm": {
      removeProvider(args[1]);
      return;
    }

    case "rename":
    case "mv": {
      renameProvider(args[1], args[2]);
      return;
    }

    case "update":
    case "upgrade": {
      updateCmd();
      return;
    }

    case "init":
    case "test": {
      await initTest();
      return;
    }

    case "--print-env": {
      printEnv();
      return;
    }

    default: {
      // Compatibility + cross-platform env update:
      // - Interactive: keep human-friendly output.
      // - Non-interactive (e.g. eval): print exports only.
      const isTTY = Boolean(process.stdout.isTTY);
      if (isTTY) {
        switchProvider(cmd);
        return;
      }
      switchProvider(cmd);
      printEnv();
      return;
    }
  }
}

main(process.argv).catch((err) => {
  process.stderr.write(String(err?.stack || err?.message || err) + "\n");
  process.exit(1);
});
