#Requires AutoHotkey v2.0

class GuiComponent extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        defaultPath := path = "" ? this.__Class : path
        super.__New(comObj, this.__Class, defaultPath, policy, strict)
    }

    ContainerType {
        get {
            return this.InvokeGet("ContainerType")
        }
    }

    Id {
        get {
            return this.InvokeGet("Id")
        }
    }

    Name {
        get {
            return this.InvokeGet("Name")
        }
    }

    Parent {
        get {
            return this.InvokeGet("Parent")
        }
    }

    Type {
        get {
            return this.InvokeGet("Type")
        }
    }

    TypeAsNumber {
        get {
            return this.InvokeGet("TypeAsNumber")
        }
    }
}
