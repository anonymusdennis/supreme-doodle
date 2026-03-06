#Requires AutoHotkey v2.0

class GuiGridView extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiGridView" : path)
    }
}
