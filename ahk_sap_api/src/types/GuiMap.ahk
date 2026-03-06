#Requires AutoHotkey v2.0

class GuiMap extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiMap", path == "" ? "GuiMap" : path, policy, strict)
    }
}
