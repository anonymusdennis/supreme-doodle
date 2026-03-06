#Requires AutoHotkey v2.0

class GuiContainer extends GuiComponent {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path == "" ? this.__Class : path)
    }

    Children {
        get {
            return this.InvokeGet("Children")
        }
    }

    FindById(id, raise := unset) {
        if IsSet(raise) {
            return this.InvokeCall("FindById", id, raise)
        }
        return this.InvokeCall("FindById", id)
    }
}
