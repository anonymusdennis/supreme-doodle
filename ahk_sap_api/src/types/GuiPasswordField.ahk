#Requires AutoHotkey v2.0

class GuiPasswordField extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiPasswordField", path = "" ? "GuiPasswordField" : path, policy, strict)
    }
}
