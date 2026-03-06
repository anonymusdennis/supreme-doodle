#Requires AutoHotkey v2.0

class GuiMessageWindow extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiMessageWindow", path == "" ? "GuiMessageWindow" : path, policy, strict)
    }
}
