#Requires AutoHotkey v2.0

class GuiChart extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiChart", path = "" ? "GuiChart" : path, policy, strict)
    }
}
