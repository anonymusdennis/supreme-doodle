#Requires AutoHotkey v2.0

class GuiGOSShell extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiGOSShell" : path)
    }
}
