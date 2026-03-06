#Requires AutoHotkey v2.0

class GuiNetChart extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiNetChart", path = "" ? "GuiNetChart" : path, policy, strict)
    }
}
