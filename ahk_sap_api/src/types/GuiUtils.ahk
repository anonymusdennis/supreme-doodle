#Requires AutoHotkey v2.0

class GuiUtils extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiUtils", path == "" ? "GuiUtils" : path, policy, strict)
    }
}
