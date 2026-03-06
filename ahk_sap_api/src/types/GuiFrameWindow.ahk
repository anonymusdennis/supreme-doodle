#Requires AutoHotkey v2.0

class GuiFrameWindow extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, policy, strict, path = "" ? this.__Class : path)
    }

    Close() {
        return this.InvokeCall("Close")
    }

    CompBitmap(scale, x, y, width, height) {
        return this.InvokeCall("CompBitmap", scale, x, y, width, height)
    }

    HardCopy(fileName, overwrite := unset) {
        if IsSet(overwrite) {
            return this.InvokeCall("HardCopy", fileName, overwrite)
        }
        return this.InvokeCall("HardCopy", fileName)
    }

    HardCopyToMemory() {
        return this.InvokeCall("HardCopyToMemory")
    }

    Iconify() {
        return this.InvokeCall("Iconify")
    }

    IsVKeyAllowed(vkey) {
        return this.InvokeCall("IsVKeyAllowed", vkey)
    }

    JumpBackward() {
        return this.InvokeCall("JumpBackward")
    }

    JumpForward() {
        return this.InvokeCall("JumpForward")
    }

    Maximize() {
        return this.InvokeCall("Maximize")
    }

    Restore() {
        return this.InvokeCall("Restore")
    }

    SendVKey(vkey) {
        return this.InvokeCall("SendVKey", vkey)
    }

    ShowMessageBox(type, text, caption := unset, defaultButton := unset) {
        if IsSet(defaultButton) {
            return this.InvokeCall("ShowMessageBox", type, text, caption, defaultButton)
        }
        if IsSet(caption) {
            return this.InvokeCall("ShowMessageBox", type, text, caption)
        }
        return this.InvokeCall("ShowMessageBox", type, text)
    }

    TabBackward() {
        return this.InvokeCall("TabBackward")
    }

    TabForward() {
        return this.InvokeCall("TabForward")
    }
}
