#Requires AutoHotkey v2.0

class GuiSapChart extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiSapChart", path == "" ? "GuiSapChart" : path, policy, strict)
    }
}
