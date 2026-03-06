#Requires AutoHotkey v2.0

class GuiCTextField extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiCTextField", path = "" ? "GuiCTextField" : path, policy, strict)
    }
}
