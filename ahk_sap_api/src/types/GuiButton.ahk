#Requires AutoHotkey v2.0

class GuiButton extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path == "" ? "GuiButton" : path)
    }

    Emphasized {
        get {
            return this.InvokeGet("Emphasized")
        }
    }

    LeftLabel {
        get {
            return this.InvokeGet("LeftLabel")
        }
    }

    RightLabel {
        get {
            return this.InvokeGet("RightLabel")
        }
    }
}
