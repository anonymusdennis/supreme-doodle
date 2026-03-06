#Requires AutoHotkey v2.0

class GuiStatusPane extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiStatusPane", path == "" ? "GuiStatusPane" : path, policy, strict)
    }
}
