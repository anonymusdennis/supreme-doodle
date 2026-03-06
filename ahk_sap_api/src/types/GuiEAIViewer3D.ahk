#Requires AutoHotkey v2.0

class GuiEAIViewer3D extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiEAIViewer3D" : path)
    }
}
