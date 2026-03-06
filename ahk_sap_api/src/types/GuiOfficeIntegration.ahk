#Requires AutoHotkey v2.0

class GuiOfficeIntegration extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiOfficeIntegration", path = "" ? "GuiOfficeIntegration" : path, policy, strict)
    }
}
