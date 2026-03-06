#Requires AutoHotkey v2.0

class GuiGraphAdapt extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiGraphAdapt", path = "" ? "GuiGraphAdapt" : path, policy, strict)
    }
}
