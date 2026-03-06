#Requires AutoHotkey v2.0

class GuiComboBoxEntry extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiComboBoxEntry", path == "" ? "GuiComboBoxEntry" : path, policy, strict)
    }
}
