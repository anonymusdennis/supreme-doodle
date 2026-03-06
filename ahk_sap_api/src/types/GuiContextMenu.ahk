#Requires AutoHotkey v2.0

class GuiContextMenu extends GuiMenu {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiContextMenu" : path)
    }
}
