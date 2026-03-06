#Requires AutoHotkey v2.0

class GuiVComponent extends GuiComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? this.__Class : path)
    }

    Text {
        get {
            return this.InvokeGet("Text")
        }
        set {
            return this.InvokeSet("Text", value)
        }
    }
}
