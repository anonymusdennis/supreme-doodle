#Requires AutoHotkey v2.0

class GuiTableColumn extends GuiComponentCollection {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiTableColumn" : path)
    }
}
