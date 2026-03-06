#Requires AutoHotkey v2.0

class GuiEnum extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiEnum" : path)
    }
}
