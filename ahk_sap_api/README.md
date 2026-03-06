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
python /home/runner/work/supreme-doodle/supreme-doodle/ahk_sap_api/tools/sap_api_codegen.py --generate-snippets
```

This writes:

- `/home/runner/work/supreme-doodle/supreme-doodle/ahk_sap_api/vscode/sap-gui-scripting.code-snippets`

Lint typed wrappers (`src/types/*.ahk`) against the SAP API docs:

```bash
python /home/runner/work/supreme-doodle/supreme-doodle/ahk_sap_api/tools/sap_api_codegen.py --lint-wrappers
```
