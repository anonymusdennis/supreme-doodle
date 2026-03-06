#Requires AutoHotkey v2.0

class GuiDialogShell extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path == "" ? "GuiDialogShell" : path)
    }
}
