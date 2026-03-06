#Requires AutoHotkey v2.0

class GuiStatusbar extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiStatusbar" : path)
    }

    Handle {
        get {
            return this.InvokeGet("Handle")
        }
    }

    MessageAsPopup {
        get {
            return this.InvokeGet("MessageAsPopup")
        }
    }

    MessageId {
        get {
            return this.InvokeGet("MessageId")
        }
    }

    MessageNumber {
        get {
            return this.InvokeGet("MessageNumber")
        }
    }

    MessageParameter {
        get {
            return this.InvokeGet("MessageParameter")
        }
    }

    MessageType {
        get {
            return this.InvokeGet("MessageType")
        }
    }

    DoubleClick() {
        return this.InvokeCall("DoubleClick")
    }
}
