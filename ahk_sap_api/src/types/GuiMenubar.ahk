#Requires AutoHotkey v2.0

class GuiMenubar extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiMenubar" : path)
    }
}
