#Requires AutoHotkey v2.0

class GuiShell extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? "GuiShell" : path)
    }

    AccDescription {
        get {
            return this.InvokeGet("AccDescription")
        }
    }

    CurrentContextMenu {
        get {
            return this.InvokeGet("CurrentContextMenu")
        }
    }

    DragDropSupported {
        get {
            return this.InvokeGet("DragDropSupported")
        }
    }

    Handle {
        get {
            return this.InvokeGet("Handle")
        }
    }

    OcxEvents {
        get {
            return this.InvokeGet("OcxEvents")
        }
    }

    SubType {
        get {
            return this.InvokeGet("SubType")
        }
    }

    SelectContextMenuItem(functionCode) {
        return this.InvokeCall("SelectContextMenuItem", functionCode)
    }

    SelectContextMenuItemByPosition(position) {
        return this.InvokeCall("SelectContextMenuItemByPosition", position)
    }

    SelectContextMenuItemByText(text) {
        return this.InvokeCall("SelectContextMenuItemByText", text)
    }
}
