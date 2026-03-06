#Requires AutoHotkey v2.0

class GuiVContainer extends GuiContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path == "" ? this.__Class : path)
    }

    FindAllByName(name, type := unset) {
        if IsSet(type) {
            return this.InvokeCall("FindAllByName", name, type)
        }
        return this.InvokeCall("FindAllByName", name)
    }

    FindAllByNameEx(name, type := unset) {
        if IsSet(type) {
            return this.InvokeCall("FindAllByNameEx", name, type)
        }
        return this.InvokeCall("FindAllByNameEx", name)
    }

    FindByName(name, type := unset) {
        if IsSet(type) {
            return this.InvokeCall("FindByName", name, type)
        }
        return this.InvokeCall("FindByName", name)
    }
}
