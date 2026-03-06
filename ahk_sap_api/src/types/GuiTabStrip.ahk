#Requires AutoHotkey v2.0

class GuiTabStrip extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path == "" ? "GuiTabStrip" : path)
    }
}
