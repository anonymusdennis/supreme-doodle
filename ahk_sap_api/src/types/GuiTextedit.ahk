#Requires AutoHotkey v2.0

class GuiTextedit extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path == "" ? "GuiTextedit" : path)
    }
}
