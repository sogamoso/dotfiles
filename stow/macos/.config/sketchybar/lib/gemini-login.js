// Run by lib/agents.sh — prints the Gemini CLI's Google sign-in from its
// encrypted credentials file, the store the CLI falls back to when the macOS
// keychain is unavailable. The file is iv:tag:ciphertext in hex, AES-256-GCM
// around a JSON map of service → account → secret, with the key derived from
// the hostname and username the way the CLI derives it. Only the
// gemini-cli-oauth main-account record is printed: the API key kept beside
// it never leaves the file. Silent when there is no file or no sign-in.
"use strict";
const crypto = require("node:crypto");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");

let data;
try {
  data = fs.readFileSync(path.join(os.homedir(), ".gemini", "gemini-credentials.json"), "utf8");
} catch {
  process.exit(0);
}
try {
  const [iv, tag, encrypted] = data.split(":");
  const key = crypto.scryptSync("gemini-cli-oauth", `${os.hostname()}-${os.userInfo().username}-gemini-cli`, 32);
  const decipher = crypto.createDecipheriv("aes-256-gcm", key, Buffer.from(iv, "hex"), { authTagLength: 16 });
  decipher.setAuthTag(Buffer.from(tag, "hex"));
  const store = JSON.parse(decipher.update(encrypted, "hex", "utf8") + decipher.final("utf8"));
  const login = store["gemini-cli-oauth"]?.["main-account"];
  if (login) process.stdout.write(login);
} catch {
  process.exit(1);
}
