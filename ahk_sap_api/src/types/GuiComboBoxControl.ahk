#Requires AutoHotkey v2.0

class GuiComboBoxControl extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiComboBoxControl", path = "" ? "GuiComboBoxControl" : path, policy, strict)
    }
}
