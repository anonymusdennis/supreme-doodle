#Requires AutoHotkey v2.0

class GuiScrollbar extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiScrollbar", path = "" ? "GuiScrollbar" : path, policy, strict)
    }
}
