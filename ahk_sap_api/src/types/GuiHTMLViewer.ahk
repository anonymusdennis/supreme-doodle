#Requires AutoHotkey v2.0

class GuiHTMLViewer extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiHTMLViewer" : path)
    }
}
