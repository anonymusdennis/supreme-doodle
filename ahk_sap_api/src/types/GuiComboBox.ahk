#Requires AutoHotkey v2.0

class GuiComboBox extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiComboBox" : path)
    }

    Key {
        get {
            return this.InvokeGet("Key")
        }
        set {
            return this.InvokeSet("Key", value)
        }
    }

    Value {
        get {
            return this.InvokeGet("Value")
        }
        set {
            return this.InvokeSet("Value", value)
        }
    }

    CurListBoxEntry {
        get {
            return this.InvokeGet("CurListBoxEntry")
        }
    }

    ShowKey {
        get {
            return this.InvokeGet("ShowKey")
        }
        set {
            return this.InvokeSet("ShowKey", value)
        }
    }

    SetKeySpace(keySpace) {
        return this.InvokeCall("SetKeySpace", keySpace)
    }
}
