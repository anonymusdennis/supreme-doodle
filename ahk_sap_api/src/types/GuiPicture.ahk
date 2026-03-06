#Requires AutoHotkey v2.0

class GuiPicture extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path == "" ? "GuiPicture" : path)
    }
}
