# AHK2 SAP GUI Scripting Wrapper

AutoHotkey v2 COM wrapper/proxy for SAP GUI Scripting with hookable call pipeline.

## Usage

```ahk
#Requires AutoHotkey v2.0
#Include src/SapWrapper.ahk

policy := SapHookPolicy()
SapGuiAuto := ComObjGet("SAPGUI")
app := GuiApplication(SapGuiAuto.GetScriptingEngine, policy)

ses := app.Children[0].Children[0]
ses.FindById("wnd[0]/tbar[0]/okcd").Text := "/nSE16"
ses.FindById("wnd[0]").SendVKey(0)
MsgBox(ses.Info.SystemName)
```

See `/examples/demo_rot_attach.ahk` for a runnable example.

## VSCode autocomplete + wrapper lint support

`sap_gui_scripting_api_760_condensed_index.md` is used as the source of truth for SAP members.

Generate snippets (all interfaces/members from SAP docs):

```bash
python ahk_sap_api/tools/sap_api_codegen.py --generate-snippets
```

This writes:

- `ahk_sap_api/vscode/sap-gui-scripting.code-snippets`

Lint typed wrappers (`src/types/*.ahk`) against the SAP API docs:

```bash
python ahk_sap_api/tools/sap_api_codegen.py --lint-wrappers
```

Lint wrapper coverage and detect direct raw COM touchpoints outside the central proxy:

```bash
python ahk_sap_api/tools/sap_api_codegen.py --lint-coverage
```

`--lint-coverage` now also checks:
- duplicate wrapper/declaration classes
- `SapWrapper.ahk` include-order inheritance risks
- `Raw()` usage and raw-return leakage inside wrapper files
- `.ahk` ↔ `.d.ahk` class drift
- expected documented members for key wrappers (session/application/frame/container/collections)
- presence of non-`Gui*` representations (`SapGuiBootstrap`, `GuiComponentType`)

## Non-`Gui*` API handling

The SAP docs include non-interface API items in addition to `Gui*` COM interfaces:
- `SapGuiAuto` (ROT bootstrap object)
- `Sapgui.ScriptingCtrl.1` (ProgID creation object)
- `GuiComponentType` (enum/constants)

This wrapper models those as:
- `src/core/SapGuiBootstrap.ahk` (attach/create helpers)
- `src/generated/GuiComponentType.ahk` (conservative enum placeholder; values are version-sensitive)
