#!/usr/bin/env node
import fg from "fast-glob";
import fs from "node:fs";
import path from "node:path";
import { diff_match_patch } from "diff-match-patch";

const ROOT = process.cwd();
const BUNDLE_DIR = path.join(ROOT, "_bundle");
const MANIFEST = path.join(BUNDLE_DIR, "manifest.json");
const argv = new Set(process.argv.slice(2));
const DRY = argv.has("--dry-run");

function stripHeader(bundleText) {
  const lines = bundleText.split(/\r?\n/);
  let i = 0;
  while (i < lines.length && lines[i].startsWith(";;")) i++;
  // optional separator line
  if (i < lines.length && lines[i].startsWith(";;")) i++;
  return lines.slice(i).join("\n");
}

if (!fs.existsSync(MANIFEST)) {
  throw new Error("Missing _bundle/manifest.json. Run export first.");
}

const manifest = JSON.parse(fs.readFileSync(MANIFEST, "utf8"));
const dmp = new diff_match_patch();
const ts = new Date().toISOString().replace(/[:.]/g, "-");

let changed = 0;

for (const entry of manifest.files) {
  const bundlePath = path.join(BUNDLE_DIR, entry.bundleFile);
  if (!fs.existsSync(bundlePath)) continue;

  const editedBundle = fs.readFileSync(bundlePath, "utf8");
  const editedText = stripHeader(editedBundle);

  const targetPath = path.join(ROOT, entry.rel);
  if (!fs.existsSync(targetPath)) {
    console.log(`[SKIP] Missing target: ${entry.rel}`);
    continue;
  }

  const originalText = fs.readFileSync(targetPath, "utf8");

  if (editedText === originalText) continue;

  // create patch from original->edited
  const patches = dmp.patch_make(originalText, editedText);
  const [appliedText, results] = dmp.patch_apply(patches, originalText);

  const ok = results.every(Boolean);
  if (!ok) {
    console.log(`[FAIL] Patch did not apply cleanly: ${entry.rel}`);
    continue;
  }

  console.log(`${DRY ? "[DRY]" : "[OK] "} ${entry.rel}`);
  changed++;

  if (!DRY) {
    fs.writeFileSync(targetPath + `.bak.${ts}`, originalText, "utf8");
    fs.writeFileSync(targetPath, appliedText, "utf8");
  }
}

console.log(`Done. Changed files: ${changed}${DRY ? " (dry-run)" : ""}`);