#Requires AutoHotkey v2.0

class GuiInputFieldControl extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiInputFieldControl", path = "" ? "GuiInputFieldControl" : path, policy, strict)
    }
}
