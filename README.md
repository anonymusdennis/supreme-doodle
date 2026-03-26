# Data Validator for SAP Table Comparison

## Purpose

This tool validates and compares table data between two SAP systems by running scripted checks in `/TFTO/SE16XXL`.

In practical terms:
- System A is your current logged-in SAP session.
- System B is reached through an RFC destination.
- The tool opens SE16XXL, builds or reuses a comparison script, pastes it into the formula editor, validates it, and runs the comparison flow.

The comparison only works if a valid RFC destination from System A to System B exists.

## How the tool works

1. `main.ahk2` starts and loads:
   - `databases.cfg` (table list)
   - `rfc_destinations.cfg` (destination list)
   - `script_template.txt` (ABAP-like comparison template)
2. It discovers open SAP GUI sessions and asks you which sessions to use.
3. It creates tasks as all combinations of:
   - each table in `databases.cfg`
   - each RFC destination in `rfc_destinations.cfg`
4. It starts one or more worker processes (`sap_worker.ahk2`).
5. Each worker:
   - opens `/nSE16N` and reads fields from `DD03L` when no cached script exists
   - opens `/n/TFTO/SE16XXL`
   - enters table and RFC destination
   - opens the formula/script editor
   - pastes generated script content
   - validates script syntax and removes invalid fields if needed
   - optionally saves the script and optionally starts a batch job (based on `worker_config.ini`)
6. Results are written to logs and runtime files.

## Preconditions

- Windows environment (the included runtime and build scripts are Windows-focused)
- SAP GUI with scripting enabled
- At least one open SAP GUI session
- RFC destination from source system to target system
- AutoHotkey v2 runtime (repository includes `AutoHotkey64.exe`)

## User setup

### 1) Define tables

Edit `databases.cfg`:
- one table name per line
- empty lines are ignored

### 2) Define RFC destinations

Edit `rfc_destinations.cfg`:
- one RFC destination per line
- empty lines are ignored

Important: destination values must exist in SAP, otherwise tasks are marked as failed for that destination.

### 3) Optional worker behavior

Edit `worker_config.ini` to control:
- script auto-save
- naming patterns for scripts/jobs
- max validation attempts
- initial and later row limits
- batch job creation/spool/mail options
- SAP window resize behavior

## How to run

Use one of these approaches:

- Double-click `main.ahk2` on a machine with AutoHotkey v2
- or run with bundled runtime:
  - `AutoHotkey64.exe main.ahk2`

At startup:
- choose SAP sessions in the dialog
- monitor progress in the tool window
- stop with `Ctrl+Esc` if needed

## Output and troubleshooting

Main runtime outputs:
- `logs/SAPAutomation_YYYY-MM-DD.log`: general log
- `logs/success_tables.log`: successful table-destination pairs
- `logs/failed_tables.log`: failed table-destination pairs and error details
- `./removed_fields.log`: fields dropped during script validation (root directory)
- `specials.txt`: special cases (for example no entries)
- `script_cache/`: cached validated scripts per table
- `sessions.json`: live task and worker state

Common failure causes:
- RFC destination not found in SAP
- table not present in destination system
- no data returned for table
- script validation failures due to field incompatibilities

## Non-code files and what they do

This section covers non-code files used directly by the active tool flow, plus non-code support/archive files present in the repository.

### Root non-code files used by the tool

| File | Purpose |
|---|---|
| `databases.cfg` | Input list of table names to validate/compare. |
| `rfc_destinations.cfg` | Input list of RFC destinations (target systems). |
| `script_template.txt` | Base script template used to build SE16XXL comparison script. |
| `worker_config.ini` | Worker runtime settings (save behavior, batch job settings, row counts, window size, naming patterns). |
| `illegals.cfg` | Field names excluded from generated comparisons (for example client fields). |
| `sessions.json` | Runtime state file: workers, task queue, statuses, timestamps. |
| `specials.txt` | Runtime special-case log written by workers. |
| `.nodisclaimer_v0.69_initial` | Marker that suppresses disclaimer popup for version `0.69_initial`. |
| `.currenttag` | Build/release counter used by release scripts. |
| `.gitignore` | Git ignore rules (logs, generated builds, tokens, dumps, etc.). |

### Root non-code files for build/release/distribution

| File | Purpose |
|---|---|
| `compile.bat` | Windows build/packaging script for compiled distribution, zip creation, and related git operations. |
| `create_release.bat` | Windows release helper to tag, push, and optionally create/upload a release in Gitea. |
| `AutoHotkey64.exe` | Bundled AutoHotkey runtime used to launch `.ahk2` scripts or compiled packaging flow. |
| `main.ico` | Icon asset for main executable/build output. |
| `worker.ico` | Icon asset for worker executable/build output. |
| `package.json` | Minimal Node metadata and dependencies for repository utility scripts. |
| `package-lock.json` | Locked Node dependency versions. |

### Non-code files in subdirectories

| Path | Purpose |
|---|---|
| `_bundle/manifest.json` | Manifest for bundled/exported script artifacts. |
| `_bundle/*.txt` | Generated bundle text snapshots of scripts; not required for normal runtime execution. |
| `ahk_sap_api/README.md` | Documentation for the SAP wrapper submodule used by the main scripts. |
| `ahk_sap_api/sap_gui_scripting_api_760_condensed_index.md` | SAP scripting API reference index used for wrapper maintenance. |
| `ahk_sap_api/sap_gui_scripting_api_761(2).txt` | SAP scripting API text reference copy. |
| `ahk_sap_api/sap_gui_scripting_api_761-1.pdf` | SAP scripting API PDF reference. |
| `ahk_sap_api/task.md` | Internal notes/task file for wrapper work. |
| `old/*` | Historical binaries, configs, dumps, and backups from previous versions; archive only. |
| `node_modules/*` | Third-party dependency files from npm install; external vendor content. |

## Notes for users

- Start with a small table subset and one destination to validate setup.
- Ensure SAP authorizations allow SE16N, SE16XXL, RFC access, and script save/job actions when enabled.
- If you only need comparison and not job execution, disable batch job creation in `worker_config.ini`.
