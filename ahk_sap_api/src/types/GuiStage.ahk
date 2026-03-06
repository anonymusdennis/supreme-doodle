#Requires AutoHotkey v2.0

class GuiStage extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiStage", path == "" ? "GuiStage" : path, policy, strict)
    }
}
