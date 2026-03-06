#Requires AutoHotkey v2.0

class GuiCustomControl extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiCustomControl" : path)
    }
}
