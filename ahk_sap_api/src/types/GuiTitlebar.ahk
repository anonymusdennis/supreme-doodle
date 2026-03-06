#Requires AutoHotkey v2.0

class GuiTitlebar extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiTitlebar", path = "" ? "GuiTitlebar" : path, policy, strict)
    }
}
