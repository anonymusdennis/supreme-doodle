#Requires AutoHotkey v2.0

class GuiApplication extends GuiContainer {
    __New(comObj, policy := "", strict := false, path := "/app") {
        super.__New(comObj, policy, strict, path)
    }

    ActiveSession {
        get {
            return this.InvokeGet("ActiveSession")
        }
    }

    AllowSystemMessages {
        get {
            return this.InvokeGet("AllowSystemMessages")
        }
        set {
            return this.InvokeSet("AllowSystemMessages", value)
        }
    }

    Connections {
        get {
            return this.InvokeGet("Connections")
        }
    }

    ConnectionErrorText {
        get {
            return this.InvokeGet("ConnectionErrorText")
        }
    }

    HistoryEnabled {
        get {
            return this.InvokeGet("HistoryEnabled")
        }
        set {
            return this.InvokeSet("HistoryEnabled", value)
        }
    }

    MajorVersion {
        get {
            return this.InvokeGet("MajorVersion")
        }
    }

    MinorVersion {
        get {
            return this.InvokeGet("MinorVersion")
        }
    }

    NewVisualDesign {
        get {
            return this.InvokeGet("NewVisualDesign")
        }
    }

    ButtonbarVisible {
        get {
            return this.InvokeGet("ButtonbarVisible")
        }
        set {
            return this.InvokeSet("ButtonbarVisible", value)
        }
    }

    StatusbarVisible {
        get {
            return this.InvokeGet("StatusbarVisible")
        }
        set {
            return this.InvokeSet("StatusbarVisible", value)
        }
    }

    TitlebarVisible {
        get {
            return this.InvokeGet("TitlebarVisible")
        }
        set {
            return this.InvokeSet("TitlebarVisible", value)
        }
    }

    ToolbarVisible {
        get {
            return this.InvokeGet("ToolbarVisible")
        }
        set {
            return this.InvokeSet("ToolbarVisible", value)
        }
    }

    Patchlevel {
        get {
            return this.InvokeGet("Patchlevel")
        }
    }

    Revision {
        get {
            return this.InvokeGet("Revision")
        }
    }

    Utils {
        get {
            return this.InvokeGet("Utils")
        }
    }

    AddHistoryEntry(entry) {
        return this.InvokeCall("AddHistoryEntry", entry)
    }

    CreateGuiCollection() {
        return this.InvokeCall("CreateGuiCollection")
    }

    DropHistory() {
        return this.InvokeCall("DropHistory")
    }

    Ignore(type := unset, value := unset) {
        if IsSet(value) {
            return this.InvokeCall("Ignore", type, value)
        }
        if IsSet(type) {
            return this.InvokeCall("Ignore", type)
        }
        return this.InvokeCall("Ignore")
    }

    OpenConnection(description, sync := unset) {
        if IsSet(sync) {
            return this.InvokeCall("OpenConnection", description, sync)
        }
        return this.InvokeCall("OpenConnection", description)
    }

    OpenConnectionByConnectionString(connectionString, sync := unset) {
        if IsSet(sync) {
            return this.InvokeCall("OpenConnectionByConnectionString", connectionString, sync)
        }
        return this.InvokeCall("OpenConnectionByConnectionString", connectionString)
    }

    RegisterROT() {
        return this.InvokeCall("RegisterROT")
    }

    RevokeROT() {
        return this.InvokeCall("RevokeROT")
    }
}
