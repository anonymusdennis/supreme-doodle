#Requires AutoHotkey v2.0

class SapGuiBootstrap {
    static AttachROT() {
        return ComObjGet("SAPGUI")
    }

    static GetScriptingEngineFromROT() {
        return this.AttachROT().GetScriptingEngine
    }

    static CreateScriptingControl() {
        return ComObject("Sapgui.ScriptingCtrl.1")
    }

    ; useRot=true attaches to a running SAP GUI via ROT (SapGuiAuto),
    ; useRot=false creates a scripting control via ProgID.
    ; policy/strict are forwarded to GuiApplication wrapper construction.
    static CreateWrappedApplication(policy := "", strict := false, useRot := true) {
        appCom := useRot ? this.GetScriptingEngineFromROT() : this.CreateScriptingControl()
        return GuiApplication(appCom, policy, strict, "/app")
    }
}
