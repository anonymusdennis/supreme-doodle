#Requires AutoHotkey v2.0

class GuiEAIViewer2D extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiEAIViewer2D" : path)
    }
}
