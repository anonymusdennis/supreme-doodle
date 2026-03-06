#Requires AutoHotkey v2.0

class GuiTab extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path == "" ? "GuiTab" : path)
    }
}
