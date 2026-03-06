#Requires AutoHotkey v2.0

class GuiConnection extends GuiContainer {
    __New(comObj, policy := "", strict := false, path := "/app/con[0]") {
        super.__New(comObj, policy, strict, path)
    }

    ConnectionString {
        get {
            return this.InvokeGet("ConnectionString")
        }
    }

    Description {
        get {
            return this.InvokeGet("Description")
        }
    }

    DisabledByServer {
        get {
            return this.InvokeGet("DisabledByServer")
        }
    }

    Sessions {
        get {
            return this.InvokeGet("Sessions")
        }
    }

    CloseConnection() {
        return this.InvokeCall("CloseConnection")
    }

    CloseSession(sessionId) {
        return this.InvokeCall("CloseSession", sessionId)
    }
}
