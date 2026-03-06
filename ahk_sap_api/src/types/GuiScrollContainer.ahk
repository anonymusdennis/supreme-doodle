#Requires AutoHotkey v2.0

class GuiScrollContainer extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiScrollContainer", path == "" ? "GuiScrollContainer" : path, policy, strict)
    }
}
