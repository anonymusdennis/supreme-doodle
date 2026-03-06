#Requires AutoHotkey v2.0

class GuiSplit extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path == "" ? "GuiSplit" : path)
    }
}
