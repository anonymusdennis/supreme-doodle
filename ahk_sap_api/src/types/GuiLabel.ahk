#Requires AutoHotkey v2.0

class GuiLabel extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiLabel" : path)
    }
}
