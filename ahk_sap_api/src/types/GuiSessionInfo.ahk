#Requires AutoHotkey v2.0

class GuiSessionInfo extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "") {
        super.__New(comObj, "GuiSessionInfo", path == "" ? "GuiSessionInfo" : path, policy, strict)
    }

    ApplicationServer {
        get {
            return this.InvokeGet("ApplicationServer")
        }
    }

    Client {
        get {
            return this.InvokeGet("Client")
        }
    }

    Group {
        get {
            return this.InvokeGet("Group")
        }
    }

    Language {
        get {
            return this.InvokeGet("Language")
        }
    }

    Program {
        get {
            return this.InvokeGet("Program")
        }
    }

    ScreenNumber {
        get {
            return this.InvokeGet("ScreenNumber")
        }
    }

    SystemName {
        get {
            return this.InvokeGet("SystemName")
        }
    }

    SystemNumber {
        get {
            return this.InvokeGet("SystemNumber")
        }
    }

    Transaction {
        get {
            return this.InvokeGet("Transaction")
        }
    }

    User {
        get {
            return this.InvokeGet("User")
        }
    }
}
