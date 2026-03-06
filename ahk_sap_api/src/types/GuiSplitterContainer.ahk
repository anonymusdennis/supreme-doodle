#Requires AutoHotkey v2.0

class GuiSplitterContainer extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiSplitterContainer", path = "" ? "GuiSplitterContainer" : path, policy, strict)
    }
}
