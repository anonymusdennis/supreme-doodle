#Requires AutoHotkey v2.0

class GuiSession extends GuiContainer {
    __New(comObj, policy := "", strict := false, path := "/app/con[0]/ses[0]") {
        super.__New(comObj, policy, strict, path)
    }

    ActiveWindow {
        get {
            return this.InvokeGet("ActiveWindow")
        }
    }

    Info {
        get {
            return this.InvokeGet("Info")
        }
    }

    Busy {
        get {
            return this.InvokeGet("Busy")
        }
    }

    ErrorList {
        get {
            return this.InvokeGet("ErrorList")
        }
    }

    IsActive {
        get {
            return this.InvokeGet("IsActive")
        }
    }

    ProgressPercent {
        get {
            return this.InvokeGet("ProgressPercent")
        }
    }

    ProgressText {
        get {
            return this.InvokeGet("ProgressText")
        }
    }

    Record {
        get {
            return this.InvokeGet("Record")
        }
        set {
            return this.InvokeSet("Record", value)
        }
    }

    RecordFile {
        get {
            return this.InvokeGet("RecordFile")
        }
        set {
            return this.InvokeSet("RecordFile", value)
        }
    }

    SuppressBackendPopups {
        get {
            return this.InvokeGet("SuppressBackendPopups")
        }
        set {
            return this.InvokeSet("SuppressBackendPopups", value)
        }
    }

    TestToolMode {
        get {
            return this.InvokeGet("TestToolMode")
        }
        set {
            return this.InvokeSet("TestToolMode", value)
        }
    }

    FindById(id, raise := unset) {
        if IsSet(raise) {
            return this.InvokeCall("FindById", id, raise)
        }
        return this.InvokeCall("FindById", id)
    }

    AsStdNumberFormat(value) {
        return this.InvokeCall("AsStdNumberFormat", value)
    }

    ClearErrorList() {
        return this.InvokeCall("ClearErrorList")
    }

    CreateSession() {
        return this.InvokeCall("CreateSession")
    }

    EnableJawsEvents(enable := unset) {
        if IsSet(enable) {
            return this.InvokeCall("EnableJawsEvents", enable)
        }
        return this.InvokeCall("EnableJawsEvents")
    }

    EndTransaction() {
        return this.InvokeCall("EndTransaction")
    }

    FindByPosition(left, top, width := unset, height := unset) {
        if IsSet(height) {
            return this.InvokeCall("FindByPosition", left, top, width, height)
        }
        if IsSet(width) {
            return this.InvokeCall("FindByPosition", left, top, width)
        }
        return this.InvokeCall("FindByPosition", left, top)
    }

    GetIconResourceName(iconName) {
        return this.InvokeCall("GetIconResourceName", iconName)
    }

    GetVKeyDescription(vkey) {
        return this.InvokeCall("GetVKeyDescription", vkey)
    }

    LockSessionUI() {
        return this.InvokeCall("LockSessionUI")
    }

    SendCommand(command) {
        return this.InvokeCall("SendCommand", command)
    }

    StartTransaction(tcode) {
        return this.InvokeCall("StartTransaction", tcode)
    }

    UnlockSessionUI() {
        return this.InvokeCall("UnlockSessionUI")
    }
}
