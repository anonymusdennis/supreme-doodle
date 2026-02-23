#!/usr/bin/env node
import fg from "fast-glob";
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";

const ROOT = process.cwd();
const OUT_DIR = path.join(ROOT, "_bundle");

const EXCLUDES = [
  "**/.git/**",
  "**/node_modules/**",
  "ahk_sap_api/src/**",      // your mirrored wrapper code: DO NOT TOUCH
  "_bundle/**",
];

function sha1(s) {
  return crypto.createHash("sha1").update(s).digest("hex");
}

fs.mkdirSync(OUT_DIR, { recursive: true });

const files = await fg(["**/*.ahk", "**/*.ahk2"], { cwd: ROOT, ignore: EXCLUDES, dot: true });

const manifest = {
  createdAt: new Date().toISOString(),
  root: ROOT,
  files: [], // { id, rel, sha1, bundleFile }
};

let n = 0;
for (const rel of files) {
  const abs = path.join(ROOT, rel);
  const text = fs.readFileSync(abs, "utf8");
  const id = sha1(rel + "\n" + text).slice(0, 12);
  const contentSha = sha1(text);

  const safe = rel.replace(/[\\/:"*?<>|]+/g, "_");
  const bundleFile = `${String(++n).padStart(5, "0")}__${id}__${safe}.bundle.ahk.txt`;
  const outPath = path.join(OUT_DIR, bundleFile);

  const header =
`;; @bundle-id: ${id}
;; @source-rel: ${rel}
;; @source-sha1: ${contentSha}
;; @note: Edit content below. Keep header lines starting with ';;' intact.
;; -------------------------
`;

  fs.writeFileSync(outPath, header + text, "utf8");

  manifest.files.push({ id, rel, sha1: contentSha, bundleFile });
}

fs.writeFileSync(path.join(OUT_DIR, "manifest.json"), JSON.stringify(manifest, null, 2), "utf8");
console.log(`Exported ${manifest.files.length} file(s) into ${OUT_DIR}`);