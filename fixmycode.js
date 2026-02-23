// fix-includes.js
// Usage: node fix-includes.js
// Replaces: "../ahk2_sap_wrapper/src/SapWrapper.ahk" -> "ahk_sap_api/src/SapWrapper.ahk"
// in all .ahk / .ahk2 files under the current directory (recursive).

'use strict';

const fs = require('fs');
const path = require('path');

const START_DIR = process.cwd();

const FROM = '../ahk2_sap_wrapper/src/SapWrapper.ahk';
const TO   = 'ahk_sap_api/src/SapWrapper.ahk';

const EXTENSIONS = new Set(['.ahk', '.ahk2']);

// Skip common noise folders; add more if you want.
const SKIP_DIRS = new Set([
  '.git',
  '.svn',
  'node_modules',
  'dist',
  'build',
  'out',
  '.idea',
  '.vscode'
]);

function isBinaryLikely(buf) {
  // crude: if there are many NUL bytes, treat as binary
  let nul = 0;
  for (let i = 0; i < Math.min(buf.length, 8000); i++) {
    if (buf[i] === 0) nul++;
  }
  return nul > 0;
}

function walk(dir, out = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const ent of entries) {
    const full = path.join(dir, ent.name);

    if (ent.isDirectory()) {
      if (SKIP_DIRS.has(ent.name)) continue;
      walk(full, out);
      continue;
    }

    if (!ent.isFile()) continue;

    const ext = path.extname(ent.name).toLowerCase();
    if (EXTENSIONS.has(ext)) out.push(full);
  }
  return out;
}

function replaceInFile(filePath) {
  const raw = fs.readFileSync(filePath);
  if (isBinaryLikely(raw)) return { changed: false, reason: 'binary-ish' };

  const text = raw.toString('utf8');

  if (!text.includes(FROM)) return { changed: false };

  const replaced = text.split(FROM).join(TO);

  if (replaced === text) return { changed: false };

  // Backup
  const backupPath = filePath + '.bak';
  if (!fs.existsSync(backupPath)) {
    fs.writeFileSync(backupPath, text, 'utf8');
  }

  fs.writeFileSync(filePath, replaced, 'utf8');

  const count = (text.match(new RegExp(escapeRegExp(FROM), 'g')) || []).length;

  return { changed: true, count, backupPath };
}

function escapeRegExp(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function main() {
  const files = walk(START_DIR);

  let changedFiles = 0;
  let totalReplacements = 0;

  for (const f of files) {
    const res = replaceInFile(f);
    if (res.changed) {
      changedFiles++;
      totalReplacements += res.count;
      console.log(`✓ ${path.relative(START_DIR, f)}  (${res.count} replacement(s))`);
      console.log(`  backup: ${path.relative(START_DIR, res.backupPath)}`);
    }
  }

  if (changedFiles === 0) {
    console.log('No changes made (string not found in any .ahk/.ahk2 files).');
  } else {
    console.log(`\nDone. Changed ${changedFiles} file(s), ${totalReplacements} replacement(s) total.`);
  }
}

main();